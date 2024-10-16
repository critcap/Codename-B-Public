extends Node

const TOKEN: String = "token"
const SESSION_ID: String = "session_id"
const ACTION: String = "action"
const FROM_USER: String = "fromUser"
const TO_USER: String = "toUser"

#
const KEY_CHARACTER: String = "character"
const KEY_MAP: String = "map"
const KEY_DIFFICULTY: String = "difficulty"
const KEY_ITEMS: String = "items"
#
const ACTION_GET_SESSION_ID: String = "GET_SESSION_ID"
const ACTION_SEND_SESSION_ID: String = "SEND_SESSION_ID"
const ACTION_GAME_END: String = "GAME_END"
#
const PARAM_CHARACTER: String = "character"
const PARAM_DIFFICULTY: String = "difficulty"
const PARAM_ITEMS: String = "items"
const PARAM_MAP: String = "map"
const PARAM_GAME_START_PARAMETERS = "gameStartParameters"
# Game End Params
const PARAM_GAME_END: String = "gameEndParameters"
const PARAM_WIN_STATE = "win"
const PARAM_DEFEATED_ENEMIES = "defeatedEnemies"
const PARAM_SURVIVE_TIME = "surviveTime"
const PARAM_LEVEL_REACHED = "levelReached"
const PARAM_GOLD = "gold"
const PARAM_SCORE = "score"
const PARAM_ITEMS_USED = "itemsUsed"

@export var _client: WebSocketClient
@export var _bridge: JavaScriptBridgeWrapper
@export var _force_load_at_startup: bool = false

var game: Game
var session: GameSession
var gameStartParams: Dictionary

@onready var _start := %Startscreen
@onready var _title := %Title
@onready var _loading: LoadingScreen = %LoadingScreen


func _ready() -> void:
	# force load at startup for testings
	if _force_load_at_startup && !JavaScriptBridgeWrapper.is_web():
		_loading.start_transition()
		await _loading.loading_completed

	_client.data_received.connect(_on_data_received)
	_client.connection_closed.connect(_on_connection_closed)
	_client.connection_established.connect(_on_client_connection_established)
	_bridge.bridge_called.connect(func(data: Dictionary) -> void:
		_loading.start_transition()
		await _loading.loading_completed
		_loading.hide()
		_on_bridge_called(data)
		)


## build game from backend data
func create_game_from_data(data) -> void:
	Debug.print(typeof(data))
	if not data is Dictionary && not data is String:
		Debug.print("Invalid data type for game creation")
		return

	if not data is Dictionary:
		data = JSON.parse_string(data)

	var player_data: PlayerCharacterData
	var map_data: MapData
	var difficulty: int
	var items: Array

	var dict := data as Dictionary

	self.gameStartParams = dict

	for key in dict.keys():
		match key:
			KEY_CHARACTER:
				player_data = DataService.convert_shopitem_to_entity(dict[key])
				continue
			KEY_MAP:
				map_data = DataService.get_map_by_id(1)
				continue
			KEY_DIFFICULTY:
				difficulty = (
					int(dict[key].get("id"))
					if dict[key] is Dictionary && dict[key].has("id")
					else 1
				)
				continue
			KEY_ITEMS:
				var shop_items: Array = dict[key]
				if not shop_items is Array || shop_items.is_empty():
					Debug.print("Invalid items data for game creation or empty")
					continue
				items = []
				for item in shop_items:
					var entity = DataService.convert_shopitem_to_entity(item)
					if not entity is ItemData || not entity is WeaponData:
						Debug.print("Invalid item data for game creation %s" % str(item))
						continue
					items.append(DataService.convert_shopitem_to_entity(item))
				continue

	if !player_data or !map_data:
		Debug.print(
			(
				"Invalid data for game creation Player: %s Map %s items %s"
				% [player_data, map_data, items]
			)
		)
		return
	if OS.is_debug_build():
		await get_tree().create_timer(5.0).timeout
	game = NodeEx.add_child(GameService.create_game(player_data, map_data, items, difficulty), self)
	game.game_closed.connect(_on_game_game_closed)
	# _ui_lobby.close()
	_start.hide()
	_title.hide()


func _on_game_game_started(character: PlayerCharacterData) -> void:
	# _ui_lobby.hide()
	_start.hide()
	_title.hide()
	if !_force_load_at_startup:
		_loading.start_transition(true)
		await _loading.loading_completed
	var map := DataService.get_map_by_id(1)
	game = NodeEx.add_child(GameService.create_game(character, map), self)
	_loading.visible = false
	game.game_closed.connect(_on_game_game_closed)


func _on_game_game_closed(
	is_win: bool, items: Array, wave: int, time_in_sec: int, kills: int, gold: int, score: int
) -> void:
	_title.show()
	_start.show()
	if not JavaScriptBridgeWrapper.is_web():
		return

	var itemsUsed: String = JSON.stringify(items)
	Debug.print("ItemsUsed: ")
	Debug.print(itemsUsed)
	var string_data: String = (
		JSON
		. stringify(
			{
				ACTION: ACTION_GAME_END,
				TOKEN: session.backendToken,
				FROM_USER: session.godotSessionId,
				TO_USER: session.angularSessionId,
				PARAM_GAME_START_PARAMETERS: self.gameStartParams,
				PARAM_GAME_END:
				{
					PARAM_WIN_STATE: is_win,
					PARAM_DEFEATED_ENEMIES: kills,
					PARAM_SURVIVE_TIME: time_in_sec,
					PARAM_LEVEL_REACHED: wave,
					# no negative gold
					PARAM_GOLD: max(0, 10000),
					PARAM_SCORE: max(0, score),
					PARAM_ITEMS_USED: items
				}
			}
		)
	)
	_client.send_data(string_data)


func _on_data_received(data) -> void:
	Debug.print("Data received from Backend: " + data)
	var dataDict: Dictionary = self.parse_backend_session_response(data)

	if dataDict[ACTION] == "response_id_created":
		Debug.print("Setting godot session id: " + dataDict[FROM_USER])
		self.session.godotSessionId = dataDict[FROM_USER]
		Debug.print("Responding with the new godotSessionId!")
		_client.send_data(
			JSON.stringify(
				{
					ACTION: ACTION_SEND_SESSION_ID,
					TOKEN: session.backendToken,
					FROM_USER: session.godotSessionId,
					TO_USER: session.angularSessionId
				}
			)
		)

	if dataDict[ACTION] == "POST_GAME":
		Debug.print("Posting new game data!")
		if (
			dataDict[TO_USER] == session.godotSessionId
			and dataDict[FROM_USER] == session.angularSessionId
		):
			Debug.print("Authenticated message in godot!")
			if dataDict.has(PARAM_GAME_START_PARAMETERS):
				# self.set_game_session_params(dataDict[PARAM_GAME_START_PARAMETERS])
				create_game_from_data(dataDict[PARAM_GAME_START_PARAMETERS])


func _on_connection_closed() -> void:
	print("Connection closed")


func _on_bridge_called(session_info: Dictionary) -> void:
	session = GameSession.new()
	for key in session_info.keys():
		match key:
			TOKEN:
				Debug.print("Token set to: " + str(session_info.get(TOKEN)))
				session.backendToken = session_info.get(key)
			SESSION_ID:
				Debug.print("SessionId set to: " + str(session_info.get(SESSION_ID)))
				session.angularSessionId = session_info.get(key)
			_:
				Debug.print("Undefined key: %s found in session_info" % key)

	if session.backendToken == null or session.angularSessionId == null:
		Debug.print("Token or angularSessionId not found in session_info: %s" % session_info)
		return

	_client.connect_to_host()


func _on_client_connection_established():
	Debug.print("Connection established! Sending websocket data!")
	_client.send_data(
		JSON.stringify({ACTION: ACTION_GET_SESSION_ID, TOKEN: session.backendToken, FROM_USER: ""})
	)


func parse_backend_session_response(response: String) -> Dictionary:
	Debug.print("Parsing!")
	var json = JSON.new()
	var error = json.parse(response)
	if error == OK:
		return json.data
	else:
		Debug.print("Error when parsing backend JSON")
		return Dictionary()


func _on_startscreen_start_game(player: PlayerCharacterData) -> void:
	_on_game_game_started(player)

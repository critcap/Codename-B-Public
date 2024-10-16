class_name DebugLobbyMenu
extends Control

const _SESSION_ID_PREFIX: String = "Session ID: "
const _TOKEN_PREFIX: String = "Token: "
const _STATUS_PREFIX: String = "Socket Status: "
const _TEST_PREFIX: String = "Transmission Result: "

@export var web_socket_client: WebSocketClient
@export var js_bridge: JavaScriptBridgeWrapper

var session: GameSession

var _is_busy: bool = false

@onready var button_force_start: Button = %BtnForceStart
@onready var status_label: Label = %Status
@onready var _session_id_label: Label = %SessionIdLabel
@onready var _token_label: Label = %TokenLabel
@onready var _connection_status_id_label: Label = %ConnectionStatusLabel
@onready var _connection_test_label: Label = %ConnectionTestLabel
@onready var _bridge_status_label: Label = %BridgeStatusLabel
@onready var _btn_connect: Button = %BtnConnect
@onready var _btn_close: Button = %BtnClose
@onready var _btn_send: Button = %BtnSend
@onready var _btn_bridge_open_close : Button = %BtnBridge


func _ready():
	if !OS.is_debug_build():
		var controls: = get_tree().get_nodes_in_group(Group.DEBUG_UI_INFO) 
		%Buttons.visible = false
		button_force_start.visible = false
		for control in controls:
			control.visible = false
	_btn_connect.pressed.connect(_on_btn_connect_pressed)
	_btn_close.pressed.connect(_on_btn_close_pressed)
	_btn_send.pressed.connect(_on_btn_send_pressed)
	_btn_bridge_open_close.pressed.connect(_on_btn_bridge_toggle)
	
	_bridge_status_label.text = "Bridge is %s" % ("open" if js_bridge.is_bridge_open() else "closed")
	set_session_id("No Session ID")
	set_token("No Token")
	set_connection_test("Connection not tested")

	if !web_socket_client:
		Debug.print("WebSocketClient not found")
		%Buttons.visible = false
		return

	web_socket_client.connection_established.connect(
		func() -> void:
			_btn_close.disabled = false
			_btn_send.disabled = session == null
			_is_busy = false
			Debug.print("Connection established with" + web_socket_client.get_socket_url()))

	web_socket_client.connection_closed.connect(
		func() -> void:
			_btn_close.disabled = true
			_btn_send.disabled = true
			_btn_connect.disabled = false
			_is_busy = false
			Debug.print("Connection closed with " + web_socket_client.get_socket_url()))

	web_socket_client.attempt_aborted.connect(
		func() -> void:
			_is_busy = false
			_btn_close.disabled = true
			_btn_send.disabled = session == null
			_btn_connect.disabled = false)

	web_socket_client.data_received.connect(
		func(data: String) -> void:
			Debug.print("Data received: %1" %data))

	web_socket_client.connection_state.value_changed.connect(
		func(value: String, _observable) -> void:
			_connection_status_id_label.text = _STATUS_PREFIX + value)

	js_bridge.bridge_status_changed.connect(
		func(is_open: bool) -> void:
			_bridge_status_label.text = "Bridge is %s" % ("open" if is_open else "closed")
			_btn_bridge_open_close.text = "%s Bridge" % ("Close" if is_open else "Open"))

func close():
	visible = false

func set_session_id(session_id: String):
	_session_id_label.text = _SESSION_ID_PREFIX + session_id


func set_token(token: String):
	_token_label.text = _TOKEN_PREFIX + token


func set_connection_test(test_result: String):
	_connection_test_label.text = _TEST_PREFIX + test_result


func set_session(_session: GameSession):
	self.session = _session
	set_session_id(_session.angularSessionId)
	set_token(_session.backendToken)
	if _is_busy:
		return
	_btn_send.disabled = false


func _on_btn_connect_pressed():
	Debug.print("Trying connecting to Host")
	web_socket_client.connect_to_host()
	_btn_connect.disabled = true
	_is_busy = true


func _on_btn_close_pressed():
	if web_socket_client.get_state() == WebSocketPeer.STATE_CLOSING:
		Debug.print("Connection is already closing..")
		return
	web_socket_client.close_connection()
	_is_busy = true
	Debug.print("Closing connection...")


func _on_btn_send_pressed():
	Debug.print("Sending test message...")
	set_connection_test("Testing data transmission...")
	var data = {"token": session.backendToken, "session-id": session.angularSessionId}
	web_socket_client.send_data(JSON.stringify(data))
	_btn_send.disabled = true
	await web_socket_client.data_received
	_btn_send.disabled = false
	Debug.print("Data send & received successfully!")
	set_connection_test("Data send & received successfully!")


func _on_btn_bridge_toggle() -> void:
	if js_bridge.is_bridge_open():
		js_bridge.close_bridge()
	else:
		js_bridge.open_bridge()

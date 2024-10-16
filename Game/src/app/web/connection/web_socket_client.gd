class_name WebSocketClient
extends Node

@export var max_connection_attempts: int = 10

## Emits when data is received from the server
signal data_received(data: String)
## Emits when the connection is closed
signal connection_closed()
## Emits when the connection to host is established
signal connection_established()
## Emits when the connection/close attempt is aborted
signal attempt_aborted()

## ObservableString to store the connection state
var connection_state: = ObservableString.new("")

## WebSocketPeer instance
var _socket = WebSocketPeer.new()
var _socket_url: String = "ws://localhost:8080/socket"


func _ready() -> void:
	set_process(false)


func get_socket_url() -> StringName:
	return _socket_url

func get_state() -> WebSocketPeer.State:
	return _socket.get_ready_state()


## Connects to the host
func connect_to_host() -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		Debug.print("Already connected")
		return

	var code: = _socket.connect_to_url(_socket_url)
	await get_tree().create_timer(1.0).timeout
	if code != OK:
		Debug.print("Error connecting to host. Error Code: %d (%s)" % [code, error_string(code)])
		return
	
	var attemps: int = 0
	#while _socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
#
		#attemps += 1
		#Debug.print("%d/%d attempt to connecting to host..." % [attemps, max_connection_attempts])
#
		#_set_connection_state(_socket.get_ready_state())
		#await get_tree().create_timer(1.0).timeout
#
		#if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			#Debug.print("Connected")
			#break
		#if _socket.get_ready_state() != WebSocketPeer.STATE_CONNECTING:
			#Debug.print("Connection failed: %d" % _socket.get_ready_state())
			#Debug.print("Abort connection attempt!")
			#attempt_aborted.emit()
			#return
		#if attemps >= max_connection_attempts:
			#Debug.print("Connection failed after %d attemmps. Code %d" % [attemps,_socket.get_ready_state()])
			#Debug.print("Abort connection attempt!")
			#attempt_aborted.emit()
			#return

	set_process(true)
	connection_established.emit()


## Sends data to the server
func send_data(data: String) -> void:
	if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		Debug.print("Not connected to host. Trying to connect...")

		connect_to_host()

		if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			Debug.print("Connection failed. Data not sent.")
			attempt_aborted.emit()
			return

	Debug.print(data)
	_socket.send_text(data)


## Closes the connection
func close_connection() -> void:
	if _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		Debug.print("Not connected to host")
		attempt_aborted.emit()
		return
	
	_socket.close()
	connection_closed.emit()


func _receive_data() -> void:
	var data: = _socket.get_packet().get_string_from_utf8()
	Debug.print(data)
	data_received.emit(data)


func _process(delta):
	_socket.poll()
	var state = _socket.get_ready_state()
	_set_connection_state(state)
	
	if state == WebSocketPeer.STATE_OPEN:
		while _socket.get_available_packet_count():
			_receive_data()
	if state == WebSocketPeer.STATE_CLOSING:
		Debug.print("Closing Code: %d  Reason: %s")

	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _socket.get_close_code()
		var reason = _socket.get_close_reason()
		connection_closed.emit()
		Debug.print("Connection closed: Code:%d  Reason:%s" % [code, reason])
		set_process(false)

func _set_connection_state(state: int) -> void:
	if state == WebSocketPeer.STATE_CONNECTING:
		connection_state.set_next("Connecting")
	elif state == WebSocketPeer.STATE_OPEN:
		connection_state.set_next("Connected")
	elif state == WebSocketPeer.STATE_CLOSING:
		connection_state.set_next("Closing")
	elif state == WebSocketPeer.STATE_CLOSED:
		connection_state.set_next("Closed")

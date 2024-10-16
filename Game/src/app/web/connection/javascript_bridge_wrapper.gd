class_name JavaScriptBridgeWrapper
extends Node

signal bridge_called(data: Dictionary)
signal bridge_status_changed(is_open: bool)

var my_callback 

func is_bridge_open() -> bool:
	return my_callback != null

func close_bridge() -> void:
	if is_bridge_open():
		my_callback = null
		JavaScriptBridge.eval("""var godotBridge = null""", true)
		Debug.print("Bridge closed!")
		bridge_status_changed.emit(false)
		return
	Debug.print("No bridge to close.")
	
static func is_web() -> bool:
	var is_web: bool = false
	for platform in [&"web_android", &"web_ios", &"web_linuxbsd", &"web_macos", &"web_windows"]:
		if OS.has_feature(platform):
			Debug.print("Running on %s" % platform)
			is_web = true
			break
	return is_web
	
	
func open_bridge() -> void:
	if is_bridge_open():
		Debug.print("Bridge already open")
		return
	var is_web: bool = is_web()
			
	if not is_web:
		Debug.print("Not running on a web platform.")
		return

	my_callback = JavaScriptBridge.create_callback(_on_my_callback)
	JavaScriptBridge.eval("""
		var godotBridge = {
		callback: null,
		setCallback: (cb) => this.callback = cb,
		test: (data) => this.callback(JSON.stringify(data)),
		}
		window.addEventListener('message', (event) => {
	  if (event.origin === 'http://localhost:4200') {
		const receivedData = event.data;
		godotBridge.test(receivedData);
	  }
	});
	""", true)
	var godot_bridge = JavaScriptBridge.get_interface("godotBridge")
	godot_bridge.setCallback(my_callback)
	Debug.print("Bridge opened!")
	bridge_status_changed.emit(true)


func _ready() -> void:
	open_bridge()


func _on_my_callback(args) -> void:
	Debug.print("Callback called!")
	Debug.print(str(args))
	var info = JSON.parse_string(args[0])
	if not info is Dictionary:
		Debug.print("Error parsing JSON")
		return
	Debug.print(str(info))
	bridge_called.emit(info)

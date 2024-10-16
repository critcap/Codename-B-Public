class_name CameraRig
extends Node2D

## Target for the camera to follow
var _target: Node2D

@onready var _camera: Camera2D = %Camera2D

var is_manual_aim: bool = false
var player: Node2D
var squared: float = pow(250,2)

func _ready():
	set_physics_process(false)
	player = GameService.get_player()
	GameService.get_context().is_manual_aim.bind(self,&"is_manual_aim")
	


func set_limit(top: int, right: int, bottom: int, left: int):
	_camera.limit_left = left
	_camera.limit_right = right
	_camera.limit_top = top
	_camera.limit_bottom = bottom

func set_target(target: Node2D):
	_target = target
	_target.tree_exiting.connect(clear_target)
	set_physics_process(true)
	#NodeEx.reparent_node(_camera, _target, true)

func clear_target():
	assert(_target != null, "No target to clear")
	_target.tree_exiting.disconnect(clear_target)
	#if _is_attached():
	#	NodeEx.reparent_node(_camera, self, true)
	_target = null
	set_physics_process(false)

func _physics_process(delta: float):
	if !is_manual_aim:
		_camera.position = _target.position
	else:
		var origin: = player.global_position
		var target: = get_global_mouse_position() - origin
		if target.length_squared() > squared:
			target = target.normalized() * 250
		
		_camera.global_position = origin.lerp(target + origin, 0.2)

func _is_attached() -> bool:
	return true if _target != null && _camera.get_parent() == _target else false

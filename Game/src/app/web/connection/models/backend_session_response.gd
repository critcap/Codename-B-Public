class_name BackendSessionResponse
extends Node

var action: String = ""
var token: String = ""
var fromUser: String  = ""

func _init(action: String, token: String, fromUser: String) -> void:
	self.action = action
	self.token = token
	self.fromUser = fromUser
	

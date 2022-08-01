extends Button


func _ready():
	if !OS.is_debug_build():
		queue_free()
	connect("pressed",self,"DebugPress")

func DebugPress():
	if get_parent().get_parent().get_node_or_null("DebugScreen") == null:
		var debugWindow = load("res://Prefabs/Elements/DebugScreen.tscn").instance()
		get_parent().get_parent().add_child(debugWindow)
	get_parent().get_parent().ShowOnly("DebugScreen")
	get_parent().get_parent().get_node("DebugScreen").SyncDebug()

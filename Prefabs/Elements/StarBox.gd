extends HBoxContainer


func _ready():
	for x in get_children():
		x.connect("gui_input", Callable(self, "on_star_input").bind(x))
		
	MarkStars(5)
	
func on_star_input(event,star_node):
	
	if event is InputEventMouseButton:
		if event.pressed:
			var i = star_node.get_index()+1
			MarkStars(i,true)
	
func MarkStars(num_of_stars,animated = false):
	var cur_node = 0
	var T= null
	if animated:
		T = create_tween()
	for x in num_of_stars:
		cur_node += 1
		
		if animated:
			if get_child(cur_node-1).self_modulate != Color(1,1,1,1):
				T.tween_property(get_child(cur_node-1),"self_modulate",Color(1,1,1,1),0.2)
		else:
			get_child(cur_node-1).self_modulate = Color(1,1,1,1)
	
	cur_node = 5
	for x in 5-num_of_stars:
		cur_node -= 1
		if animated:
			if get_child(cur_node).self_modulate != Color(0.2,0.2,0.2,1):
				T.tween_property(get_child(cur_node),"self_modulate",Color(0.2,0.2,0.2,1),0.2)
		else:
			get_child(cur_node).self_modulate = Color(0.2,0.2,0.2,1)

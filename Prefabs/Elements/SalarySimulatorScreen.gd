extends Control

var TotalItemInstance = preload("res://Prefabs/Elements/TotalItem.tscn")

func _on_CloseBtn_pressed():
	get_parent().HideAll()
	get_parent().ShowOnly("TotalsScreen")


func _on_ValueBox_UpdatedVar(NewVar):
	var IL = GlobalTime.IsraelIncomeCalcFromSalary(0,0,0,NewVar)
	var VBox = get_node("Scroll/VBoxContainer")
	for x in VBox.get_children():
		x.queue_free()
	var Itm = null
	var Delay = 0.0
	var StepTime = 0.1
	for x in IL:
		if not "Nosafot" in x && not "Net" in x:
			Itm = TotalItemInstance.instance()
			VBox.add_child(Itm)
			var i = String(IL[x])
			if i.is_valid_integer():
				i = String(i)
			elif i.is_valid_float():
				i = GlobalTime.FloatToString(i,2)
			Itm.ShowItem(Delay,{"title":x,"desc":i})
			Delay += StepTime
		if x == "Net":
			var i = String(IL[x])
			if i.is_valid_integer():
				i = String(i)
			elif i.is_valid_float():
				i = GlobalTime.FloatToString(i,2)
			Itm = TotalItemInstance.instance()
			VBox.add_child(Itm)
			Itm.ShowItem(Delay,{"title":x,"desc":i})

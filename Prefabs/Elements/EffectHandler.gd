extends Node

func _ready():
	DeactivateAll()
# warning-ignore:return_value_discarded
	GlobalTime.connect("app_loaded",self,"app_loaded")
	for x in get_parent().get_node("BottomUI/HBoxContainer").get_children():
		x.connect("BtnPressed",self,"BtnPressed",[x])
	

func app_loaded():
	if IfBetweenMonths({"month":12,"year":2022},{"month":3,"year":2023}):
		ActivateOnly("Winter")

func BtnPressed(BtnNode):
	if BtnNode.name == "TimeScreen":
		app_loaded()
	else:
		DeactivateAll()
	
func IfBetweenMonths(Date1,Date2):
	var CurMonth = OS.get_datetime()
	var Min = Date1["year"]*Date1["year"] + Date1["month"]
	var Max = Date2["year"]*Date2["year"] + Date2["month"]
	var Cur = CurMonth["year"]*CurMonth["year"] + CurMonth["month"]
	if Cur >= Min && Cur <= Max:
		return true
	return false

func ActivateOnly(OnlyEffect):
	for a in get_children():
		if a.name == OnlyEffect:
			for b in a.get_children():
				if b is Particles2D:
					b.emitting = true
				if b is Sprite:
					b.visible = true
		else:
			for b in a.get_children():
				if b is Particles2D:
					b.emitting = false
				if b is Sprite:
					b.visible = false
func DeactivateAll():
	for a in get_children():
		for b in a.get_children():
			if b is Particles2D:
				b.emitting = false
			if b is Sprite:
				b.visible = false

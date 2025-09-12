@tool
extends Node

@export var HideAll: bool = false: set = SetHideAll

func _ready():
	if !Engine.is_editor_hint():
		DeactivateAll()
	# warning-ignore:return_value_discarded
		GlobalTime.connect("app_loaded", Callable(self, "app_loaded"))
	# warning-ignore:return_value_discarded
		GlobalTime.connect("BtnGroupPressed", Callable(self, "GroupBtnPressed"))
	# warning-ignore:return_value_discarded
		GlobalTime.connect("ShowOnlyScreen", Callable(self, "HourEditorScreen"))
	
func SetHideAll(new):
	HideAll = new
	if Engine.is_editor_hint():
		if HideAll:
			DeactivateAll()
			
func HourEditorScreen(ScreenName):
	if ScreenName != "TimeScreen":
		DeactivateAll()
	else:
		app_loaded()
	
func app_loaded():
	if IfBetweenMonths({"month":12,"year":2023},{"month":1,"year":2024}):
		ActivateOnly("Winter")
	if IfBetweenMonths({"month":10,"year":2023},{"month":12,"year":2023}):
		ActivateOnly("WeWithILUA")
		
	if ExactDayInYear({"month":4,"day":1}):
		ActivateOnly("AprilFool")
	if ExactDayInYear({"month":3,"day":8}):
		ActivateOnly("WomansDay")
	if ExactDayInYear({"month":2,"day":14}):
		ActivateOnly("ValentinceDay")

func GroupBtnPressed(BtnNode,GroupName):
	if GroupName != "Menu":
		return
	if BtnNode.name == "TimeScreen":
		app_loaded()
	else:
		DeactivateAll()
	
func ExactDayInYear(Date):
	var CurMonth = Time.get_datetime_dict_from_system()
	if CurMonth["month"]==Date["month"] && CurMonth["day"] == Date["day"]:
		return true
	return false
	
func IfBetweenMonths(Date1,Date2):
	var CurMonth = Time.get_datetime_dict_from_system()
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
				if b is GPUParticles2D:
					b.emitting = true
				if b is Sprite2D:
					b.visible = true
				if b is Label:
					b.visible = true
		else:
			for b in a.get_children():
				if b is GPUParticles2D:
					b.emitting = false
				if b is Sprite2D:
					b.visible = false
				if b is Label:
					b.visible = false
func DeactivateAll():
	for a in get_children():
		for b in a.get_children():
			if b is GPUParticles2D:
				b.emitting = false
			if b is Sprite2D:
				b.visible = false
			if b is Label:
				b.visible = false

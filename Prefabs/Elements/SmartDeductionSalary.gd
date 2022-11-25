extends Panel

var ClosedOpenedYValue = Vector2(280,100)


func _ready():
	$CreditBox.visible = false
	$Overtime1.visible = false
	$Overtime2.visible = false
	$GenderSelector.visible = false
	LoadSettings()
	InitCountryButton()
	
func InitCountryButton():
	for x in $Country.get_children():
		if not x is Timer:
			x.connect("index_pressed",self,"SelectCountry",[x])
		
func LoadSettings():
	var S = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	if S == null:
		rect_min_size.y = ClosedOpenedYValue.y
		SelectCountry(0,$Country.get_popup())
		return
		
	if S.has("flag"):
		$Flag.texture = load(S["flag"])
		
	if S.has("overtime125"):
		if S["overtime125"]:
			$Overtime1.AnimToggle()
			
	if S.has("overtime150"):
		if S["overtime150"]:
			$Overtime2.AnimToggle()
	
	
	if S.has("credit"):
		$CreditBox.visible = true
		$Overtime1.visible = true
		$Overtime2.visible = true
		$CreditBox.SetInisialValue(S["credit"])
		$GenderSelector.visible = true
	else:
		$Overtime1.visible = false
		$Overtime2.visible = false
		$CreditBox.visible = false
		$GenderSelector.visible = false
	SyncGenderSelector()


func EnableDisableModule(Enable):
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishAnim",[T])
	if Enable:
		T.interpolate_property(self,"rect_min_size:y",rect_min_size.y,ClosedOpenedYValue.x,0.2,Tween.TRANS_QUAD,Tween.EASE_OUT)
	else:
		T.interpolate_property(self,"rect_min_size:y",rect_min_size.y,ClosedOpenedYValue.y,0.2,Tween.TRANS_QUAD,Tween.EASE_OUT)
	T.start()
	
func FinishAnim(T):
	T.queue_free()
	
func SyncGenderSelector():
	match $CreditBox.InisialValue:
		2.25:
			SelectGender("Male")
		2.75:
			SelectGender("Female")
		_:
			SelectGender("")
			
func SelectGender(GenderName):
	for x in $GenderSelector.get_children():
		if x.name == GenderName:
			GlobalTime.emit_signal("BtnGroupPressed",x,"Gender")
			return
	#If non selected, deactivate both
	GlobalTime.emit_signal("BtnGroupPressed",null,"Gender")
			
func SelectCountry(Index,MenuItem):
	var Icon = MenuItem.get_item_icon(Index)
	$Flag.texture = Icon
	var Country = MenuItem.get_item_text(Index)
	if Index == 0:
		GlobalSave.RemoveSettingByCategory("SalaryDeduction")
		$CreditBox.visible = false
		$Overtime1.visible = false
		$Overtime2.visible = false
		$GenderSelector.visible = false
		EnableDisableModule(false)
	else:
		GlobalTime.emit_signal("ShowInterstitalAd")
		EnableDisableModule(true)
		$CreditBox.visible = true
		$Overtime1.visible = true
		$Overtime2.visible = true
		$GenderSelector.visible = true
		GlobalSave.AddVarsToSettings("SalaryDeduction","flag",Icon.resource_path)
		GlobalSave.AddVarsToSettings("SalaryDeduction","country",Country)
		GlobalSave.AddVarsToSettings("SalaryDeduction","credit",$CreditBox.InisialValue)
		GlobalSave.AddVarsToSettings("SalaryDeduction","overtime125",$Overtime1.is_Pressed)
		GlobalSave.AddVarsToSettings("SalaryDeduction","overtime150",$Overtime2.is_Pressed)


func _on_CreditBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SalaryDeduction","credit",float(NewVar))
	SyncGenderSelector()


func _on_Overtime1_OnToggle():
	GlobalSave.AddVarsToSettings("SalaryDeduction","overtime125",$Overtime1.is_Pressed)


func _on_Overtime2_OnToggle():
	GlobalSave.AddVarsToSettings("SalaryDeduction","overtime150",$Overtime2.is_Pressed)


func _on_Flag_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Country.ForceShowOnMouse(event.global_position)


func _on_Female_BtnPressed():
	$CreditBox.SetInisialValue(2.75)


func _on_Male_BtnPressed():
	$CreditBox.SetInisialValue(2.25)

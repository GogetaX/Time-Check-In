extends Panel

var OldSalary = 0

func _ready():
	#GlobalSave.AddVarsToSettings("SaloryCalculation","salary",$ValueBox.InisialValue)
	InitAllCurrencyButtons()
	SyncFromSave()
	
func InitAllCurrencyButtons():
	for x in $Currency.get_children():
		if not x is Timer:
			x.connect("index_pressed",self,"SelectCurrency",[x])



func SelectCurrency(Index,MenuItem):
	var Icon = MenuItem.get_item_icon(Index)
	var Sufix = MenuItem.get_item_text(Index)
	$CurrentCurrencyIcon.texture = Icon
	
	GlobalSave.AddVarsToSettings("SaloryCalculation","icon",Icon.resource_path)
	GlobalSave.AddVarsToSettings("SaloryCalculation","sufix",Sufix)
	GlobalTime.emit_signal("UpdateDayInfo")
	
func _on_CheckBox_OnToggle():
	DisableEnable(!$Activate.is_Pressed)
	GlobalSave.AddVarsToSettings("SaloryCalculation","enabled",$Activate.is_Pressed)
	GlobalSave.AddVarsToSettings("SaloryCalculation","salary",$SalaryBox.InisialValue)
	GlobalSave.AddVarsToSettings("SaloryCalculation","bonus",$TravelBox.InisialValue)
	GlobalTime.emit_signal("UpdateDayInfo")
		
func DisableEnable(SetAsDisable):
	$SalaryBox.Disable(SetAsDisable)
	$TravelBox.Disable(SetAsDisable)
	$Currency.disabled = SetAsDisable
	
	

func _on_ValueBox_UpdatedVar(NewVar):
	if OldSalary > 0 && NewVar > OldSalary:
		var PercentUp = int((NewVar / OldSalary -1) * 100)
		if PercentUp >= 1 && PercentUp <= 100:
			var MonthsUsed = GlobalSave.HowManyMonthsWorked()
			if MonthsUsed != null && MonthsUsed.size()>1:
				PercentUp = String(PercentUp)+"%"
				var PopupData = {"type": "Congrats","Title":TranslationServer.translate("salary_raise"),"Desc":TranslationServer.translate("congrats_on_salary_raise") % PercentUp}
				GlobalTime.ShowPopup(PopupData)
			
	GlobalSave.AddVarsToSettings("SaloryCalculation","salary",NewVar)
	GlobalTime.emit_signal("UpdateDayInfo")
	GlobalTime.emit_signal("ShowInterstitalAd")
	OldSalary = NewVar
	
func _on_TravelBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SaloryCalculation","bonus",NewVar)
	GlobalTime.emit_signal("ShowInterstitalAd")

func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if S == null:
		SelectCurrency(1,$Currency.get_popup())
		return

	if S.has("salary"):
		$SalaryBox.SetInisialValue(S["salary"])
		OldSalary = S["salary"]
	if S.has("bonus"):
		$TravelBox.SetInisialValue(S["bonus"])
	if S.has("icon"):
		$CurrentCurrencyIcon.texture = load(S["icon"])
	if S.has("enabled"):
		if S["enabled"]:
			$Activate.AnimToggle()
		DisableEnable(!S["enabled"])





func _on_CurrentCurrencyIcon_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Currency.ForceShowOnMouse(event.global_position)

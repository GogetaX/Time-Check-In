extends Panel



func _ready():
	#GlobalSave.AddVarsToSettings("SaloryCalculation","salary",$ValueBox.InisialValue)
	InitAllCurrencyButtons()
	SyncFromSave()
	
func InitAllCurrencyButtons():
	for x in $Currency.get_children():
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
	GlobalSave.AddVarsToSettings("SaloryCalculation","travel",$TravelBox.InisialValue)
	GlobalTime.emit_signal("UpdateDayInfo")
		
func DisableEnable(SetAsDisable):
	$SalaryBox.Disable(SetAsDisable)
	$TravelBox.Disable(SetAsDisable)
	$Currency.disabled = SetAsDisable
	
	

func _on_ValueBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SaloryCalculation","salary",NewVar)
	GlobalTime.emit_signal("UpdateDayInfo")
	
func _on_TravelBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SaloryCalculation","travel",NewVar)

func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("SaloryCalculation")
	if S == null:
		return

	if S.has("salary"):
		$SalaryBox.SetInisialValue(S["salary"])
	if S.has("travel"):
		$TravelBox.SetInisialValue(S["travel"])
	if S.has("icon"):
		$CurrentCurrencyIcon.texture = load(S["icon"])
	if S.has("enabled"):
		if S["enabled"]:
			$Activate.AnimToggle()
		DisableEnable(!S["enabled"])




extends Panel


func _ready():
	$CreditBox.visible = false
	$Overtime1.visible = false
	$Overtime2.visible = false
	LoadSettings()
	InitCountryButton()
	
func InitCountryButton():
	for x in $Country.get_children():
		x.connect("index_pressed",self,"SelectCountry",[x])
		
func LoadSettings():
	var S = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	if S == null:
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
	else:
		$Overtime1.visible = false
		$Overtime2.visible = false
		$CreditBox.visible = false


func SelectCountry(Index,MenuItem):
	var Icon = MenuItem.get_item_icon(Index)
	$Flag.texture = Icon
	var Country = MenuItem.get_item_text(Index)
	if Index == 0:
		GlobalSave.RemoveSettingByCategory("SalaryDeduction")
		$CreditBox.visible = false
		$Overtime1.visible = false
		$Overtime2.visible = false
	else:
		$CreditBox.visible = true
		$Overtime1.visible = true
		$Overtime2.visible = true
		GlobalSave.AddVarsToSettings("SalaryDeduction","flag",Icon.resource_path)
		GlobalSave.AddVarsToSettings("SalaryDeduction","country",Country)
		GlobalSave.AddVarsToSettings("SalaryDeduction","credit",$CreditBox.InisialValue)


func _on_CreditBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SalaryDeduction","credit",float(NewVar))


func _on_Overtime1_OnToggle():
	GlobalSave.AddVarsToSettings("SalaryDeduction","overtime125",$Overtime1.is_Pressed)


func _on_Overtime2_OnToggle():
	GlobalSave.AddVarsToSettings("SalaryDeduction","overtime150",$Overtime2.is_Pressed)

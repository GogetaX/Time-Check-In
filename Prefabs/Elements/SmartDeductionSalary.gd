extends Panel


func _ready():
	$CreditBox.visible = false
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
	
	if S.has("credit"):
		$CreditBox.visible = true
		$CreditBox.SetInisialValue(S["credit"])
	else:
		$CreditBox.visible = false


func SelectCountry(Index,MenuItem):
	var Icon = MenuItem.get_item_icon(Index)
	$Flag.texture = Icon
	var Country = MenuItem.get_item_text(Index)
	if Index == 0:
		GlobalSave.RemoveSettingByCategory("SalaryDeduction")
		$CreditBox.visible = false
	else:
		$CreditBox.visible = true
		GlobalSave.AddVarsToSettings("SalaryDeduction","flag",Icon.resource_path)
		GlobalSave.AddVarsToSettings("SalaryDeduction","country",Country)
		GlobalSave.AddVarsToSettings("SalaryDeduction","credit",$CreditBox.InisialValue)


func _on_CreditBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("SalaryDeduction","credit",float(NewVar))

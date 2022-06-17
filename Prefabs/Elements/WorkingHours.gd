extends Panel


func _ready():
	SyncFromSave()
	
func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if S == null:
		return

	if S.has("hours"):
		$ValueBox.SetInisialValue(S["hours"])


func _on_ValueBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("WorkingHours","hours",NewVar)

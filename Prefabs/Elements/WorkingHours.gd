extends Panel


func _ready():
	SyncFromSave()
	
func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if S == null:
		GlobalSave.AddVarsToSettings("WorkingHours","hours",$WorkingHours.InisialValue)
		return

	if S.has("hours"):
		$WorkingHours.SetInisialValue(S["hours"])


func _on_ValueBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("WorkingHours","hours",NewVar)

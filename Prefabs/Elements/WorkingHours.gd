extends Panel


func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("app_loaded",self,"app_loaded")
	#SyncFromSave()
	
func app_loaded():
	yield(get_tree(),"idle_frame")
	SyncFromSave()
	
func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if S == null:
		GlobalSave.AddVarsToSettings("WorkingHours","hours",$WorkingHours.InisialValue)
		GlobalSave.AddVarsToSettings("WorkingHours","minutes",$WorkingMinutes.InisialValue)
		GlobalSave.AddVarsToSettings("WorkingHours","monthly_hours",$WorkingMonthlyHours.InisialValue)
		return
		
	if S.has("minutes"):
		$WorkingMinutes.SetInisialValue(S["minutes"])
	else:
		$WorkingMinutes.SetInisialValue(8)
	if S.has("monthly_hours"):
		$WorkingMonthlyHours.SetInisialValue(S["monthly_hours"])
	else:
		
		$WorkingMonthlyHours.SetInisialValue(176)
		
	if S.has("hours"):
		$WorkingHours.SetInisialValue(S["hours"])
		
	if S.has("check_out_reminder"):
		if S["check_out_reminder"]:
			$CheckOutReminder.AnimToggle(false)


func _on_ValueBox_UpdatedVar(NewVar):
	if int(NewVar) == 0:
		if int($WorkingMinutes.GetValue()) == 0:
			$WorkingMinutes.SetInisialValue(30)
			GlobalSave.AddVarsToSettings("WorkingHours","minutes",$WorkingMinutes.InisialValue)
	GlobalSave.AddVarsToSettings("WorkingHours","hours",NewVar)


func _on_CheckOutReminder_OnToggle():
	GlobalSave.AddVarsToSettings("WorkingHours","check_out_reminder",$CheckOutReminder.is_Pressed)
	return
	if $CheckOutReminder.is_Pressed:
		GlobalNotif.RequestPermision()
		if OS.get_name() == "iOS":
			if !localnotification.is_enabled():
				var PopupData = {"type": "ok","Title":TranslationServer.translate("Problem"),"Desc":TranslationServer.translate("Notification is not enabled in the device settings")}
				GlobalTime.ShowPopup(PopupData)
				$CheckOutReminder.AnimToggle()


func _on_WorkingMinutes_UpdatedVar(NewVar):
	if int(NewVar) == 0:
		if int($WorkingHours.GetValue()) == 0:
			$WorkingHours.SetInisialValue(1)
			GlobalSave.AddVarsToSettings("WorkingHours","hours",$WorkingMinutes.InisialValue)
	GlobalSave.AddVarsToSettings("WorkingHours","minutes",NewVar)


func _on_WorkingMonthlyHours_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("WorkingHours","monthly_hours",NewVar)

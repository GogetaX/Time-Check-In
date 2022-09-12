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
		
	if S.has("check_out_reminder"):
		if S["check_out_reminder"]:
			$CheckOutReminder.AnimToggle(false)


func _on_ValueBox_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("WorkingHours","hours",NewVar)


func _on_CheckOutReminder_OnToggle():
	GlobalSave.AddVarsToSettings("WorkingHours","check_out_reminder",$CheckOutReminder.is_Pressed)
	if $CheckOutReminder.is_Pressed:
		GlobalNotif.RequestPermision()
		if OS.get_name() == "iOS":
			if !localnotification.is_enabled():
				var PopupData = {"type": "ok","Title":TranslationServer.translate("Problem"),"Desc":TranslationServer.translate("Notification is not enabled in the device settings")}
				GlobalTime.ShowPopup(PopupData)
				$CheckOutReminder.AnimToggle()

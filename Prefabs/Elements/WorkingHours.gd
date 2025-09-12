extends Panel

# Called when the node enters the scene tree, sets up signal connection
func _ready():
	# warning-ignore:return_value_discarded
	GlobalTime.connect("app_loaded", Callable(self, "app_loaded"))
	# SyncFromSave() is deferred to app_loaded to ensure all nodes are ready

# Waits for the next process frame before syncing settings
func app_loaded():
	await get_tree().process_frame
	SyncFromSave()

# Syncs UI elements with saved settings or sets defaults if not present
func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if S == null:
		GlobalSave.AddVarsToSettings("WorkingHours", "hours", $WorkingHours.InisialValue)
		GlobalSave.AddVarsToSettings("WorkingHours", "minutes", $WorkingMinutes.InisialValue)
		GlobalSave.AddVarsToSettings("WorkingHours", "monthly_hours", $WorkingMonthlyHours.InisialValue)
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

# Handles updates to working hours, ensures non-zero total duration
func _on_ValueBox_UpdatedVar(NewVar):
	var hours = int(NewVar)
	var minutes = int($WorkingMinutes.GetValue())
	if hours == 0 and minutes == 0:
		$WorkingMinutes.SetInisialValue(30)
		GlobalSave.AddVarsToSettings("WorkingHours", "minutes", $WorkingMinutes.InisialValue)
	GlobalSave.AddVarsToSettings("WorkingHours", "hours", hours)

# Manages the check-out reminder toggle and notification permissions
func _on_CheckOutReminder_OnToggle():
	GlobalSave.AddVarsToSettings("WorkingHours", "check_out_reminder", $CheckOutReminder.is_Pressed)
	if $CheckOutReminder.is_Pressed:
		GlobalNotif.RequestPermision()
		if OS.get_name() == "iOS":
			if not LocalNotification.isPermissionGranted():
				var PopupData = {
					"type": "ok",
					"Title": TranslationServer.translate("Problem"),
					"Desc": TranslationServer.translate("Notification is not enabled in the device settings")
				}
				GlobalTime.ShowPopup(PopupData)
				$CheckOutReminder.AnimToggle()

# Handles updates to working minutes, ensures non-zero total duration
func _on_WorkingMinutes_UpdatedVar(NewVar):
	var minutes = int(NewVar)
	var hours = int($WorkingHours.GetValue())
	if minutes == 0 and hours == 0:
		$WorkingHours.SetInisialValue(1)
		GlobalSave.AddVarsToSettings("WorkingHours", "hours", $WorkingHours.InisialValue)
	GlobalSave.AddVarsToSettings("WorkingHours", "minutes", minutes)

# Updates monthly working hours setting
func _on_WorkingMonthlyHours_UpdatedVar(NewVar):
	GlobalSave.AddVarsToSettings("WorkingHours", "monthly_hours", NewVar)

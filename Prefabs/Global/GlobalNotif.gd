extends Node

enum NotifTags {REMINDER_SPECIFIC_HOURS_PASSED, STARTED_125, STARTED_150}

func _ready():
	LocalNotification.init()

func ClearNotifications():
	for x in NotifTags:
		LocalNotification.cancel(x)

func PushCheckOutReminder():
	var tot_hours = 8
	var tot_minutes = 0
	var tot_minutes_str = "00"
	var Deduction = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var WorkingHours = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if WorkingHours == null:
		return
	if WorkingHours.has("hours"):
		tot_hours = WorkingHours["hours"]
	if WorkingHours.has("minutes"):
		tot_minutes = WorkingHours["minutes"]
		if tot_minutes < 10:
			tot_minutes_str = "0" + str(tot_minutes)
		else:
			tot_minutes_str = str(tot_minutes)
	if WorkingHours.has("check_out_reminder"):
		if WorkingHours["check_out_reminder"]:
			var passed_time = str(tot_hours) + ":" + tot_minutes_str
			LocalNotification.show("Time Check-In", TranslationServer.translate("p_notif_passed_hours") % passed_time, (tot_hours * 3600) + (tot_minutes * 60), NotifTags.REMINDER_SPECIFIC_HOURS_PASSED)
			if Deduction != null:
				if Deduction.has("overtime125") and Deduction["overtime125"]:
					if tot_hours == 8:
						LocalNotification.show("Time Check-In", TranslationServer.translate("p_notif_125"), 8 * 3600, NotifTags.STARTED_125)
					else:
						LocalNotification.show("Time Check-In", TranslationServer.translate("p_notif_125"), 8 * 3600, NotifTags.STARTED_125)
				if Deduction.has("overtime150") and Deduction["overtime150"]:
					LocalNotification.show("Time Check-In", TranslationServer.translate("p_notif_150"), 10 * 3600, NotifTags.STARTED_150)

func RequestPermision():
	match OS.get_name():
		"iOS":
			if not LocalNotification.is_inited():
				LocalNotification.init()
		"Android":
			if not LocalNotification.isPermissionGranted():
				LocalNotification.requestPermission()

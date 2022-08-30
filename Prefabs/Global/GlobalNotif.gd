extends Node

func PushCheckOutReminder():
	var WorkingHours = 8
	
	var S = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	if S.has("hours"):
		WorkingHours = S["hours"]
	if S.has("check_out_reminder"):
		if S["check_out_reminder"]:
			print("Setting up notification for ",WorkingHours," hours")
			localnotification.show("This is a test msg","Test Title",10,0)

func RequestPermision():
	match OS.get_name():
		"iOS":
			if !localnotification.is_inited():
				localnotification.init()
				print("Enabling Notification")

extends Node

func ClearNotifications():
	localnotification.cancel_all()

func PushCheckOutReminder():
	var tot_hours = 8
	var Deduction = GlobalSave.GetValueFromSettingCategory("SalaryDeduction")
	var WorkingHours = GlobalSave.GetValueFromSettingCategory("WorkingHours")
	
	if WorkingHours == null:
		return
	if WorkingHours.has("hours"):
		tot_hours = WorkingHours["hours"]
	
	if WorkingHours.has("check_out_reminder"):
		if WorkingHours["check_out_reminder"]:
			localnotification.show("Passed "+String(tot_hours)+" hours, time to check out!","Time Check-In",tot_hours*3600,0)
			if Deduction != null:
				if Deduction.has("overtime125") && Deduction["overtime125"]:
					localnotification.show("You have started your overtime 125%","Time Check-In",8*3600,0)
				if Deduction.has("overtime150") && Deduction["overtime150"]:
					localnotification.show("You have started your overtime 150%","Time Check-In",10*3600,1)

func RequestPermision():
	match OS.get_name():
		"iOS":
			if !localnotification.is_inited():
				localnotification.init()

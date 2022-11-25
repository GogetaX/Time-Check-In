extends Node

func ClearNotifications():
	localnotification.cancel_all()

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
		if tot_minutes<10:
			tot_minutes_str = "0"+String(tot_minutes)
		else:
			tot_minutes_str = String(tot_minutes)
	if WorkingHours.has("check_out_reminder"):
		if WorkingHours["check_out_reminder"]:
			var passed_time = String(tot_hours)+":"+tot_minutes_str
			localnotification.show(TranslationServer.translate("p_notif_passed_hours") % passed_time,"Time Check-In",(tot_hours*3600)+(tot_minutes*60),0)
			if Deduction != null:
				if Deduction.has("overtime125") && Deduction["overtime125"]:
					if tot_hours == 8:
						localnotification.show(TranslationServer.translate("p_notif_125"),"Time Check-In",8*3600,0)
					else:
						localnotification.show(TranslationServer.translate("p_notif_125"),"Time Check-In",8*3600,2)
				if Deduction.has("overtime150") && Deduction["overtime150"]:
					localnotification.show(TranslationServer.translate("p_notif_150"),"Time Check-In",10*3600,1)

func RequestPermision():
	match OS.get_name():
		"iOS":
			if !localnotification.is_inited():
				localnotification.init()

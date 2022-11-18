extends Node

func ExportModule(info):
	var ExportData = {}
	while true:
		if info["CurYear"]*info["CurMonth"] > info["LastMonth"]["year"]*info["LastMonth"]["month"]:
			break
		var d = GlobalSave.LoadDateForExport(info["CurMonth"],info["CurYear"])
		if d != null:
			if !ExportData.has(info["CurYear"]):
				ExportData[info["CurYear"]] = {}
			if !ExportData[info["CurYear"]].has(info["CurMonth"]):
				ExportData[info["CurYear"]][info["CurMonth"]] = {}
			ExportData[info["CurYear"]][info["CurMonth"]] = d
		info["CurMonth"] += 1
		if info["CurMonth"] > 12:
			info["CurYear"] += 1
			info["CurMonth"] = 1
	var F = File.new()
	var dir = Directory.new()
	if !dir.dir_exists("user://exports/"):
		dir.make_dir("user://exports/")
	var Cur_Date = OS.get_datetime()
	var f_name = "ExportCSV-"+String(Cur_Date["day"])+"-"+String(Cur_Date["month"])+"-"+String(Cur_Date["year"])+".csv"
	#F.open("user://exports/"+f_name,File.WRITE)
	print("Saving as path")
	print(ProjectSettings.globalize_path(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/"+f_name))
	var o = F.open(ProjectSettings.globalize_path(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/"+f_name),File.WRITE)
	print("File Open Msg: ",o)
	F.store_string("Date,Worked hours,Details\n")
	for Year in ExportData:
		for Month in ExportData[Year]:
			for Day in ExportData[Year][Month]:
				var tot = GlobalTime.CalcBetweenCheckinsTOSeconds(ExportData[Year][Month][Day])
				var t = GlobalTime.SecondsToDate(tot)
				
				var worked_str = ""
				if tot > 0:
					worked_str = String(t["hour"])+":"+String(t["minute"])+":"+String(t["second"])
				if ExportData[Year][Month][Day].has("report"):
					worked_str = ExportData[Year][Month][Day]["report"]
				var details = GlobalTime.GetAllCheckInAndOuts(ExportData[Year][Month][Day],10,false).replace(","," >")
				#print(worked_str)
				if tot > 0 || worked_str != "":
					var s = String(Day)+"/"+String(Month)+"/"+String(Year)+","+worked_str+","+details+"\n"
					F.store_string(s)
	F.close()
# warning-ignore:return_value_discarded
	var PopupData = {"type": "ok","Title":"Export","Desc":TranslationServer.translate("finished_export_as") % f_name}
	var _Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")

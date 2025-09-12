extends Node

	
func CreateFile(path,fname):
	
	if !DirAccess.dir_exists_absolute(path):
		var D = DirAccess.open(path)
		D.make_dir_recursive(path)
	var F = FileAccess.open(path+fname,FileAccess.WRITE)
	F.store_line("Path3D: "+path)
	F.close()
	
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
	var Cur_Date = Time.get_datetime_dict_from_system()
	var f_name = "ExportCSV-"+String(Cur_Date["day"])+"-"+String(Cur_Date["month"])+"-"+String(Cur_Date["year"])+".csv"
	#F.open("user://exports/"+f_name,File.WRITE)
	var F = null
	match OS.get_name():
		"iOS":
			if !DirAccess.dir_exists_absolute("user://exports/"):
				DirAccess.make_dir_absolute("user://exports/")
			F = FileAccess.open("user://exports/"+f_name,FileAccess.WRITE)
		"Windows","Android","MacOS":
			F.open(ProjectSettings.globalize_path(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/"+f_name),FileAccess.WRITE)
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
	match OS.get_name():
		"Android","Windows","MacOS":
			var PopupData = {"type": "export","Title":"Export","FName":f_name,"Desc1":TranslationServer.translate("finished_export_android"),"Desc2":TranslationServer.translate("finished_export_android_path")}
			var _Answer = await GlobalTime.ShowPopup(PopupData)
		"iOS":
			var PopupData = {"type": "export","Title":"Export","FName":f_name,"Desc1":TranslationServer.translate("finished_export_ios"),"Desc2":TranslationServer.translate("finished_export_ios_path")}
			var _Answer = await GlobalTime.ShowPopup(PopupData)
			
			return


func AttachFileToEmailiOS(ReportFile):
	var txt = "mailto:?subject=Report: "+String(ReportFile)+"&attachment=user://exports/"+ReportFile
	txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
	OS.shell_open(txt)

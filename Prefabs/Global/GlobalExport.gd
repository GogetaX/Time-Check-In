extends Node

	
func CreateFile(path,fname):
	var D = Directory.new()
	if !D.dir_exists(path):
		D.make_dir_recursive(path)
	var F = File.new()
	F.open(path+fname,File.WRITE)
	F.store_line("Path: "+path)
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
	var F = File.new()
	var Cur_Date = OS.get_datetime()
	var f_name = "ExportCSV-"+String(Cur_Date["day"])+"-"+String(Cur_Date["month"])+"-"+String(Cur_Date["year"])+".csv"
	#F.open("user://exports/"+f_name,File.WRITE)
	match OS.get_name():
		"iOS":
			var D = Directory.new()
			if !D.dir_exists("user://exports/"):
				D.make_dir("user://exports/")
			F.open("user://exports/"+f_name,File.WRITE)
		"Windows","Android","MacOS":
			F.open(ProjectSettings.globalize_path(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/"+f_name),File.WRITE)
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
			var _Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
		"iOS":
			var PopupData = {"type": "export","Title":"Export","FName":f_name,"Desc1":TranslationServer.translate("finished_export_ios"),"Desc2":TranslationServer.translate("finished_export_ios_path")}
			var _Answer = yield(GlobalTime.ShowPopup(PopupData),"completed")
			
			return

func GetiOSLibraryPath():
	#/Users/sergiokirienko/Library/Developer/CoreSimulator/Devices/10672DE3-D6D4-409F-94FD-CCAA11573322/data/Containers/Data/Application/614E7B6F-A5DD-4B63-BAB8-5306F16F24FA/Documents/Documents/ExportCSV-18-11-2022.csv
	var res = ProjectSettings.globalize_path("user://")
	var d = res.split("/")
	var r = ""
	for x in d:
		if x == "Documents":
			return r+"/Library/"
		r = r + "/"+x
	return r

func AttachFileToEmailiOS(ReportFile):
	var txt = "mailto:?subject=Report: "+String(ReportFile)+"&attachment=user://exports/"+ReportFile
	txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
	OS.shell_open(txt)

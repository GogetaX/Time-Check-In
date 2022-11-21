extends Control



func _ready():
	GlobalTime.ExporterUI = self
	if OS.get_name() == "iOS":
		$VBoxContainer/ExportBtn.disabled = true


func _on_Accept_pressed():
	get_parent().HideAll()
	get_parent().ShowOnly("TotalsScreen")


func _on_ExportBtn_pressed():
	var GetFirstMonth = $VBoxContainer/TimePeriodSelector.GetFirstMonth()
	var GetLastMonth = $VBoxContainer/TimePeriodSelector.GetLastMonth()
	var CurMonth = GetFirstMonth["month"]
	var CurYear = GetFirstMonth["year"]
	
	GlobalExport.ExportModule({"CurYear":CurYear,"CurMonth":CurMonth,"FirstMonth":GetFirstMonth,"LastMonth":GetLastMonth})

func _on_ReportToDev_pressed():
	var date = OS.get_datetime()
	match OS.get_name():
		"Android","Windows":
# warning-ignore:return_value_discarded
			OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Export feature request "+
			String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name())
		"iOS":
			var txt = "mailto:gogetax2@gmail.com?subject=Export feature request "+String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()
			txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
			OS.shell_open(txt)

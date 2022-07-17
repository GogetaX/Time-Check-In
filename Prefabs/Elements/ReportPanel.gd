extends Panel



func _on_ReportBug_pressed():
	var date = OS.get_datetime()
	match OS.get_name():
		"Android","Windows":
			var a = OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Report bug "+
			String(date["day"])+"/"+String(date["month"])+"/"+String(date["year"])+"&body=type your bug description here.")
			print("email ",a)
		"iOS":
			var a = OS.shell_open("mailto:gogetax2@gmail.com")
			print(a)

func _on_RequestFeature_pressed():
	var date = OS.get_datetime()
# warning-ignore:return_value_discarded
	OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Request feature "+
	String(date["day"])+"/"+String(date["month"])+"/"+String(date["year"])+"&body=type your feature request description here.")

extends Panel



func _on_ReportBug_pressed():
	var date = OS.get_datetime()
	var BugDescription = TranslationServer.translate("email_bug_description")
	match OS.get_name():
		"Android","Windows":
# warning-ignore:return_value_discarded
			OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Report bug "+
			String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="+BugDescription)
		"iOS":
			var txt = "mailto:gogetax2@gmail.com?subject=Report bug "+String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="
			txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
			OS.shell_open(txt)
			
func _on_RequestFeature_pressed():
	var date = OS.get_datetime()
	var FeatureDescription = TranslationServer.translate("email_feature_description")
	match OS.get_name():
		"Android","Windows":
# warning-ignore:return_value_discarded
			OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Request feature "+
			String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="+FeatureDescription)
		"iOS":
			var txt = "mailto:gogetax2@gmail.com?subject=Request feature "+String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="
			txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
			OS.shell_open(txt)



func _on_Debugger_pressed():
	var date = OS.get_datetime()
	var FeatureDescription = OS.get_unique_id()
	match OS.get_name():
		"Android","Windows":
# warning-ignore:return_value_discarded
			OS.shell_open("mailto:?to=gogetax2@gmail.com&subject=Report "+
			String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="+FeatureDescription)
		"iOS":
			var txt = "mailto:gogetax2@gmail.com?subject=Report "+String(date["day"])+"."+String(date["month"])+"."+String(date["year"])+"/"+OS.get_name()+"&body="+FeatureDescription
			txt = txt.replace(" ","%20")
# warning-ignore:return_value_discarded
			OS.shell_open(txt)

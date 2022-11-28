extends Panel


func _ready():
	InitLanguangeButton()
	SyncFromSave()
	
func InitLanguangeButton():
	for x in $Lang.get_children():
		if not x is Timer:
			x.connect("index_pressed",self,"SelectLang",[x])

func FindItemIndexByLang(Lang):
	for x in $Lang.get_popup().get_item_count():
		if GlobalSave.LanguangeToLetters($Lang.get_popup().get_item_text(x)) == Lang:
			return x
	return -1
	
func SyncFromSave():
	
			
	var S = GlobalSave.GetValueFromSettingCategory("Languange")
	if S == null:
		#first time run? set default lang
		if TranslationServer.get_loaded_locales().has(OS.get_locale_language()):
			var index = FindItemIndexByLang(OS.get_locale_language())
			if index >= 0:
				SelectLang(index,$Lang.get_popup(),true)
		return
	if S.has("icon"):
		$LangTexture.texture = load(S["icon"])
	
func SelectLang(Index,MenuItem,first_run = false):
	var Icon = MenuItem.get_item_icon(Index)
	$LangTexture.texture = Icon
	var Lang = MenuItem.get_item_text(Index)
	
	GlobalSave.AddVarsToSettings("Languange","icon",Icon.resource_path)
	GlobalSave.AddVarsToSettings("Languange","lang",Lang)
	TranslationServer.set_locale(GlobalSave.LanguangeToLetters(Lang))
# warning-ignore:return_value_discarded
	
	if !first_run:
		get_tree().reload_current_scene()
		GlobalTime.call_deferred("emit_signal","NoAnimShowWindow","SettingsScreen")#.emit_signal("ShowOnlyScreen","SettingsScreen")
		GlobalSave.emit_signal("UpdateLanguange")
	

func _on_LangTexture_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Lang.ForceShowOnMouse(event.global_position)

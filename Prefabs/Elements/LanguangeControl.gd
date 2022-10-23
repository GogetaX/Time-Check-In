extends Panel


func _ready():
	InitLanguangeButton()
	SyncFromSave()
	
func InitLanguangeButton():
	for x in $Lang.get_children():
		if not x is Timer:
			x.connect("index_pressed",self,"SelectLang",[x])

func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("Languange")
	if S == null:
		return
	if S.has("icon"):
		$LangTexture.texture = load(S["icon"])
	
func SelectLang(Index,MenuItem):
	var Icon = MenuItem.get_item_icon(Index)
	$LangTexture.texture = Icon
	var Lang = MenuItem.get_item_text(Index)
	
	GlobalSave.AddVarsToSettings("Languange","icon",Icon.resource_path)
	GlobalSave.AddVarsToSettings("Languange","lang",Lang)
	TranslationServer.set_locale(GlobalSave.LanguangeToLetters(Lang))
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	GlobalTime.call_deferred("emit_signal","NoAnimShowWindow","SettingsScreen")#.emit_signal("ShowOnlyScreen","SettingsScreen")
	GlobalSave.emit_signal("UpdateLanguange")
	

func _on_LangTexture_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Lang.ForceShowOnMouse(event.global_position)

extends Panel

const SelectedColor = Color("#2699fb")
const NormalColor = Color(1,1,1,1)

func _ready():
	if !GlobalTheme.SavedColor:
		GlobalTheme.DefaultColors["StartBGColor"] = GetColor("res://Prefabs/Styles/Background_LightBlue.tres", "bg_color")
		GlobalTheme.DefaultColors["StartTotalBorderColor"] = GetColor("res://Prefabs/Styles/Panel/TotalItem.tres", "border_color")
		GlobalTheme.DefaultColors["StartSettingPanel"] = GetColor("res://Prefabs/Styles/Panel/SettingPanel.tres", "border_color")
		GlobalTheme.DefaultColors["StartSettingTitle"] = GetColor("res://Prefabs/Styles/Panel/SettingTitle.tres", "bg_color")
		GlobalTheme.DefaultColors["StartBottomBG"] = GetColor("res://Prefabs/Styles/Panel/BottomScreen.tres", "bg_color")
		GlobalTheme.DefaultColors["StartCalDayBG"] = GetColor("res://Prefabs/Styles/CalDay.tres", "bg_color")
		GlobalTheme.DefaultColors["StartCalDayBorder"] = GetColor("res://Prefabs/Styles/CalDay.tres", "border_color")
		GlobalTheme.DefaultColors["StartPopupScreenBG"] = GetColor("res://Prefabs/Styles/ModulatePopupScreen.tres", "bg_color")
		GlobalTheme.DefaultColors["StartPopupScreenBorder"] = GetColor("res://Prefabs/Styles/ModulatePopupScreen.tres", "border_color")
		GlobalTheme.DefaultColors["StartCurScreenPopup"] = GetColor("res://Prefabs/Styles/CurScreenIndicator.tres", "bg_color")
		GlobalTheme.SavedColor = true
		SyncFromSave()
	else:
		# Language change case
		var S = GlobalSave.GetValueFromSettingCategory("AppSettings")
		if S != null:
			if S.has("DarkMode"):
				if S["DarkMode"] == "Enable":
					$CanvasModulate.color = GlobalTheme.DarkColor
				else:
					$ToggleBetween.AnimToggle(false)

func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S == null:
		GlobalSave.AddVarsToSettings("AppSettings", "DarkMode", "Disable")
	S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S["DarkMode"] == "Disable":
		$ToggleBetween.AnimToggle(false)
	SyncTheme()

func FindSelected():
	for x in $VBoxContainer/HBoxContainer.get_children():
		if x.get("theme_override_colors/font_color") != NormalColor:
			return x
	return null

func AdjustThemeColor(ThemePath, color, invert = false):
	var inv = GlobalTheme.LoadResource(ThemePath)
	var T = create_tween()
	for x in color:
		if invert:
			var start_color = inv.get(x)
			var end_color = Color(1.0 - start_color.r, 1.0 - start_color.g, 1.0 - start_color.b, start_color.a)
			T.tween_property(inv, x, end_color, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		else:
			T.tween_property(inv, x, color[x], 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func CanvasModul(to_color):
	var T = create_tween()
	T.tween_property($CanvasModulate, "color", to_color, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func GetColor(ThemePath, color_path):
	return GlobalTheme.LoadResource(ThemePath).get(color_path)

func SyncTheme():
	var S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S["DarkMode"] == "Enable":
		AdjustThemeColor("res://Prefabs/Styles/Background_LightBlue.tres", {"bg_color": GlobalTheme.DefaultColors["StartBGColor"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/TotalItem.tres", {"border_color": GlobalTheme.DefaultColors["StartTotalBorderColor"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingPanel.tres", {"border_color": GlobalTheme.DefaultColors["StartSettingPanel"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingTitle.tres", {"bg_color": GlobalTheme.DefaultColors["StartSettingTitle"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/BottomScreen.tres", {"bg_color": GlobalTheme.DefaultColors["StartBottomBG"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres", {"bg_color": GlobalTheme.DefaultColors["StartCalDayBG"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres", {"border_color": GlobalTheme.DefaultColors["StartCalDayBorder"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres", {"bg_color": GlobalTheme.DefaultColors["StartPopupScreenBG"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres", {"border_color": GlobalTheme.DefaultColors["StartPopupScreenBorder"]}, true)
		AdjustThemeColor("res://Prefabs/Styles/CurScreenIndicator.tres", {"bg_color": GlobalTheme.DefaultColors["StartCurScreenPopup"]}, true)
		CanvasModul(GlobalTheme.DarkColor)
	else:
		AdjustThemeColor("res://Prefabs/Styles/Background_LightBlue.tres", {"bg_color": GlobalTheme.DefaultColors["StartBGColor"]})
		AdjustThemeColor("res://Prefabs/Styles/Panel/TotalItem.tres", {"border_color": GlobalTheme.DefaultColors["StartTotalBorderColor"]})
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingPanel.tres", {"border_color": GlobalTheme.DefaultColors["StartSettingPanel"]})
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingTitle.tres", {"bg_color": GlobalTheme.DefaultColors["StartSettingTitle"]})
		AdjustThemeColor("res://Prefabs/Styles/Panel/BottomScreen.tres", {"bg_color": GlobalTheme.DefaultColors["StartBottomBG"]})
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres", {"bg_color": GlobalTheme.DefaultColors["StartCalDayBG"]})
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres", {"border_color": GlobalTheme.DefaultColors["StartCalDayBorder"]})
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres", {"bg_color": GlobalTheme.DefaultColors["StartPopupScreenBG"]})
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres", {"border_color": GlobalTheme.DefaultColors["StartPopupScreenBorder"]})
		AdjustThemeColor("res://Prefabs/Styles/CurScreenIndicator.tres", {"bg_color": GlobalTheme.DefaultColors["StartCurScreenPopup"]})
		CanvasModul(Color(1,1,1,1))

func _on_ToggleBetween_OnToggle(val):
	if val:
		GlobalSave.AddVarsToSettings("AppSettings", "DarkMode", "Enable")
	else:
		GlobalSave.AddVarsToSettings("AppSettings", "DarkMode", "Disable")
	SyncTheme()

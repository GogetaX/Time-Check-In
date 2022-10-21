extends Panel

const SelectedColor = Color("#2699fb")
const NormalColor = Color(1,1,1,1)

var StartBGColor = null
var StartTotalBorderColor = null
var StartSettingPanel = null
var StartSettingTitle = null
var StartBottomBG = null
var StartCalDayBG = null
var StartCalDayBorder = null
var StartPopupScreenBG = null
var StartPopupScreenBorder = null

var DarkColor = Color(0.8,0.8,0.8,1.0)

func _ready():
	StartBGColor = GetColor("res://Prefabs/Styles/Background_LightBlue.tres","bg_color")
	StartTotalBorderColor = GetColor("res://Prefabs/Styles/Panel/TotalItem.tres","border_color")
	StartSettingPanel = GetColor("res://Prefabs/Styles/Panel/SettingPanel.tres","border_color")
	StartSettingTitle = GetColor("res://Prefabs/Styles/Panel/SettingTitle.tres","bg_color")
	StartBottomBG = GetColor("res://Prefabs/Styles/Panel/BottomScreen.tres","bg_color")
	StartCalDayBG = GetColor("res://Prefabs/Styles/CalDay.tres","bg_color")
	StartCalDayBorder = GetColor("res://Prefabs/Styles/CalDay.tres","border_color")
	StartPopupScreenBG = GetColor("res://Prefabs/Styles/ModulatePopupScreen.tres","bg_color")
	StartPopupScreenBorder = GetColor("res://Prefabs/Styles/ModulatePopupScreen.tres","border_color")
	SyncFromSave()
	
func SyncFromSave():
	var S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S == null:
		GlobalSave.AddVarsToSettings("AppSettings","DarkMode","Disable")
	S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S["DarkMode"] == "Disable":
		$ToggleBetween.AnimToggle(false)
	SyncTheme()
	
	
func FindSelected():
	for x in $VBoxContainer/HBoxContainer.get_children():
		if x.get("custom_colors/font_color") != NormalColor:
			return x
	return null
	
func FinishedShow(T):
	T.queue_free()
	
func AdjustThemeColor(ThemePath,color,invert = false):
	var inv = GlobalTheme.LoadResource(ThemePath)
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedShow",[T])
	for x in color:
		if invert:
			T.interpolate_property(inv,x,inv.get(x),Color(1.0-inv.get(x).r,1.0-inv.get(x).g,1.0-inv.get(x).b,inv.get(x).a),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		else:
			T.interpolate_property(inv,x,inv.get(x),color[x],0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	T.start()
	

func CanvasModul(to_color):
	var T = Tween.new()
	add_child(T)
	T.connect("tween_all_completed",self,"FinishedShow",[T])
	T.interpolate_property($CanvasModulate,"color",$CanvasModulate.color,to_color,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	T.start()
	
func GetColor(ThemePath,color_path):
	return GlobalTheme.LoadResource(ThemePath).get(color_path)
	
func SyncTheme():
	var S = GlobalSave.GetValueFromSettingCategory("AppSettings")
	if S["DarkMode"] == "Enable":
		AdjustThemeColor("res://Prefabs/Styles/Background_LightBlue.tres",{"bg_color":StartBGColor},true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/TotalItem.tres",{"border_color":StartTotalBorderColor},true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingPanel.tres",{"border_color":StartSettingPanel},true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingTitle.tres",{"bg_color":StartSettingTitle},true)
		AdjustThemeColor("res://Prefabs/Styles/Panel/BottomScreen.tres",{"bg_color":StartBottomBG},true)
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres",{"bg_color":StartCalDayBG},true)
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres",{"border_color":StartCalDayBorder},true)
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres",{"bg_color":StartPopupScreenBG},true)
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres",{"border_color":StartPopupScreenBorder},true)
		CanvasModul(DarkColor)
	else:
		AdjustThemeColor("res://Prefabs/Styles/Background_LightBlue.tres",{"bg_color":StartBGColor})
		AdjustThemeColor("res://Prefabs/Styles/Panel/TotalItem.tres",{"border_color":StartTotalBorderColor})
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingPanel.tres",{"border_color":StartSettingPanel})
		AdjustThemeColor("res://Prefabs/Styles/Panel/SettingTitle.tres",{"bg_color":StartSettingTitle})
		AdjustThemeColor("res://Prefabs/Styles/Panel/BottomScreen.tres",{"bg_color":StartBottomBG})
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres",{"bg_color":StartCalDayBG})
		AdjustThemeColor("res://Prefabs/Styles/CalDay.tres",{"border_color":StartCalDayBorder})
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres",{"bg_color":StartPopupScreenBG})
		AdjustThemeColor("res://Prefabs/Styles/ModulatePopupScreen.tres",{"border_color":StartPopupScreenBorder})
		CanvasModul(Color(1,1,1,1))
		
#


func _on_ToggleBetween_OnToggle(val):
	if val:
		GlobalSave.AddVarsToSettings("AppSettings","DarkMode","Enable")
	else:
		GlobalSave.AddVarsToSettings("AppSettings","DarkMode","Disable")
	SyncTheme()

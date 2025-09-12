extends Control

const SelectedColor = Color("#ffb326fb")
const UnSelectedColor = Color("#bce0fd")

var CurSelected = null
var FoundDateList = []

func _ready():
# warning-ignore:return_value_discarded
	GlobalTime.connect("ShowOnlyScreen", Callable(self, "ShowOnly"))
	InitButtons()
	$VBoxContainer/HBoxContainer2/SelectedMonthFirst.get_popup().connect("index_pressed", Callable(self, "SelectedFirstDate"))
	$VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().connect("index_pressed", Callable(self, "SelectedLastDate"))

	
func ShowOnly(ScreenName):
	if ScreenName != "ExporterScreen":
		return
	InitOptions()
	FastSelect("LastMonth")
	
	
func InitOptions():
	FoundDateList.clear()
	$VBoxContainer/HBoxContainer2/SelectedMonthFirst.get_popup().clear()
	$VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().clear()
	var FList = GlobalSave.GetAllDateFiles()
	var F = File.new()
	if FList != []:
		for x in FList:
			F.open(GlobalIosArrange.UserPath+x,File.READ)
			var d = F.get_var()
			for a in d:
				if d[a].has("check_in1"):
					FoundDateList.append(d[a]["check_in1"])
					break
			F.close()
	for x in FoundDateList:
		$VBoxContainer/HBoxContainer2/SelectedMonthFirst.get_popup().add_item(String(x["month"])+"."+String(x["year"]))
		
func SelectedFirstDate(Index):
	var DateSelectedFirst = $VBoxContainer/HBoxContainer2/SelectedMonthFirst.get_popup().get_item_text(Index)
	var DateSelectedLast = $VBoxContainer/HBoxContainer2/SelectedMonthLast.text
	$VBoxContainer/HBoxContainer2/SelectedMonthFirst.text = DateSelectedFirst
	#$VBoxContainer/HBoxContainer2/SelectedMonthLast.text = LastDateSelected
	$VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().clear()
	var DSplit = DateSelectedFirst.split(".")
	var DLastSplit = DateSelectedLast.split(".")
	var SelectedDateFirst = {}
	SelectedDateFirst["year"] = int(DSplit[1])
	SelectedDateFirst["month"] = int(DSplit[0])
	
	var SelectedDateLast = {}
	SelectedDateLast["year"] = int(DLastSplit[1])
	SelectedDateLast["month"] = int(DLastSplit[0])
	
	for x in FoundDateList:
		if x["year"]*x["year"] + x["month"] >= SelectedDateFirst["year"]*SelectedDateFirst["year"] + SelectedDateFirst["month"]:
			$VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().add_item(String(x["month"])+"."+String(x["year"]))
	if SelectedDateFirst["year"]*SelectedDateFirst["year"] + SelectedDateFirst["month"]>SelectedDateLast["year"]*SelectedDateLast["year"]+ SelectedDateLast["month"]:
		SelectedLastDate(0)
	
func SelectedLastDate(Index):
	var DateSelected = $VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().get_item_text(Index)
	$VBoxContainer/HBoxContainer2/SelectedMonthLast.text = DateSelected
	
func InitButtons():
	for x in $VBoxContainer/HBoxContainer.get_children():
		if x is Label:
			x.connect("gui_input", Callable(self, "MonthSelectorPressed").bind(x))
		
func MonthSelectorPressed(event,btn):
	if event is InputEventMouseButton:
		if event.pressed:
			var T = Tween.new()
			add_child(T)
			T.connect("tween_all_completed", Callable(self, "FinishTween").bind(T,btn))
			T.interpolate_property(btn,"theme_override_colors/font_color",btn.get("theme_override_colors/font_color"),SelectedColor,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			if CurSelected != null:
				T.interpolate_property(CurSelected,"theme_override_colors/font_color",CurSelected.get("theme_override_colors/font_color"),UnSelectedColor,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			T.start()
			
func FinishTween(T,new_btn):
	T.queue_free()
	CurSelected = new_btn
	SyncDates()
	
func GetFirstMonth():
	var t = $VBoxContainer/HBoxContainer2/SelectedMonthFirst.text.split(".")
	return {"month":int(t[0]),"year":int(t[1])}
	
func GetLastMonth():
	var t = $VBoxContainer/HBoxContainer2/SelectedMonthLast.text.split(".")
	return {"month":int(t[0]),"year":int(t[1])}
	
func FastSelect(lbl_name):
	CurSelected = null
	for x in $VBoxContainer/HBoxContainer.get_children():
		if x.name ==lbl_name:
			x.set("theme_override_colors/font_color",SelectedColor)
			CurSelected = x
		else:
			x.set("theme_override_colors/font_color",UnSelectedColor) 
	SyncDates()

func SyncDates():
	var CurDate = Time.get_datetime_dict_from_system()
	var FromDate = {}
	var ToDate = {}
	match CurSelected.name:
		"LastMonth":
			CurDate["month"]-=1
			if CurDate["month"] <=0:
				CurDate["month"] = 12
				CurDate["year"] -= 1
			FromDate = CurDate
			ToDate = CurDate
		"ThisMonth":
			FromDate = CurDate
			ToDate = CurDate
		"Last3Months":
			CurDate["month"]-=1
			if CurDate["month"] <=0:
				CurDate["month"] = 12
				CurDate["year"] -= 1
			ToDate = CurDate.duplicate()
			CurDate["month"]-=3
			if CurDate["month"] <=0:
				CurDate["month"] = 12+CurDate["month"]
				CurDate["year"] -= 1
			FromDate = CurDate
		_:
			print("Erorr TimePeriodSelector->SyncDates() date does not found: ",CurSelected.name)
	$VBoxContainer/HBoxContainer2/SelectedMonthFirst.text = String(FromDate["month"])+"."+String(FromDate["year"])
	$VBoxContainer/HBoxContainer2/SelectedMonthLast.text = String(ToDate["month"])+"."+String(ToDate["year"])


	for x in FoundDateList:
		if x["year"]*x["year"] + x["month"] >= ToDate["year"]*ToDate["year"] + ToDate["month"]:
			$VBoxContainer/HBoxContainer2/SelectedMonthLast.get_popup().add_item(String(x["month"])+"."+String(x["year"]))

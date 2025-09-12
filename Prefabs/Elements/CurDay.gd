extends Label

# Reference to CurMonth node; adjust the path based on your scene structure
@onready var CurMonth = get_node_or_null("/root/MainScene/TopMenu/CurMonth")

func _ready():
	# Check if CurMonth was found
	if CurMonth == null:
		print("Warning: CurMonth node not found.")
	
	var CurDate = Time.get_datetime_dict_from_system()
	GlobalTime.connect("SelectDay", Callable(self, "SelectedDay"))
	# Set initial text using str() for string conversion
	text = TranslationServer.translate("Today") + " " + str(CurDate["day"]) + " " + GlobalTime.GetMonthName(CurDate["month"])[0] + " " + str(CurDate["year"])

func SelectedDay(_DayNode):
	var DayDescription = ""
	var CurDate = Time.get_datetime_dict_from_system()
	var selected = GlobalTime.CurSelectedDate
	var today = CurDate

	# Calculate differences for cleaner logic
	var day_diff = selected["day"] - today["day"]
	var month_diff = selected["month"] - today["month"]
	var year_diff = selected["year"] - today["year"]

	# Determine relative description based on differences
	if year_diff == 0 and month_diff == 0 and day_diff == 0:
		DayDescription = TranslationServer.translate("Today") + " "
	elif year_diff == 0 and month_diff == 0 and day_diff == 1:
		DayDescription = TranslationServer.translate("Tomorrow") + " "
	elif year_diff == 0 and month_diff == 0 and day_diff == -1:
		DayDescription = TranslationServer.translate("Yesterday") + " "
	elif year_diff == 0 and month_diff == 0:
		DayDescription = TranslationServer.translate("This month") + " "
	elif year_diff == 0 and month_diff == 1:
		DayDescription = TranslationServer.translate("Next month") + " "
	elif year_diff == 0 and month_diff == -1:
		DayDescription = TranslationServer.translate("Last month") + " "
	elif year_diff == 0:
		DayDescription = TranslationServer.translate("This year") + " "
	elif year_diff == 1:
		DayDescription = TranslationServer.translate("Next year") + " "
	elif year_diff == -1:
		DayDescription = TranslationServer.translate("Last year") + " "
	else:
		DayDescription = ""  # Default for dates more than a year apart

	# Update label text with selected date
	text = DayDescription + str(selected["day"]) + " " + GlobalTime.GetMonthName(selected["month"])[0] + " " + str(selected["year"])

extends Control


const SelectedColor = Color("#fbffb326")
const UnSelectedColor = Color("#bce0fd")

var CurSelected = null


func _ready():
	FastSelect("csv")

func FastSelect(lbl_name):
	CurSelected = null
	for x in $HBoxContainer.get_children():
		if x.name ==lbl_name:
			x.set("custom_colors/font_color",SelectedColor)
			CurSelected = x
		else:
			x.set("custom_colors/font_color",UnSelectedColor) 

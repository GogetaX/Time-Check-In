extends Control

func _ready():
	#GlobalTime.connect("BtnGroupPressed",self,"BtnGroupPressed")
	LoadData(6,2022,12)
	
func LoadData(Month,Year,Day):
	var Res = GlobalSave.LoadSpecificFile(Month,Year)
	for x in Res:
		if x == Day:
			$RichTextLabel.text += String(Res[x])

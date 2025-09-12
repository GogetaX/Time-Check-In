extends RichTextLabel

var HebrewDB = "קראטוןםפשדגכעיחלךףזסבהנמצתץ"

func _ready():
	text = TranslationServer.translate(text)
	#connect("draw",self,"SyncLang")

func SyncLang():
	var t = get_text().split("\n")
	print("Before:")
	var MaxLineWidth = 10
	print(t)
	var res = ""
	var non_hebrew = false
	var output = []
	for Line in range(t.size(),0,-1):
		if t[Line-1].length() > MaxLineWidth:
			MaxLineWidth = t[Line-1].length()-10
			
		for Letter in range(t[Line-1].length()):
			if FindIfHebrew(t[Line-1][Letter]):
				if non_hebrew && res.length()>0:
					output.append([Line-1,res])
					res = ""
					non_hebrew = false
				res = t[Line-1][Letter] + res
			elif t[Line-1][Letter] == " ":
				if res.length()>0:
					output.append([Line-1,res])
				output.append([Line-1," "])
				res = ""
				non_hebrew = false
			else:
				if res.length()>0:
					output.append([Line-1,res])
					res = ""
				res = res + t[Line-1][Letter]
				non_hebrew = true
		if res.length()>0:
			output.append([0,res])
			res = ""
		res = ""
	print("After:")
	#print(output)
	res = ""
	text = "[right]"
	var tot_lines = 0
	for Line in range(t.size()):
		for x in output:
			if x[0] == Line:
				text = x[1] + text
				tot_lines += x[1].length()
				if tot_lines >= MaxLineWidth:
					text += "\n"
					tot_lines = 0
	return

func FindIfHebrew(t):
	for x in HebrewDB.length():
		if t == HebrewDB[x]:
			return true
	return false


func _on_Button_pressed():
	SyncLang()

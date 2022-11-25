tool
extends Panel
var InfoIsPressed = false
var LastMousePos = Vector2()

export (String) var CategoryText = "Category" setget SetCategoryText
export (String,MULTILINE) var PanelInfo = "" setget SetPanelInfo
export (Texture) var Icon = null setget SetTexture

func _ready():
	if PanelInfo == "":
		$Info.visible = false
	else:
		$Info.visible = true
	
	if Icon == null:
		$Icon.visible = false
	else:
		$Icon.texture = Icon
		
func SetTexture(new):
	Icon = new
	
func SetPanelInfo(new):
	PanelInfo = new
	if PanelInfo == "":
		$Info.visible = false
	else:
		$Info.visible = true
	
func SetCategoryText(new):
	CategoryText = new
	$Label.text = CategoryText


func _on_Info_gui_input(event):
	if !$Info.visible: return
	if event is InputEventMouseButton:
		if event.pressed:
			InfoIsPressed = true
			LastMousePos = event.position
		if !event.pressed && InfoIsPressed:
			if abs(event.position.distance_to(LastMousePos))<=10:
				var d = {"type": "ok","Title":CategoryText,"Desc":TranslationServer.translate(PanelInfo)}
				GlobalTime.ShowPopup(d)
				InfoIsPressed = false
			

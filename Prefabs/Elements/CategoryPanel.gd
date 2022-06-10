tool
extends Panel

export (String) var CategoryText = "Category" setget SetCategoryText


func SetCategoryText(new):
	CategoryText = new
	$Label.text = CategoryText

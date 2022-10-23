extends Node

const DarkColor = Color(0.8,0.8,0.8,1.0)

var Loaded = {}
var SavedColor = false
var DefaultColors = {}


func LoadResource(ResPath):
	if !Loaded.has(ResPath):
		Loaded[ResPath] = ResourceLoader.load(ResPath)
	return Loaded[ResPath]

func ClearSave():
	Loaded = {}

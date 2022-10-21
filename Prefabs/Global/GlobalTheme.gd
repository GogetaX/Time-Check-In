extends Node

var Loaded = {}

func LoadResource(ResPath):
	if !Loaded.has(ResPath):
		Loaded[ResPath] = ResourceLoader.load(ResPath)
	return Loaded[ResPath]

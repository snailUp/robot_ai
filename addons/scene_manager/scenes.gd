#
# Please do not edit anything in this script
#
# Just use the editor to change everything you want
#
extends Node

var scenes: Dictionary = {
	"_auto_refresh": true,
	"_auto_save": false,
	"_ignore_list": ["res://addons"],
	"_ignores_visible": true,
	"_sections": ["Scenes"],
	
	"entry": {
		"sections": ["Scenes"],
		"settings": {
			"All": {"subsection": "", "visibility": true},
			"Scenes": {"subsection": "", "visibility": true}
		},
		"value": "res://framecore/entry.tscn"
	},
	
	"login": {
		"sections": ["Scenes"],
		"settings": {
			"All": {"subsection": "", "visibility": true},
			"Scenes": {"subsection": "", "visibility": true}
		},
		"value": "res://resources/ui/login/UILoginPanel.tscn"
	},
	
	"sample": {
		"sections": ["Scenes"],
		"settings": {
			"All": {"subsection": "", "visibility": true},
			"Scenes": {"subsection": "", "visibility": true}
		},
		"value": "res://resources/ui/sample/UISamplePanel.tscn"
	},
	
	"level_map": {
		"sections": ["Scenes"],
		"settings": {
			"All": {"subsection": "", "visibility": true},
			"Scenes": {"subsection": "", "visibility": true}
		},
		"value": "res://resources/map/level/LevelMapScene.tscn"
	}
}

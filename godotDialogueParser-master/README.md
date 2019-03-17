# godot Dialogue Parser

a simple dialogue parser made on godot.

Comes with a [WIP] demo story (in portuguese-br).

the parser expects a JSON file with the format:  
{  
	"events" : {  
		"event1" : {  
			"value" : false,  
			"scene" : {  
				"field to modify" : "value"  
			}  
		}  
	},  
	"variables" : {  
		"variable" : "value"  
	},  
	"scene" : {  
		"background" {  
			"default" : "path to image" (this will be loaded when the scene begins)  
		},  
		"images" : {  
			"img1" : "path to img1"  
		},  
		"current" : "current dialogue branch",  
		"dialogue branch 1" : {  
			"text" : "something here",  
			"speaker" : "name of the character", (optional)  
			"image" : "img1", (optional)  
			"background" : "another background", (optional)  
			"write" : "variable", (optional - will prompt a input field)  	
			"next" : "next branch",  
			"options" : [         (alternative to next - will prompt buttons)  
				{  
					"text" : "option1",  
					"next" : "next branch"  
				}  
			],  
			"isEnd" : true [when the dialogue end]  
		}  
		"dialog branch 2" : {  
			...
		}  
	},  
	"scene2" : {  
		...  
	}  
}	

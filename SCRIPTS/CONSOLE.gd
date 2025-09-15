extends RichTextLabel

func _ready():
	Globals.console = self
	append_text("[Console Initialized]\n")

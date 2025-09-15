extends Node
var console: RichTextLabel = null

var buildMode: bool = false

func log(msg: String):
	if console:
		console.append_text(msg + "\n")
		console.scroll_to_line(console.get_line_count())

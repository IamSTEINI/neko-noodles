extends FoldableContainer

func _ready() -> void:
	if not is_connected("folding_changed", Callable(self, "_on_folding_changed")):
		connect("folding_changed", Callable(self, "_on_folding_changed"))

	_update_state(false)

func _on_folding_changed(is_folded: bool) -> void:
	_update_state(is_folded)

func _update_state(is_folded: bool) -> void:
	if folded:
		$ScrollContainer.visible = false
		self.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	else:
		$ScrollContainer.visible = true
		self.size_flags_vertical = Control.SIZE_EXPAND_FILL

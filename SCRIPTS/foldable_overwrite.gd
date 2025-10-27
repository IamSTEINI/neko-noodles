extends FoldableContainer

func _ready() -> void:
	if not is_connected("folding_changed", Callable(self, "_on_folding_changed")):
		connect("folding_changed", Callable(self, "_on_folding_changed"))

	_update_state(true, true)

func _on_folding_changed(is_self_folded: bool) -> void:
	_update_state(is_self_folded, false)

func _update_state(is_self_folded: bool, main_ex: bool) -> void:
	if !main_ex:
		$"../../../../../../../../Click".play()
	if is_self_folded:
		$ScrollContainer.visible = false
		self.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	else:
		$ScrollContainer.visible = true
		self.size_flags_vertical = Control.SIZE_EXPAND_FILL

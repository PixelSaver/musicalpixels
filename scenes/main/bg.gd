extends ColorRect

func _process(_delta: float) -> void:
	self.modulate = Global.global_settings.background

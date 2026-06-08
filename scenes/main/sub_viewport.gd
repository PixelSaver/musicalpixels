extends SubViewport

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

func _on_viewport_resized():
	size = get_viewport().get_visible_rect().size

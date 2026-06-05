extends Node2D
class_name VisualizerClass

@onready var miniaudio = MiniaudioClass.new()

func _ready() -> void:
	add_child(miniaudio)
	miniaudio.start()

func begin_visualization() -> void:
	pass
func end_visualization() -> void:
	pass

func _process(delta: float) -> void:
	handle_visualization(miniaudio.get_samples(), delta)

func handle_visualization(samples:PackedFloat32Array, delta:float) -> void:
	pass

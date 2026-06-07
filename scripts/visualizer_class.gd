extends Node2D
class_name VisualizerClass

@export var settings:VisualizerSettings

func _ready() -> void:
	Global.sensitivity_delta.connect(func(del:float):
		settings.sensitivity += del
	)

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	push_error("Override function to return id")
	return -1

## Function called once the visualization is chosen
func begin_visualization() -> void:
	pass
func end_visualization() -> void:
	queue_free()

func handle_visualization(
	_miniaudio:MiniaudioClass, 
	_samples:PackedFloat32Array, 
	_delta:float
) -> void:
	pass

extends Node2D
class_name VisualizerClass

## Function called once the visualization is chosen
func begin_visualization() -> void:
	pass
func end_visualization() -> void:
	pass

func handle_visualization(_miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	pass

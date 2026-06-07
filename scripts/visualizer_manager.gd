extends Node2D
class_name VisualizerManager

@onready var miniaudio = MiniaudioClass.new()
@export var visualizer : VisualizerClass

func _ready() -> void:
	Global.current_visualizer = visualizer
	add_child(miniaudio)
	miniaudio.start()

func switch_to_visualizer(id:VisualizerDatabase.VisualizerID):
	pass

func _process(delta: float) -> void:
	var vis := Global.current_visualizer
	if vis == null: return
	vis.handle_visualization(miniaudio, miniaudio.get_samples(), delta)

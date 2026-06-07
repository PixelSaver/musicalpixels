extends Node2D
class_name VisualizerManager

@onready var miniaudio = MiniaudioClass.new()
@export var visualizer_chosen : VisualizerDatabase.VisualizerID  :
	set(id):
		switch_to_visualizer(id)
		visualizer_chosen = id
@export var visualizer : VisualizerClass

func _ready() -> void:
	add_child(miniaudio)
	miniaudio.start()
	switch_to_visualizer(visualizer_chosen)

func switch_to_visualizer(id:VisualizerDatabase.VisualizerID):
	if Global.current_visualizer != null:
		if Global.current_visualizer.get_visualizer_id() == id: return
		Global.current_visualizer.end_visualization()
	var inst := VisualizerDatabase.get_instantiated_scene(id)
	add_child(inst)
	Global.current_visualizer = inst
	inst.begin_visualization()

func _process(delta: float) -> void:
	var vis := Global.current_visualizer
	if vis == null: return
	vis.handle_visualization(miniaudio, miniaudio.get_samples(), delta)

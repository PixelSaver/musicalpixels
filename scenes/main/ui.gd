#@tool
extends Control
class_name UI
@onready var option_button: OptionButton = $OptionButton
var countdown = 4.0
var countdown_max = 4.0

func _ready() -> void:
	#option_button.clear()
	#for item in VisualizerDatabase.VISUALIZERS.keys():
		#option_button.add_item(str(item), item)
	option_button.item_selected.connect(func(idx):
		Global.switch_to_visualizer.emit(idx)
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		self.modulate.a = 1.0
		countdown = countdown_max
	if event.is_action_pressed("scroll_up"):
		Global.sensitivity_delta.emit(1.0)
		print("Sense up")
	if event.is_action_pressed("scroll_down"):
		Global.sensitivity_delta.emit(-1.0)
		print("Sense down")

func _process(delta: float) -> void:
	countdown -= delta
	if countdown < 0:
		self.modulate.a = clamp(lerp(modulate.a, 0., 0.1), 0.0, 1.0)

#@tool
extends Control
class_name UI
@onready var option_button: OptionButton = $OptionButton
@onready var color_picker: ColorPickerButton = $ColorPickerButton
var countdown = 4.0
var countdown_max = 4.0

func _ready() -> void:
	option_button.item_selected.connect(func(idx):
		Global.switch_to_visualizer.emit(idx)
	)
	color_picker.color_changed.connect(func(color:Color):
		Global.global_settings.background = color
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

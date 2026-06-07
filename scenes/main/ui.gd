#@tool
extends Control
class_name UI
@onready var option_button: OptionButton = $OptionButton

func _ready() -> void:
	#option_button.clear()
	#for item in VisualizerDatabase.VISUALIZERS.keys():
		#option_button.add_item(str(item), item)
	option_button.item_selected.connect(func(idx):
		Global.switch_to_visualizer.emit(idx)
	)

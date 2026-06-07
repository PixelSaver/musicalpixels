extends Node


var current_visualizer: VisualizerClass = null
signal switch_to_visualizer(id:VisualizerDatabase.VisualizerID)

signal sensitivity_delta(delta:float)

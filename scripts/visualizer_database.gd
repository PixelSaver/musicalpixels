extends Node

enum VisualizerID {
	LINE_AMP,
	SIMPLE_AMP,
	CIRCLE_FFT,
	SIMPLE_FFT,
	SKEW_FFT,
	MESH_FFT,
	MULTIMESH_FFT,
	RINGS_FFT,
	SPHERE_FFT,
	ARCS_FFT,
	ARCS_MESH_FFT,
}
const VISUALIZERS := {
	VisualizerID.LINE_AMP:
		preload("res://scenes/visualizers/amplitude/line_amp_v.tscn"),
	VisualizerID.SIMPLE_AMP:
		preload("res://scenes/visualizers/amplitude/simple_amp_v.tscn"),
	VisualizerID.CIRCLE_FFT:
		preload("res://scenes/visualizers/circle_fft_v.tscn"),
	VisualizerID.SIMPLE_FFT:
		preload("res://scenes/visualizers/simple_fft_v.tscn"),
	VisualizerID.SKEW_FFT:
		preload("res://scenes/visualizers/skew_fft_v.tscn"),
	VisualizerID.MESH_FFT:
		preload("res://scenes/visualizers/mesh_fft/mesh_fft_v.tscn"),
	VisualizerID.MULTIMESH_FFT:
		preload("res://scenes/visualizers/mesh_fft/multimesh_fft_v.tscn"),
	VisualizerID.RINGS_FFT:
		preload("res://scenes/visualizers/mesh_fft/rings_fft_v.tscn"),
	VisualizerID.SPHERE_FFT:
		preload("res://scenes/visualizers/mesh_fft/sphere_fft_v.tscn"),
	VisualizerID.ARCS_FFT:
		preload("res://scenes/visualizers/arcs_fft_v.tscn"),
	VisualizerID.ARCS_MESH_FFT:
		preload("res://scenes/visualizers/mesh_fft/arcs_mesh_fft_v.tscn"),
}

func get_random_id() -> VisualizerID:
	return VISUALIZERS.keys().pick_random()
func get_random_visualizer() -> VisualizerClass:
	return self.get_instantiated_scene(get_random_id())
func get_scene(id:VisualizerID):
	return VISUALIZERS[id]
func get_instantiated_scene(id:VisualizerID) -> VisualizerClass:
	return VISUALIZERS[id].instantiate() as VisualizerClass
	

extends VisualizerClass
class_name MultiMeshFFTVisualizer

@onready var mm_inst: MultiMeshInstance3D = $MultiMeshInstance3D
@export var mm_shader : Shader
@export var low_cut := 80.0
@export var high_cut := 24000.0
@export var num_bars  := 32
@export var fft_size := 1024
@export var bar_width := 16
@export var max_height := 400.0
@export var noise_level := 1.0
@export var noise : NoiseTexture2D
@export var h_gradient : GradientTexture1D

@export var sample_rate := 48000.0

@export var rings := 10
@export var points := 400
var max_energy := 0.0;
var mm : MultiMesh

var fft_img : Image
var fft_tex : ImageTexture

var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.MULTIMESH_FFT
func _init() -> void:
	
	RenderingServer.set_debug_generate_wireframes(true)

func _ready() -> void:
	var sp = SphereMesh.new()
	sp.radius = .5
	sp.height = 1.
	var sm = ShaderMaterial.new()
	sm.shader = mm_shader
	sp.material = sm
	mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.instance_count = rings * points
	mm.mesh = sp
	mm_inst.multimesh = mm
	
	for i in mm.instance_count:
		mm.set_instance_transform(
			i,
			Transform3D()
		)
	var idx = 0
	for r in range(rings):
		for p in range(points):
			mm.set_instance_transform(idx, Transform3D())
			var ring_t = float(r) / float(rings)
			var point_t = float(p) / float(points)
			mm.set_instance_custom_data(idx, Color(
				ring_t,
				point_t,
				0.0,
				1.0
			))
			idx += 1
	
	bar_heights.resize(num_bars)
	bar_heights.fill(0.0)
	fft_img = Image.create(num_bars, 1, false, Image.FORMAT_RF)
	fft_tex = ImageTexture.create_from_image(fft_img)
	
	#var mesh_mat = mesh.material_override as ShaderMaterial
	sm.set_shader_parameter("gradient", h_gradient)
	sm.set_shader_parameter("data_tex", fft_tex)
	sm.set_shader_parameter("noise_tex", noise)
	sm.set_shader_parameter("noise_level", noise_level)
	sm.set_shader_parameter("rings", rings)
	sm.set_shader_parameter("points", points)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(fft_size, true, true, 0)
	if spectrum.size() == 0:
		return

	for b in range(num_bars):
		var t1 = float(b) / num_bars
		var t2 = float(b + 1) / num_bars

		var nyquist := sample_rate * 0.5
		var f_min := low_cut * pow(high_cut / low_cut, t1)
		var f_max := low_cut * pow(high_cut / low_cut, t2)
		

		var energy := FFTHelper.get_band_energy(
			spectrum,
			fft_size,
			f_min,
			f_max,
			sample_rate,
		)
		#energy = pow(max(0.0, energy - 0.1), 1.5)

		#var target = clamp(energy * 5.0, 0.0, 1.0) * max_height
		var target = pow(energy * 0.2, 0.3) * max_height * 0.8

		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)
	max_energy = bar_heights.max()
	mm.mesh.material.set_shader_parameter("max_energy", max_energy)
	_update_fft_tex()

func _update_fft_tex() -> void:
	for i in range(num_bars):
		var v = clamp(bar_heights[i] / max_height, 0.0, 1.0)
		fft_img.set_pixel(i, 0, Color(v,0,0))
	#fft_tex = ImageTexture.create_from_image(fft_img)
	fft_tex.update(fft_img)

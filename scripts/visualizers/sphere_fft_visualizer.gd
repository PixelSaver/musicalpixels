extends VisualizerClass
class_name SphereFFTVisualizer

@onready var mesh: MeshFFT = $Mesh

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

var fft_img : Image
var fft_tex : ImageTexture

var bar_heights: Array[float] = []

func _init() -> void:
	
	RenderingServer.set_debug_generate_wireframes(true)

func _ready() -> void:
	
	bar_heights.resize(num_bars)
	bar_heights.fill(0.0)
	fft_img = Image.create(num_bars, 1, false, Image.FORMAT_RF)
	fft_tex = ImageTexture.create_from_image(fft_img)
	
	var mesh_mat = mesh.material_override as ShaderMaterial
	mesh_mat.set_shader_parameter("data_tex", fft_tex)
	mesh_mat.set_shader_parameter("data_size", float(num_bars))
	mesh_mat.set_shader_parameter("noise_level", noise_level)
	mesh_mat.set_shader_parameter("noise_tex", noise)
	mesh_mat.set_shader_parameter("gradient", h_gradient)

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
	mesh.material_override.set_shader_parameter("max_energy", bar_heights.max())

	_update_fft_tex()

func _update_fft_tex() -> void:
	for i in range(num_bars):
		var v = clamp(bar_heights[i] / max_height, 0.0, 1.0)
		fft_img.set_pixel(i, 0, Color(v,0,0))
	#fft_tex = ImageTexture.create_from_image(fft_img)
	fft_tex.update(fft_img)

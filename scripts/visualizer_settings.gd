extends Resource
class_name VisualizerSettings

@export_category("General")
@export var low_cut := 80.0
@export var high_cut := 24000.0
@export_range(4, 100, 1) var num_bars := 32
@export var fft_size : FFTHelper.Sizes = FFTHelper.Sizes.HIGH
@export var width := 16
@export var max_height := 400.0
@export var radius := 50.
@export var noise_level := 1.0
@export var noise : NoiseTexture2D
@export var noise_func : FastNoiseLite
@export var gradient : GradientTexture1D
@export var smoothing := 0.15
@export var sample_rate := 48000.
@export var sensitivity : float = 0. :
	set(val):
		sensitivity = clampf(val, -50., 50.)
func get_sensitivity_value() -> float: return exp(sensitivity)

func _init() -> void:
	noise = NoiseTexture2D.new()
	noise_func = FastNoiseLite.new()
	noise_func.seed = randi()
	noise.noise = noise_func

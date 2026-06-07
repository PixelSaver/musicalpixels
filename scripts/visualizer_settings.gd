extends Resource
class_name VisualizerSettings

@export_category("General")
@export var low_cut := 80.0
@export var high_cut := 24000.0
@export_range(4, 100, 1) var num_bars := 32
@export var fft_size : FFTHelper.Sizes = 1024
@export var bar_width := 16
@export var max_height := 400.0
@export var noise_level := 1.0
@export var noise : NoiseTexture2D
@export var gradient : GradientTexture1D
@export var smoothing := 0.15

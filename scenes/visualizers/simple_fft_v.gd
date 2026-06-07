extends VisualizerClass
class_name SimpleFFTVisualizer

@export var num_bars  := 64
@export var fft_size := 8192
@export var bar_width := 20
@export var max_height := 400.0
@export var gradient : GradientTexture1D
@export var sample_rate := 48000.0

var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.SIMPLE_FFT
func _ready() -> void:
	bar_heights.resize(num_bars)
	bar_heights.fill(0.0)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(fft_size, true, true, 0)
	if spectrum.size() == 0:
		return

	for b in range(num_bars):
		var t1 = float(b) / num_bars
		var t2 = float(b + 1) / num_bars

		var nyquist := sample_rate * 0.5
		var f_min := 20.0 * pow(nyquist / 20.0, t1)
		var f_max := 20.0 * pow(nyquist / 20.0, t2)
		

		var energy := FFTHelper.get_band_energy(
			spectrum,
			fft_size,
			f_min,
			f_max,
			sample_rate,
		)
		
		var target = log(energy * 5. * max_height + 1.0) * 45
		#var target = pow(energy * 0.2, 0.2) * max_height * 0.8
		#var target = log(energy * max_height + 1.0) * 100
		
		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)

	queue_redraw()

func _draw() -> void:
	if bar_heights.size() == 0: return
	var viewport_size = get_viewport_rect().size
	var total_width = num_bars * bar_width
	var origin_x = (viewport_size.x - total_width) / 2.0
	var origin_y = viewport_size.y / 2.0

	for b in range(num_bars):
		var h = max(bar_heights[b], 0.0)
		if h <= 2: continue
		var x = origin_x + b * bar_width
		draw_rect(Rect2(x, origin_y - h, bar_width - 2, h), gradient.gradient.sample(b/float(num_bars)))
		draw_rect(Rect2(x, origin_y, bar_width - 2, h), gradient.gradient.sample(b/float(num_bars)))

extends VisualizerClass
class_name SimpleFFTVisualizer

var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.SIMPLE_FFT
func _ready() -> void:
	bar_heights.resize(settings.num_bars)
	bar_heights.fill(0.0)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(settings.fft_size, true, true, 0)
	if spectrum.size() == 0:
		return
	
	for b in range(settings.num_bars):
		var t1 = float(b) / settings.num_bars
		var t2 = float(b + 1) / settings.num_bars
		var f_min := settings.low_cut * pow(settings.high_cut / settings.low_cut, t1)
		var f_max := settings.low_cut * pow(settings.high_cut / settings.low_cut, t2)
		
		var energy := FFTHelper.get_band_energy(
			spectrum,
			settings.fft_size,
			f_min,
			f_max,
			settings.sample_rate,
		)
		
		var target = log(energy * 5. * settings.max_height + 1.0) *\
			45 * settings.get_sensitivity_value()
		#var target = pow(energy * 0.2, 0.2) * max_height * 0.8
		#var target = log(energy * max_height + 1.0) * 100
		
		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)
	
	queue_redraw()

func _draw() -> void:
	if bar_heights.size() == 0: return
	var viewport_size = get_viewport_rect().size
	var total_width = settings.num_bars * settings.width
	var origin_x = (viewport_size.x - total_width) / 2.0
	var origin_y = viewport_size.y / 2.0

	for b in range(settings.num_bars):
		var h = max(bar_heights[b], 0.0)
		if h <= 2: continue
		var x = origin_x + b * settings.width
		draw_rect(Rect2(x, origin_y - h, settings.width - 2, h), settings.gradient.gradient.sample(b/float(settings.num_bars)))
		draw_rect(Rect2(x, origin_y, settings.width - 2, h), settings.gradient.gradient.sample(b/float(settings.num_bars)))

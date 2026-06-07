extends VisualizerClass
class_name CircleFFTVisualizer
#radius=400
var offset := 0.0
var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.CIRCLE_FFT
func _ready() -> void:
	bar_heights.resize(settings.num_bars)
	bar_heights.fill(0.0)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, delta:float) -> void:
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
		
		var target = clamp(energy * 5.0, 0.0, 1.0) * settings.max_height * settings.get_sensitivity_value()
		target = log(target+1.0)/log(10) * 100
		
		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)
		
		var smoothed: Array[float] = []
		smoothed.resize(settings.num_bars)
		
		for i in range(settings.num_bars):
			var prev = bar_heights[(i - 1 + settings.num_bars) % settings.num_bars]
			var curr = bar_heights[i]
			var next = bar_heights[(i + 1) % settings.num_bars]
			
			smoothed[i] = (
				prev * 0.005 +
				curr * 0.99 +
				next * 0.005
			)
			
		bar_heights = smoothed
		
	offset += delta * 10. / bar_heights.max()
	

	queue_redraw()

func _draw() -> void:
	if bar_heights.size() == 0: return
	var origin = get_viewport_rect().size / 2.0
	var theta = 2 * PI / settings.num_bars

	for b in range(settings.num_bars):
		var vec = Vector2.UP.rotated(offset + theta*b)
		var pos = vec * settings.radius + origin
		var h = bar_heights[b]
		#var color = Color.from_hsv(float(b) / num_bars, 0.8, 0.9)
		var color = Color.WHITE
		draw_line(pos-vec*h*0.5, pos + vec * h*0.5, color, 10)

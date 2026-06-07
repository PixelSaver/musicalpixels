extends VisualizerClass
class_name SkewFFTVisualizer

@export var num_bars  := 64
@export var fft_size := 8192
@export var bar_width := 20
@export var max_height := 400.0

@export var sample_rate := 48000.0

var bar_heights: Array[float] = []


func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.SKEW_FFT
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

		var target = energy * 5.0 * max_height
		target = log(target+1.0)/log(10) * 100

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
		var h = bar_heights[b]
		if h <= 1: continue
		var x = origin_x + b * bar_width
		var color = Color.from_hsv(remap(float(b) / num_bars, 0.0, 1.0, 0.4, 0.7), 0.8, 0.9)
		#var color = Color.WHITE
		draw_colored_polygon(
			PackedVector2Array([
					Vector2(x, origin_y),          # bottom-left
					Vector2(x + bar_width, origin_y),     # bottom-right
					Vector2(x + bar_width, origin_y - h),                # top-right
					Vector2(x, origin_y - h),                    # top-left
				]),
			color
		)
		var skew = 1.2 * h*0.5
		draw_colored_polygon(
			PackedVector2Array([
					Vector2(x - skew, (origin_y + h*0.5)),          # bottom-left
					Vector2(x + bar_width - skew, (origin_y + h*0.5)),     # bottom-right
					Vector2(x + bar_width, origin_y),                # top-right
					Vector2(x, origin_y),                    # top-left
				]),
			color * Color(1,1,1,0.7)
		)

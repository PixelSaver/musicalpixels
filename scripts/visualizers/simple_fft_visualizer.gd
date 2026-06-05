extends VisualizerClass
class_name SimpleFFTVisualizer

@export var NUM_BARS  := 64
@export var FFT_SIZE  := 8192
@export var BAR_WIDTH := 16
@export var MAX_HEIGHT := 400.0

var bar_heights: Array[float] = []

func _ready() -> void:
	bar_heights.resize(NUM_BARS)
	bar_heights.fill(0.0)

func handle_visualization(miniaudio:MiniaudioClass, samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(FFT_SIZE, true, true, 0)
	if spectrum.size() == 0:
		return

	var freq_bins = FFT_SIZE / 2.

	for b in range(NUM_BARS):
		var t1 = float(b) / NUM_BARS
		var t2 = float(b + 1) / NUM_BARS

		var start_bin = max(1, int(pow(t1, 2.0) * freq_bins))
		var end_bin   = max(start_bin + 1, int(pow(t2, 2.0) * freq_bins))
		end_bin = min(end_bin, freq_bins - 1)

		var energy := 0.0
		for i in range(start_bin, end_bin):
			energy += spectrum[i]
		energy /= float(end_bin - start_bin)

		var target = clamp(energy * 5.0, 0.0, 1.0) * MAX_HEIGHT
		target = log(target+1.0)/log(10) * 100

		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)

	queue_redraw()

func _draw() -> void:
	if bar_heights.size() == 0: return
	var viewport_size = get_viewport_rect().size
	var total_width = NUM_BARS * BAR_WIDTH
	var origin_x = (viewport_size.x - total_width) / 2.0
	var origin_y = viewport_size.y / 2.0

	for b in range(NUM_BARS):
		var h = bar_heights[b]
		var x = origin_x + b * BAR_WIDTH
		#var color = Color.from_hsv(float(b) / NUM_BARS, 0.8, 0.9)
		var color = Color.WHITE
		draw_rect(Rect2(x, origin_y - h, BAR_WIDTH - 2, h), color)
		draw_rect(Rect2(x, origin_y, BAR_WIDTH - 2, h), color)

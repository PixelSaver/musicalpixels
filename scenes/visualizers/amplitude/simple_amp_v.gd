extends VisualizerClass
class_name SimpleAmplitudeVisualizer

const NUM_BARS = 64
const BAR_WIDTH = 16
const MAX_HEIGHT = 400
const SMOOTHING = 0.15

var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.SIMPLE_AMP
func _ready() -> void:
	bar_heights.resize(NUM_BARS)
	bar_heights.fill(0.0)

func handle_visualization(_mini, samples:PackedFloat32Array, _delta:float) -> void:
	if samples.size() < NUM_BARS * 2:
		return

	# Mmono
	var mono: PackedFloat32Array = PackedFloat32Array()
	mono.resize(int(samples.size() / 2.))
	for i in range(mono.size()):
		mono[i] = (samples[i * 2] + samples[i * 2 + 1]) * 0.5

	# Split mono buffer into bands and get peak per band
	var samples_per_band = mono.size() / float(NUM_BARS)
	for b in range(NUM_BARS):
		var peak = 0.0
		var start = b * samples_per_band
		for i in range(samples_per_band):
			var v = abs(mono[start + i])
			if v > peak:
				peak = v
		# Smooth toward target height
		var target = peak * MAX_HEIGHT
		bar_heights[b] = lerp(bar_heights[b], exp(target*.15), SMOOTHING)

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

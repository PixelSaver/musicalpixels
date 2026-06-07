extends VisualizerClass
class_name LineVisualizer

var bar_heights: Array[float] = []
var line := Line2D.new()

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.LINE_AMP

func _ready() -> void:
	add_child(line)
	bar_heights.resize(settings.num_bars)
	bar_heights.fill(0.0)

func handle_visualization(_mini, samples:PackedFloat32Array, _delta:float) -> void:
	if samples.size() < settings.num_bars * 2:
		return

	# Mmono
	var mono: PackedFloat32Array = PackedFloat32Array()
	mono.resize(int(samples.size() / 2.))
	for i in range(mono.size()):
		mono[i] = (samples[i * 2] + samples[i * 2 + 1]) * 0.5

	# Split mono buffer into bands and get peak per band
	var samples_per_band = mono.size() / float(settings.num_bars)
	for b in range(settings.num_bars):
		var peak = 0.0
		var start = b * samples_per_band
		for i in range(samples_per_band):
			var v = abs(mono[start + i])
			if v > peak:
				peak = v
		# Smooth toward target height
		var target = peak * settings.max_height * settings.get_sensitivity_value()
		bar_heights[b] = lerp(bar_heights[b], exp(target*.15), settings.smoothing)

	_update_line()

func _update_line() -> void:
	if bar_heights.is_empty():
		return
	var viewport_size = get_viewport_rect().size
	var total_width = settings.num_bars * settings.width
	var origin_x = (
		viewport_size.x - total_width
	) / 2.0
	var origin_y = viewport_size.y / 2.0
	line.clear_points()
	for p in range(settings.num_bars):
		# spatial smoothing
		var h := 0.0
		var count := 0.0
		for o in range(-2, 3):
			var idx = clamp(
				p + o,
				0,
				settings.num_bars - 1
			)
			h += bar_heights[idx]
			count += 1.0
		h /= count
		var x = origin_x + p * settings.width
		line.add_point(
			Vector2(x, origin_y - h)
		)

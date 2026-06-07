extends VisualizerClass
class_name CircleFFTVisualizer

@export var num_bars  := 50
@export_range(9, 13, 1) var fft_size_exp : int = 13
var fft_size : int
@export var bar_width := 16
@export var max_height := 400.0
@export var radius := 400

var offset := 0.0
@export var sample_rate := 48000.0

var bar_heights: Array[float] = []

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.CIRCLE_FFT
func _ready() -> void:
	fft_size = pow(2,fft_size_exp)
	bar_heights.resize(num_bars)
	bar_heights.fill(0.0)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, delta:float) -> void:
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

		var target = clamp(energy * 5.0, 0.0, 1.0) * max_height
		target = log(target+1.0)/log(10) * 100

		var speed = 0.8 if target > bar_heights[b] else 0.1
		bar_heights[b] = lerp(bar_heights[b], target, speed)
		
		var smoothed: Array[float] = []
		smoothed.resize(num_bars)

		for i in range(num_bars):
			var prev = bar_heights[(i - 1 + num_bars) % num_bars]
			var curr = bar_heights[i]
			var next = bar_heights[(i + 1) % num_bars]

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
	var theta = 2 * PI / num_bars

	for b in range(num_bars):
		var vec = Vector2.UP.rotated(offset + theta*b)
		var pos = vec * radius + origin
		var h = bar_heights[b]
		#var color = Color.from_hsv(float(b) / num_bars, 0.8, 0.9)
		var color = Color.WHITE
		draw_line(pos-vec*h*0.5, pos + vec * h*0.5, color, 10)

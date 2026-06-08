extends VisualizerClass
class_name ArcPulseFFTVisualizer

var state : FFTState = FFTState.new()
const BASS_CEIL   := 0.6
const MID_CEIL    := 0.5
const TREBLE_CEIL := 0.03
const ATTACK := 0.2
const RELEASE := 0.04
var b_1 : float = 0.0
var b_2 : float = 0.0 
var b_3 : float = 0.0
var num_mids = 3.0
var angles : Array[float] = [
	PI / 4.0,
	3 * PI / 4.0,
	5 * PI / 4.0,
	7 * PI / 4.0,
]
var mids : Array[float] = []
var colors = [
	Color("#007368"),
	Color("ff3e46ff"),
	Color("#e28600"),
]

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.ABSTRACT_FFT

func begin_visualization() -> void: 
	mids.resize(num_mids)
	for m in range(num_mids):
		mids[m] = 0.0

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(settings.fft_size, true, true, 0)
	if spectrum.size() == 0:
		return
	
	b_1 = _smooth(b_1, FFTHelper.get_band_energy(spectrum, settings.fft_size, 20, 300, settings.sample_rate) * settings.get_sensitivity_value())
	b_2 = _smooth(b_2, FFTHelper.get_band_energy(spectrum, settings.fft_size, 50, 150, settings.sample_rate) * settings.get_sensitivity_value())
	b_3 = _smooth(b_3, FFTHelper.get_band_energy(spectrum, settings.fft_size, 200, 400, settings.sample_rate) * settings.get_sensitivity_value())
	state = FFTHelper.split_fft_buckets(spectrum, settings.fft_size, settings.sample_rate, state)
	
	var range = Vector2(400, 2000)
	var del = (range.y - range.x) / num_mids
	for m in range(num_mids):
		var sub_range = Vector2(range.x + del * m, range.x + del * (m+1))
		mids[m] = _smooth(mids[m], FFTHelper.get_band_energy(spectrum, settings.fft_size, sub_range.x, sub_range.y, settings.sample_rate) * settings.get_sensitivity_value())
		

	state.bass = _smooth(state.prev_bass, state.bass)
	state.mid = _smooth(state.prev_mid, state.mid)
	state.treble = _smooth(state.prev_treble, state.treble)
	state.amp = _smooth(state.prev_amp, state.amp)
	
	#TODO beat detection
	queue_redraw()

func _draw() -> void:
	var c = get_viewport_rect().size / 2.
	# bass rectangle across screen
	# _draw_bass_arcs(c, clampf(state.bass, 0.0, BASS_CEIL))
	_draw_bass_arcs(c, clampf(sqrt(b_1), 0.0, BASS_CEIL))
	_draw_bass_arcs(c, clampf(sqrt(b_2), 0.0, BASS_CEIL))
	_draw_bass_arcs(c, clampf(sqrt(b_3), 0.0, BASS_CEIL))
	for i in range(mids.size()):
		_draw_mid_arcs(c, clampf(sqrt(sqrt(mids[i])), 0.0, MID_CEIL), i)

func _draw_bass_arcs(c:Vector2, data:float) -> void:
	var mult : float = PI / 4.0 / BASS_CEIL
	draw_arc(c, data*500., angles[0] - data*mult, angles[0] + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., angles[1] - data*mult, angles[1] + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., angles[2] - data*mult, angles[2] + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., angles[3] - data*mult, angles[3] + data*mult, 50, colors[0], 3)

func _draw_mid_arcs(c:Vector2, data:float, seed:int) -> void:
	var mult : float = PI / 4.0 / MID_CEIL
	var rot = settings.noise_func.get_noise_2d(hash(seed*234.23), c.x) * 6 * PI
	_draw_arc(c, data*250. + seed*30., angles[0]+rot, angles[0]+rot + 1+ data*mult, 50, colors[1], true, 3)
	_draw_arc(c, data*250. + seed*30., angles[1]+rot, angles[1]+rot + 1+ data*mult, 50, colors[1], true, 3)
	_draw_arc(c, data*250. + seed*30., angles[2]+rot, angles[2]+rot + 1+ data*mult, 50, colors[1], true, 3)
	_draw_arc(c, data*250. + seed*30., angles[3]+rot, angles[3]+rot + 1+ data*mult, 50, colors[1], true, 3)

func _draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, spike: bool = false, width: float = -1.0, antialiased: bool = false):
	draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased)
	var spike_dir = Vector2.RIGHT.rotated(start_angle)
	draw_line(center + spike_dir * (radius - width*0.5), center + spike_dir * (radius + 5.), color, width)

func _smooth(from:float, to:float) -> float:
	var rate := ATTACK if to > from else RELEASE
	return lerpf(from, to, rate)

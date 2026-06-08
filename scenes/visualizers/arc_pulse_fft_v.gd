extends VisualizerClass
class_name ArcPulseFFTVisualizer

var state : FFTState = FFTState.new()
const BASS_CEIL   := 0.6
const MID_CEIL    := 0.3
const TREBLE_CEIL := 0.03
const ATTACK := 0.2
const RELEASE := 0.04
var b_1 : float = 0.0
var b_2 : float = 0.0 
var b_3 : float = 0.0
var colors = [
	Color("#007368"),
	Color("#e28600"),
]

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.ABSTRACT_FFT

func begin_visualization() -> void: 
	pass

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, _delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(settings.fft_size, true, true, 0)
	if spectrum.size() == 0:
		return
	
	b_1 = _smooth(b_1, FFTHelper.get_band_energy(spectrum, settings.fft_size, 20, 300, settings.sample_rate) * settings.get_sensitivity_value())
	b_2 = _smooth(b_2, FFTHelper.get_band_energy(spectrum, settings.fft_size, 50, 150, settings.sample_rate) * settings.get_sensitivity_value())
	b_3 = _smooth(b_3, FFTHelper.get_band_energy(spectrum, settings.fft_size, 200, 400, settings.sample_rate) * settings.get_sensitivity_value())
	state = FFTHelper.split_fft_buckets(spectrum, settings.fft_size, settings.sample_rate, state)
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

func _draw_bass_arcs(c:Vector2, data:float) -> void:
	print("Value: %s" % data)
	var mult : float = PI / 4.0 / BASS_CEIL
	draw_arc(c, data*500.,   PI/4. - data*mult,   PI/4. + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., 3*PI/4. - data*mult, 3*PI/4. + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., 5*PI/4. - data*mult, 5*PI/4. + data*mult, 50, colors[0], 3)
	draw_arc(c, data*500., 7*PI/4. - data*mult, 7*PI/4. + data*mult, 50, colors[0], 3)

func _smooth(from:float, to:float) -> float:
	var rate := ATTACK if to > from else RELEASE
	return lerpf(from, to, rate)

extends VisualizerClass
class_name ArcPulseFFTVisualizer

var state : FFTState = FFTState.new()
const BASS_CEIL   := 0.8
const MID_CEIL    := 0.3
const TREBLE_CEIL := 0.03
const ATTACK := 0.4
const RELEASE := 0.04
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
	_draw_bass_arcs(c, clampf(state.bass, 0.0, BASS_CEIL))

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

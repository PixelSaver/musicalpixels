extends VisualizerClass
class_name AbstractFFTVisualizer

var state : FFTState = FFTState.new()
const BASS_CEIL   := 0.8
const MID_CEIL    := 0.3
const TREBLE_CEIL := 0.03
const ATTACK := 0.4
const RELEASE := 0.04

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.ABSTRACT_FFT

func begin_visualization() -> void: 
	pass

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(settings.fft_size, true, true, 0)
	if spectrum.size() == 0:
		return
	
	var raw_bass = FFTHelper.get_band_energy(spectrum, settings.fft_size, 20, 400, settings.sample_rate) * settings.get_sensitivity_value()
	var raw_mid = FFTHelper.get_band_energy(spectrum, settings.fft_size, 400, 2000, settings.sample_rate) * settings.get_sensitivity_value()
	var raw_treble = FFTHelper.get_band_energy(spectrum, settings.fft_size, 4000, 12000, settings.sample_rate) * settings.get_sensitivity_value()
	state.bass = _smooth(state.bass, raw_bass)
	state.mid = _smooth(state.mid, raw_mid)
	state.treble = _smooth(state.treble, raw_treble)
	state.amp = FFTHelper.get_amplitude_from_spectrum(spectrum)
	#TODO beat detection
	queue_redraw()

func _draw() -> void:
	var c = get_viewport_rect().size / 2.
	
	# figure out background color??
	
	# bass rectangle across screen
	if state.bass > .01:
		var bh:= remap(state.bass, .01, BASS_CEIL, 0, 160)
		draw_rect(Rect2(0, c.y - bh / 2.0, c.x*2.0, bh), Color("#fab0af"))
	# mid circle at center?
	if state.mid > .005:
		var r:= remap(state.mid, 0, MID_CEIL, 0, 160)
		draw_circle(c, r, Color("#9ca8c6"), true, -1, true)
	
	# treble diamond
	var d := remap(state.treble, 0, TREBLE_CEIL, 0, 160)
	if d > 1.0:
		draw_colored_polygon(
			PackedVector2Array([
				c + Vector2(0,  d),
				c + Vector2(d,  0),
				c + Vector2(0, -d),
				c + Vector2(-d, 0),
			]),
			Color("#c57ffe")
		)

func _smooth(from:float, to:float) -> float:
	var rate := ATTACK if to > from else RELEASE
	return lerpf(from, to, rate)

extends VisualizerClass
class_name ArcsFFTVisualizer

@export var settings : VisualizerSettings = VisualizerSettings.new()
@export var ring_separation := 10.0
@export var ring_resolution := 30
@export var init_ring_size := 10.0
var colors : Array[Color]= [
	Color.from_string("#ec4503", Color.AQUAMARINE),
	Color.from_string("#ffac11", Color.AQUAMARINE),
	Color.from_string("#fa017b", Color.AQUAMARINE),
	Color.from_string("#00c299", Color.AQUAMARINE),
]
## [a,b,c,d] 
## a is the starting angle
## b is the length of the arc
## c is the change/energy per frame
## d is the 2nd derivative
## e is smoothed 2nd derivative
var arc_lengths: Array[Array] = []
var max_energy := -1.0
var cum_time := 0.0

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.ARCS_FFT

func begin_visualization() -> void: 
	arc_lengths.clear()
	for i in range(settings.num_bars):
		arc_lengths.append([randf_range(0.0, TAU), 0.0, 0.0, 0.0, 0.0])
	cum_time = randfn(0.0, 100.)

func handle_visualization(miniaudio:MiniaudioClass, _samples:PackedFloat32Array, delta:float) -> void:
	var spectrum: PackedFloat32Array = miniaudio.get_fft(settings.fft_size, true, true, 0)
	if spectrum.size() == 0:
		return

	for b in range(settings.num_bars):
		var t1 = float(b) / settings.num_bars
		var t2 = float(b + 1) / settings.num_bars

		var nyquist :float= settings.sample_rate * 0.5
		var f_min := settings.low_cut * pow(settings.high_cut / settings.low_cut, t1)
		var f_max := settings.low_cut * pow(settings.high_cut / settings.low_cut, t2)

		var energy := FFTHelper.get_band_energy(
			spectrum,
			settings.fft_size,
			f_min,
			f_max,
			settings.sample_rate,
		)
		var target = pow(energy * 0.2, 0.26) * settings.max_height * 0.5
		
		var speed = 0.8 if target > arc_lengths[b][2] else 0.1
		var new_len = lerp(arc_lengths[b][2], target, speed)
		arc_lengths[b][3] = new_len - arc_lengths[b][2]
		arc_lengths[b][2] = new_len
	
	max_energy = -1.0
	for _set in arc_lengths:
		max_energy = max(_set[3], max_energy)
	
	cum_time += delta
	queue_redraw()

func _draw() -> void:
	if arc_lengths.size() <= 0: return
	var c : Vector2 = get_viewport_rect().size / 2.
	for i in range(settings.num_bars):
		## [a,b,c,d] 
		## a is the starting angle
		## b is the length of the arc
		## c is the change/energy per frame
		## d is the 2nd derivative
		var _set = arc_lengths[i]
		var rad = init_ring_size + i * ring_separation
		_set[4] = lerp(_set[4], _set[3], 0.1)
		var advance = _set[4] * .1 if _set[4] > 0. else _set[4] * .05
		advance += settings.noise_func.get_noise_2d(cum_time, i*30.) * .1 * (.05 + max_energy) * settings.noise_level * log(i+1)
		var theta = _set[0] + advance
		_set[0] = theta
		var length = clamp(
			lerp(_set[1], _set[1] + _set[2], 0.2) + 0.2 + 0.01*i, 
			0.0, TAU
		)
		draw_arc(c, rad + sqrt(length*100), 
			theta, 
			theta+length, 
			ring_resolution, 
			colors[i % 4].lightened(remap(length, 0.0, TAU, -0.2, 0.2)), 
			20 + pow(abs(_set[4]), 0.3) * (-1 if _set[4] < 0.0 else 1) * 3,
			true,
		)

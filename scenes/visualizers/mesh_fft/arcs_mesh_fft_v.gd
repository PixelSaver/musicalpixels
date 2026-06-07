extends VisualizerClass
class_name ArcsMeshFFTVisualizer

@export var ring_separation := 1.0
@export var ring_resolution := 40
#@export var init_ring_size := 0.0
var colors : Array[Color]= [
	Color.from_string("#ec4503", Color.AQUAMARINE),
	Color.from_string("#ffac11", Color.AQUAMARINE),
	Color.from_string("#fa017b", Color.AQUAMARINE),
	Color.from_string("#00c299", Color.AQUAMARINE),
]
## [a,b,c,d,e] 
## a is the starting angle
## b is the length of the arc
## c is the change/energy per frame
## d is the 2nd derivative
## e is smoothed 2nd derivative
var arc_lengths: Array[Array] = []
var max_energy := -1.0
var cum_time := 0.0

var im_mesh := ImmediateMesh.new()
var mesh_inst = MeshInstance3D.new()

func get_visualizer_id() -> VisualizerDatabase.VisualizerID:
	return VisualizerDatabase.VisualizerID.ARCS_MESH_FFT

func begin_visualization() -> void: 
	arc_lengths.clear()
	for i in range(settings.num_bars):
		arc_lengths.append([randf_range(0.0, TAU), 0.0, 0.0, 0.0, 0.0])
	cum_time = randfn(0.0, 100.)
	mesh_inst.mesh = im_mesh
	add_child(mesh_inst)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mesh_inst.material_override = mat
	mesh_inst.rotate_x(-PI/2.)
	

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
		var target = pow(energy * 0.2, 0.26) * settings.max_height * 0.5 * settings.get_sensitivity_value()
		
		var speed = 0.8 if target > arc_lengths[b][2] else 0.1
		var new_len = lerp(arc_lengths[b][2], target, speed)
		arc_lengths[b][3] = new_len - arc_lengths[b][2]
		arc_lengths[b][2] = new_len
	
	max_energy = -1.0
	for _set in arc_lengths:
		max_energy = max(_set[3], max_energy)
	
	cum_time += delta
	_draw_3d()

func _draw_3d() -> void:
	im_mesh.clear_surfaces()
	im_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if arc_lengths.size() <= 0: return
	var c : Vector2 = get_viewport_rect().size / 2.
	for i in range(settings.num_bars):
		## [a,b,c,d] 
		## a is the starting angle
		## b is the length of the arc
		## c is the change/energy per frame
		## d is the 2nd derivative
		var _set = arc_lengths[i]
		var rad = settings.radius + i * ring_separation
		
		_set[4] = lerp(_set[4], _set[3], 0.1)
		
		var advance = _set[4] * .1 if _set[4] > 0. else _set[4] * .05
		advance += settings.noise_func.get_noise_2d(cum_time, i*30.) * .1 * (.05 + max_energy) * settings.noise_level * log(i+1)
		var theta = _set[0] + advance
		_set[0] = theta
		var length = clamp(
			lerp(_set[1], _set[1] + _set[2], 0.2) + 0.2 + 0.01*i, 
			0.0, TAU
		)
		draw_arc_3d(
			im_mesh,
			Vector3(0., 0., log(length)*3), 
			rad + log(length*.1), 
			theta, 
			theta+length, 
			colors[i % 4].lightened(remap(length, 0.0, TAU, -0.1, 0.2)), 
			3 + pow(abs(_set[4]), 0.8) * (-1 if _set[4] < 0.0 else 1)*0.5,
			3. + pow(abs(_set[4]), 0.8) * (-1 if _set[4] < 0.0 else 1)*2.0,
			ring_resolution, 
		)
	im_mesh.surface_end()

func draw_arc_3d(
	mesh: ImmediateMesh,
	center: Vector3,
	radius: float,
	angle_from: float,
	angle_to: float,
	color: Color,
	thickness: float,
	z_depth: float,
	steps: int = 30,
	#normal:
) -> void:
	var half_t := thickness * 0.5
	var half_d := z_depth * 0.5

	for s in range(steps):
		var t0 := float(s) / steps
		var t1 := float(s + 1) / steps
		var a0 := lerpf(angle_from, angle_to, t0)
		var a1 := lerpf(angle_from, angle_to, t1)

		# Front face (z = +half_d) and back face (z = -half_d)
		var fi0 := center + Vector3(cos(a0) * (radius - half_t), sin(a0) * (radius - half_t),  half_d)
		var fo0 := center + Vector3(cos(a0) * (radius + half_t), sin(a0) * (radius + half_t),  half_d)
		var fi1 := center + Vector3(cos(a1) * (radius - half_t), sin(a1) * (radius - half_t),  half_d)
		var fo1 := center + Vector3(cos(a1) * (radius + half_t), sin(a1) * (radius + half_t),  half_d)

		var bi0 := center + Vector3(cos(a0) * (radius - half_t), sin(a0) * (radius - half_t), -half_d)
		var bo0 := center + Vector3(cos(a0) * (radius + half_t), sin(a0) * (radius + half_t), -half_d)
		var bi1 := center + Vector3(cos(a1) * (radius - half_t), sin(a1) * (radius - half_t), -half_d)
		var bo1 := center + Vector3(cos(a1) * (radius + half_t), sin(a1) * (radius + half_t), -half_d)

		# -- FRONT FACE (normal +Z) --
		_tri(mesh, color, Vector3.BACK, fi0, fo0, fo1)
		_tri(mesh, color, Vector3.BACK, fi0, fo1, fi1)

		# -- BACK FACE (normal -Z, winding flipped) --
		_tri(mesh, color, Vector3.FORWARD, bi0, bo1, bo0)
		_tri(mesh, color, Vector3.FORWARD, bi0, bi1, bo1)

		# -- OUTER WALL (normal points away from center radially) --
		var on0 := Vector3(cos(a0), sin(a0), 0.0)
		var on1 := Vector3(cos(a1), sin(a1), 0.0)
		_tri(mesh, color, on0, fo0, bo0, bo1)
		_tri(mesh, color, on1, fo0, bo1, fo1)

		# -- INNER WALL (normal points toward center, flipped) --
		var in0 := -Vector3(cos(a0), sin(a0), 0.0)
		var in1 := -Vector3(cos(a1), sin(a1), 0.0)
		_tri(mesh, color, in0, fi0, bi0, bi1)  # winding flipped vs outer
		_tri(mesh, color, in1, fi0, bi1, fi1)

	# -- END CAPS (flat quads at angle_from and angle_to) --
	# Each cap needs its own segment normal (tangent to the arc at that point)
	_add_cap(mesh, color, center, radius, half_t, half_d, angle_from, -1.0)
	_add_cap(mesh, color, center, radius, half_t, half_d, angle_to,    1.0)


func _tri(mesh: ImmediateMesh, color: Color, normal: Vector3, a: Vector3, b: Vector3, c: Vector3) -> void:
	mesh.surface_set_color(color); mesh.surface_set_normal(normal); mesh.surface_add_vertex(a)
	mesh.surface_set_color(color); mesh.surface_set_normal(normal); mesh.surface_add_vertex(b)
	mesh.surface_set_color(color); mesh.surface_set_normal(normal); mesh.surface_add_vertex(c)


func _add_cap(mesh: ImmediateMesh, color: Color, center: Vector3, radius: float, half_t: float, half_d: float, angle: float, dir: float) -> void:
	# Normal is the tangent of the arc at this angle, pointing outward or inward
	var cap_normal := Vector3(-sin(angle) * dir, cos(angle) * dir, 0.0)
	var fi := center + Vector3(cos(angle) * (radius - half_t), sin(angle) * (radius - half_t),  half_d)
	var fo := center + Vector3(cos(angle) * (radius + half_t), sin(angle) * (radius + half_t),  half_d)
	var bi := center + Vector3(cos(angle) * (radius - half_t), sin(angle) * (radius - half_t), -half_d)
	var bo := center + Vector3(cos(angle) * (radius + half_t), sin(angle) * (radius + half_t), -half_d)
	_tri(mesh, color, cap_normal, fi, bi, bo)
	_tri(mesh, color, cap_normal, fi, bo, fo)

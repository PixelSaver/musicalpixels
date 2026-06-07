class_name FFTHelper
extends RefCounted

enum Sizes {
	## 512
	TINY=512,
	## 1024
	SMALL=1024,
	## 2048
	MEDIUM=2048,
	## 4096
	HIGH=4096,
	## 8192
	SUPER=8192,
	## 16384
	MAX=16384,
}

static func get_band_energy(
	spectrum: PackedFloat32Array,
	fft_size: Sizes,
	f_min: float,
	f_max: float,
	sample_rate: float
) -> float:

	var nyquist := sample_rate * 0.5
	f_min = clamp(f_min, 0.0, nyquist)
	f_max = clamp(f_max, 0.0, nyquist)

	if f_max <= f_min: return 0.0

	var bin_count := fft_size/2.

	var start_f := (f_min / nyquist) * bin_count
	var end_f := (f_max / nyquist) * bin_count
	var start_bin := int(floor(start_f))
	var end_bin := int(ceil(end_f))

	start_bin = clamp(start_bin, 1, bin_count-1)
	end_bin = clamp(end_bin, start_bin, bin_count-1)

	var energy = 0.0
	var count := 0

	for i in range(start_bin, end_bin):
		energy += spectrum[i]
		count += 1
	if count == 0: return 0.0
	
	return energy / float(count)

static func get_amplitude_from_spectrum(spectrum: PackedFloat32Array) -> float:
	var sum := 0.0
	for v in spectrum:
		sum += v
	return sum / spectrum.size()

static func get_amplitude_from_sample(samples: PackedFloat32Array, window: int = 1024) -> float:
	var start := maxf(0, samples.size() - window)
	var sum := 0.0
	for i in range(start, samples.size()):
		sum += samples[i] * samples[i]
	return sqrt(sum / (samples.size() - start))

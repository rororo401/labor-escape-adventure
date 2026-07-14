class_name RandomSeedMixer
extends RefCounted

const MODULUS := 2147483647
const UINT32_RANGE := 4294967296.0


static func seed_from_text(seed_text: String) -> int:
	var primary := 104729
	var secondary := 130363
	for byte in seed_text.to_utf8_buffer():
		var value := int(byte) + 1
		primary = int((primary * 257 + value) % MODULUS)
		secondary = int((secondary * 263 + value + primary % 97) % MODULUS)
	var mixed := int((primary * 65537 + secondary + seed_text.length()) % MODULUS)
	return 1 if mixed == 0 else mixed


static func rng_from_text(seed_text: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_from_text(seed_text)
	return rng


static func unit_float(seed_text: String) -> float:
	var rng := rng_from_text(seed_text)
	return float(rng.randi()) / UINT32_RANGE


static func shuffle_in_place(items: Array, seed_text: String) -> void:
	var rng := rng_from_text(seed_text)
	for index in range(items.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temporary = items[index]
		items[index] = items[swap_index]
		items[swap_index] = temporary

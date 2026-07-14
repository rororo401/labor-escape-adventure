class_name GameAudioManager
extends Node

const SETTINGS_PATH := "user://audio_settings.cfg"
const SETTINGS_SECTION := "audio"
const MUSIC_ENABLED_KEY := "music_enabled"
const MUSIC_VOLUME_KEY := "music_volume_percent"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const DEFAULT_MUSIC_PATH := "res://assets/audio/music/calm_daily_loop.ogg"
const DEFAULT_MUSIC_ENABLED := true
const DEFAULT_MUSIC_VOLUME_PERCENT := 55.0

var settings_path := SETTINGS_PATH
var music_enabled := DEFAULT_MUSIC_ENABLED
var music_volume_percent := DEFAULT_MUSIC_VOLUME_PERCENT
var _music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_load_settings()
	_create_music_player()
	_apply_music_settings()
	if DisplayServer.get_name() != "headless":
		play_music(DEFAULT_MUSIC_PATH)


func _exit_tree() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	_apply_music_settings()
	_save_settings()
	if music_enabled and _music_player != null and not _music_player.playing:
		_music_player.play()


func is_music_enabled() -> bool:
	return music_enabled


func set_music_volume_percent(value: float) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	_apply_music_settings()
	_save_settings()


func get_music_volume_percent() -> float:
	return music_volume_percent


func play_music(stream_path: String, restart: bool = false) -> void:
	if _music_player == null or stream_path.is_empty():
		return
	var next_stream := load(stream_path) as AudioStream
	if next_stream == null:
		push_warning("Could not load music stream: %s" % stream_path)
		return
	if next_stream is AudioStreamOggVorbis:
		(next_stream as AudioStreamOggVorbis).loop = true
	if _music_player.stream != next_stream:
		_music_player.stream = next_stream
		restart = true
	if music_enabled and (restart or not _music_player.playing):
		_music_player.play()


func stop_music() -> void:
	if _music_player != null:
		_music_player.stop()


func reload_settings() -> void:
	_load_settings()
	_apply_music_settings()


func _create_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "BackgroundMusicPlayer"
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func _apply_music_settings() -> void:
	var bus_index := AudioServer.get_bus_index(MUSIC_BUS)
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, not music_enabled)
	var linear_volume := maxf(music_volume_percent / 100.0, 0.0001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		music_enabled = DEFAULT_MUSIC_ENABLED
		music_volume_percent = DEFAULT_MUSIC_VOLUME_PERCENT
		return
	music_enabled = bool(config.get_value(SETTINGS_SECTION, MUSIC_ENABLED_KEY, DEFAULT_MUSIC_ENABLED))
	music_volume_percent = clampf(
		float(config.get_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, DEFAULT_MUSIC_VOLUME_PERCENT)),
		0.0,
		100.0
	)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SETTINGS_SECTION, MUSIC_ENABLED_KEY, music_enabled)
	config.set_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, music_volume_percent)
	var error := config.save(settings_path)
	if error != OK:
		push_warning("Could not save audio settings: %s" % error)

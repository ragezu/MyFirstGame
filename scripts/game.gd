# === File: game.gd ===
extends Node2D

@onready var player = $player
@onready var start_button = $HUD/TitlePanel/StartButton
@onready var title_panel = $HUD/TitlePanel
@onready var game_over_panel = $HUD/GameOverPanel
@onready var time_label = $HUD/GameOverPanel/TimeLabel
@onready var fall_label = $HUD/GameOverPanel/FallLabel
@onready var music = $BackgroundMusic
@onready var portal_node = $Levels/Level1/Portal  # Corrected path based on your scene tree

var game_started = false
var time_played = 0.0
var fall_count = 0
var last_y = 0.0
const FALL_DISTANCE = 320.0  # 10 tiles * 32px

func _ready():
	if player:
		player.visible = false
		player.set_physics_process(false)
	if title_panel:
		title_panel.visible = true
	if game_over_panel:
		game_over_panel.visible = false

	# Debug border for GameOverPanel
	if game_over_panel:
		var style = StyleBoxFlat.new()
		style.border_color = Color.RED
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		game_over_panel.add_theme_stylebox_override("panel", style)

	# Connect signals
	if start_button:
		start_button.pressed.connect(_on_start_pressed)

	print("PORTAL NODE:", portal_node)
	if portal_node and portal_node.has_signal("touched_portal"):
		print("Connecting portal signal to game.gd...")
		portal_node.touched_portal.connect(_on_touched_portal)
	else:
		print("[ERROR] Portal signal not found or not connected")

func _on_start_pressed():
	if title_panel:
		title_panel.visible = false
	if game_over_panel:
		game_over_panel.visible = false

	if player:
		player.visible = true
		player.set_physics_process(true)
		player.global_position = Vector2(100, -200)  # Spawn location

	if $Levels:
		$Levels.visible = true

	game_started = true
	time_played = 0.0
	fall_count = 0
	last_y = player.global_position.y if player else 0
	if music:
		music.play()

func _process(delta):
	if not game_started or not player:
		return

	time_played += delta

	var y_now = player.global_position.y
	if y_now - last_y > FALL_DISTANCE:
		fall_count += 1
		last_y = y_now
		player.play_fall_sound()
	elif y_now < last_y:
		last_y = y_now

func _on_touched_portal(body):
	if body == player:
		print("Teleporting:", body.name)
		game_started = false
		player.set_physics_process(false)
		if music:
			music.stop()
		player.play_finish_sound()
		show_game_over()

func show_game_over():
	print("=== show_game_over() called ===")
	var seconds = int(time_played)
	var minutes = seconds / 60
	var hours = minutes / 60
	seconds %= 60
	minutes %= 60

	if time_label:
		print("Setting time label")
		time_label.text = "Time: %02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		print("time_label is null")

	if fall_label:
		print("Setting fall label")
		fall_label.text = "Falls: %d" % fall_count
	else:
		print("fall_label is null")

	if game_over_panel:
		print("Setting game_over_panel.visible = true")
		game_over_panel.visible = true
	else:
		print("game_over_panel is null")

	if player:
		player.visible = false
	if $Levels:
		$Levels.visible = false

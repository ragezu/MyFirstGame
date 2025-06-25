extends Marker2D

@export var room_height: int = 720  # Height of one vertical room (screen)

var current_room_y: int = -1  # Tracks which room the player is in

@onready var player: Node2D = get_node("$../player")  # Update path if needed

func _ready() -> void:
	update_camera_position()

func _physics_process(_delta: float) -> void:
	update_camera_position()

func update_camera_position() -> void:
	if player == null:
		return

	# Determine which vertical room the player is in
	var new_room_y: int = int(floor(player.global_position.y / room_height))

	# Only move the camera if player entered a new room
	if new_room_y != current_room_y:
		current_room_y = new_room_y
		global_position.y = current_room_y * room_height + room_height / 2

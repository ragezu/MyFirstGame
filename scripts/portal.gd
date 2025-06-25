extends Area2D

signal touched_portal(body)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("PORTAL TRIGGERED by:", body.name)
	emit_signal("touched_portal", body)

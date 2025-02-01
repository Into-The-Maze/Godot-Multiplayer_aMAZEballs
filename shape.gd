# shape.gd
extends RigidBody3D

func _ready() -> void:
	$OmniLight3D.light_color = Color(randf(), randf(), randf())
	$OmniLight3D.light_energy = 5

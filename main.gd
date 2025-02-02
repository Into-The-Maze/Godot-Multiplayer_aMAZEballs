# main.gd
extends Node

const PORT = 135
var peer = ENetMultiplayerPeer.new()

var shape_id_counter = 0

@export var p: PackedScene  # Player scene
@export var s: PackedScene  # Shape scene

func _on_spawn_pressed() -> void:
	# Only the server should actually create the object.
	# If this is a client, send an RPC request to the server.
	if multiplayer.is_server():
		_spawn_shape()  # spawn locally and tell clients
	else:
		# Send request to the host (assumed to have peer ID 1)
		rpc_id(1, "spawn_shape_request")

@rpc("authority")  # Only the server (authority) can run this.
func spawn_shape_request() -> void:
	_spawn_shape()

func _spawn_shape() -> void:
	# Create the shape on the server.
	var shape = s.instantiate()
	shape.position = Vector3(0, 10, 0)
	add_child(shape)

	# Assign a unique ID to each shape.
	shape_id_counter += 1
	var shape_id = shape_id_counter

	# Now tell all clients to create a matching shape.
	rpc("spawn_shape_remote", shape.position, shape_id)

@rpc("call_remote")  # This runs on every peer.
func spawn_shape_remote(pos: Vector3, shape_id: int) -> void:
	# On the server we already spawned it, so only let clients do so.
	if multiplayer.is_server():
		return

	# Avoid spawning the same shape multiple times by tracking IDs.
	if has_node(str(shape_id)):
		return  # Shape with this ID already exists.

	var shape = s.instantiate()
	shape.position = pos
	shape.name = str(shape_id)  # Store the ID to prevent duplicates
	add_child(shape)
	
func _on_join_pressed() -> void:
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer
	$Control/Host.hide()
	$Control/Join.hide()

func _on_host_pressed() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	# When a peer connects, add a new player.
	multiplayer.peer_connected.connect(_on_peer_connected)
	$Control/Host.hide()
	$Control/Join.hide()

func _on_peer_connected(id: int) -> void:
	# When a new peer connects, create a player node for them on the server.
	# (In this example, the server assigns the new player an ID.)
	add_player(id)

func add_player(id: int) -> void:
	# The server creates a player for the given id.
	var player = p.instantiate()
	player.name = str(id)
	add_child(player)
	# Tell all clients to also create this player.
	rpc("add_player_remote", str(id))

@rpc("call_remote")
func add_player_remote(id: String) -> void:
	# Only create the player on clients; the server already did.
	if multiplayer.is_server():
		return
	var player = p.instantiate()
	player.name = id
	add_child(player)

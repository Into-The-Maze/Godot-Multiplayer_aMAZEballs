extends Node2D

@onready var texture_rect = $TextureRect  # Reference to your TextureRect (to get the texture)
@onready var viewport = $SubViewport         # Reference to your Viewport
@onready var mesh_instance = $MeshInstance2D # Reference to your MeshInstance (or create it dynamically)

func _ready():
	# Assuming the setup is correct
	var texture = viewport.get_texture()

	# Create a ShaderMaterial or use a SpatialMaterial
	var material = ShaderMaterial.new()
	
	# Apply the texture to the material's shader parameter
	material.set_shader_param("texture", texture)

	# Set the material to the MeshInstance
	mesh_instance.material_override = material
	
	# Ensure the MeshInstance is visible in the scene
	mesh_instance.visible = true

extends MeshInstance3D
var lifetime = 0.3
var alpha = 1.0
var speed = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1, pos2):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(pos1)
	draw_mesh.surface_add_vertex(pos2)
	draw_mesh.surface_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifetime -= delta
	alpha -= delta * 3.5
	material_override.albedo_color.a = alpha
	if(lifetime <= 0):
		queue_free()

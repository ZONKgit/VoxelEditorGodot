extends Spatial

onready var model = $"../model"

func _ready():
	update_model()

func update_model():
	var voxel_scale = 0.1
	
	for child in get_children():
		child.queue_free()
	
	for i in model.model:
		var voxel = preload("res://scenes/prevew_voxel.tscn").instance()
		voxel.global_translation = Vector3(i[0]*voxel_scale, i[1]*voxel_scale, i[2]*voxel_scale)

		add_child(voxel)

func add_voxel(pos: Vector3):
	model.model.append([pos.x, pos.y, pos.z])
	update_model()

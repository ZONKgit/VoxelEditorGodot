extends Spatial

onready var camera = $camera/camera
onready var model = $model

var is_workspace_active = true
var viewMode = "Normal"
var brush_mode = "Attach" # Attach-Добавление Erase-Удаление Paint-Рисование
var voxel_color: Color = Color(255,255,255)
var collision_point:Vector3
var collision_normal:Vector3

func _input(e) -> void:
	if is_workspace_active:

		var mouse_position = get_viewport().get_mouse_position()
		var collistion_dict := raycast_from_mouse(mouse_position, 1)

		if collistion_dict.has("position"):
			var cursor_position: Vector3 = collistion_dict.position
			var cursor_normal: Vector3 = collistion_dict.normal
			var voxel_pos = (cursor_position-cursor_normal/20).snapped(Vector3.ONE*0.1)
			var new_voxel_pos = (cursor_position+cursor_normal/20).snapped(Vector3.ONE*0.1)
			
			$cursor.translation = new_voxel_pos
			$remove_cursor.translation = voxel_pos
			
			if Input.is_action_just_pressed("attach"):
				match brush_mode:
					"Attach":
						model.add_voxel(new_voxel_pos*10, voxel_color)
					"Erase":
						model.remove_voxel(voxel_pos*10)
					"Paint":
						model.paint_voxel(voxel_pos*10, voxel_color)
						
			if cursor_position:  _emit_cursor_position(cursor_position, cursor_normal)
		else: $cursor.translation = Vector3(0,255,0)
	
func raycast_from_mouse(mouse_position: Vector2, collision_mask) -> Dictionary:
	var ray_start = camera.project_ray_origin(mouse_position)
	var ray_end: Vector3 = ray_start + camera.project_ray_normal(mouse_position) * 10
	var space_state := get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)
func _emit_cursor_position(raw_position: Vector3, raw_normal: Vector3):
	var normal = raw_normal.snapped(Vector3.ONE)
	var position = _get_proper_position(raw_position, normal)
	
	return position
	emit_signal("pointing_at", position, normal)
func _get_proper_position(raw_position: Vector3, normal: Vector3) -> Vector3:
	var position = raw_position
	position = position.snapped(Vector3.ONE)
	return position - normal / 2




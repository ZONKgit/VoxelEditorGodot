extends CanvasLayer

onready var model = $"../model"
onready var editor = $".."

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func _on_selectViewMode_item_selected(index):
	match index:
		0:
			model.material_overlay = null
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		1:
			model.material_overlay = load("res://resources/materials/debug_material.tres")
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME


func _on_is_outline_toggled(button_pressed):
	$"../camera/camera/MeshInstance".visible = button_pressed


func _on_voxel_color_picker_color_changed(color):
	editor.voxel_color = color




func _on_workspace_area_mouse_entered():
	editor.is_workspace_active = true


func _on_workspace_area_mouse_exited():
	editor.is_workspace_active = false


func _on_attach_mode_button_pressed():
	editor.brush_mode = "Attach"

func _on_erase_mode_button_pressed():
	editor.brush_mode = "Erase"


func _on_paint_mode_button_pressed():
	editor.brush_mode =  "Paint"


func _on_reload_model_button_pressed():
	model.update_model()

extends CanvasLayer

onready var model = $"../model"
onready var editor = $".."
onready var colors_grid = $ui/left_panel/colors_list_panel/colors_grid

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func add_color_to_pallete(color: Color) -> void:
	var color_button = preload("res://scenes/color_prev.tscn").instance()
	color_button.color = color
	color_button.get_node("set_color_button").connect("pressed", editor, "set_active_color", [color])
	colors_grid.add_child(color_button)

func _on_selectViewMode_item_selected(index): # Переключение режима просмотра
	match index:
		0:
			model.material_overlay = null
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		1:
			model.material_overlay = load("res://resources/materials/debug_material.tres")
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
func _on_is_outline_toggled(button_pressed): # Переключение режима обводки
	$"../camera/camera/MeshInstance".visible = button_pressed
func _on_voxel_color_picker_popup_closed(): # Смена активного цвета
	var color = $ui/left_panel/select_color_container/voxel_color_picker.color
	editor.set_active_color(color)
	add_color_to_pallete(color)
	
func _on_workspace_area_mouse_entered(): # Находиться ли курсор в рабочей области
	editor.is_workspace_active = true
func _on_workspace_area_mouse_exited(): # Находиться ли курсор в рабочей области
	editor.is_workspace_active = false
func _on_attach_mode_button_pressed(): # Выбор режима установки вокселя
	editor.brush_mode = "Attach"
func _on_erase_mode_button_pressed(): # Выбор режима ломания вокселя
	editor.brush_mode = "Erase"
func _on_paint_mode_button_pressed(): # Выбор режима рисовнаия вокселя
	editor.brush_mode =  "Paint"
func _on_reload_model_button_pressed(): # Перезапуск модели
	model.update_model()



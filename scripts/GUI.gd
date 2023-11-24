extends CanvasLayer

onready var model = $"../model"
onready var editor = $".."
onready var colors_grid = $ui/left_panel/colors_list_panel/ScrollContainer/colors_grid
onready var save_project_panel = $ui/save_project_panel
onready var export_project_panel = $ui/export_project_panel

func _ready():
	load_models_list()

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func add_color_to_pallete(color: Color) -> void:
	var color_button = preload("res://scenes/color_prev.tscn").instance()
	color_button.color = color
	color_button.get_node("set_color_button").connect("pressed", editor, "set_active_color", [color])
	colors_grid.add_child(color_button)
func remove_all_colors_in_pallete() -> void:
	model.colors = []
	for child in colors_grid.get_children():
		child.queue_free()
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
	model.colors.append(color)
func _on_workspace_area_mouse_entered(): # Находиться ли курсор в рабочей области
	editor.is_workspace_active = true
func _on_workspace_area_mouse_exited(): # Находиться ли курсор в рабочей области
	editor.is_workspace_active = false
func _on_attach_mode_button_pressed(): # Выбор режима установки вокселя
	editor.brush_mode = "Attach"
	$ui/left_panel/brush_mode_buttons/attach_mode_button.disabled = true
	$ui/left_panel/brush_mode_buttons/erase_mode_button.disabled = false
	$ui/left_panel/brush_mode_buttons/paint_mode_button.disabled = false
func _on_erase_mode_button_pressed(): # Выбор режима ломания вокселя
	editor.brush_mode = "Erase"
	$ui/left_panel/brush_mode_buttons/attach_mode_button.disabled = false
	$ui/left_panel/brush_mode_buttons/erase_mode_button.disabled = true
	$ui/left_panel/brush_mode_buttons/paint_mode_button.disabled = false
func _on_paint_mode_button_pressed(): # Выбор режима рисовнаия вокселя
	editor.brush_mode =  "Paint"
	$ui/left_panel/brush_mode_buttons/attach_mode_button.disabled = false
	$ui/left_panel/brush_mode_buttons/erase_mode_button.disabled = false
	$ui/left_panel/brush_mode_buttons/paint_mode_button.disabled = true
func _on_reload_model_button_pressed(): # Перезапуск модели
	model.update_model()
func load_models_list() -> void: # Загрузка проектов в список проектов
	var exaple_files_list_node = $ui/right_panel/projects_list/ScrollContainer/VBoxContainer
	var exaple_files = Utils.list_files_in_directory("res://"+editor.projects_folder+"/")
	
	#Удаление всех предыдущих кнопок, если таковы есть
	for child in exaple_files_list_node.get_children():
		child.queue.queue_free()
	
	for file in exaple_files:
		
		var button = Button.new()
		button.connect("pressed", model, "load_project", [str(file)])
		button.text = str(file)
		
		exaple_files_list_node.add_child(button)
	print(Utils.list_files_in_directory("res://"+editor.projects_folder+"/"))

func _on_close_save_project_panel_button_pressed():
	save_project_panel.hide()
func _on_save_project_button_pressed():
	var save_project_file_name = $ui/save_project_panel/save_project_file_name
	model.save_project(save_project_file_name.text)
	save_project_panel.hide()
	load_models_list()
func _on_open_save_project_panel_button_pressed():
	save_project_panel.show()
func _input(event):
#	Горячии клавиши
	if Input.is_action_just_pressed("save_project"):
		_on_open_save_project_panel_button_pressed()
	if Input.is_action_just_pressed("place"):
		_on_attach_mode_button_pressed()
	if Input.is_action_just_pressed("erase"):
		_on_erase_mode_button_pressed()
	if Input.is_action_just_pressed("paint"):
		_on_paint_mode_button_pressed()
func _on_export_button_pressed(): #Кнопка открытия панели экспорта
	export_project_panel.show()
func _on_export_project_button_pressed(): # Кнопка экспорта проекта
	var message_label_text = $ui/export_project_panel/output_message_label.text
	var filename = $ui/export_project_panel/export_project_file_name.text
	var is_create_folder = $ui/export_project_panel/export_project_button/create_folder_check_box.pressed
	var export_output = model.exportcsg(filename, is_create_folder)
	message_label_text = str("Файл сохранён: "+export_output)
	$ui/export_project_panel/export_project_button.hide()
	
func _on_close_export_project_panel_button_pressed():
	export_project_panel.hide()
	$ui/export_project_panel/export_project_button.show()

func _on_new_project_button_pressed():
	model.model = []
	model.update_model()
	remove_all_colors_in_pallete()

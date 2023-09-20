extends Panel

onready var color_prev = $color_preview
onready var r_value_label = $color_sliders_box/r_container/value
onready var g_value_label = $color_sliders_box/g_container/value
onready var b_value_label = $color_sliders_box/b_container/value

var color: Color

func update() -> void:
	color_prev.color = color
	r_value_label.text = str(int(color.r*255))
	g_value_label.text = str(int(color.g*255))
	b_value_label.text = str(int(color.b*255))
	

func _on_r_slider_value_changed(value):
	color.r = value/255
	update()

func _on_g_slider_value_changed(value):
	color.g = value/255
	update()

func _on_b_slider_value_changed(value):
	color.b = value/255
	update()

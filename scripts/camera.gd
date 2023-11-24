extends Position3D

onready var camera = $camera

var sensivity: float = 0.005
var zoom: float = 1
var max_zoom: float = 3
var min_zoom: float = 0.1

func _process(delta) -> void:
	camera.translation.z = zoom




func _input(event) -> void:
	
	if Input.is_action_pressed("camera_move") and Input.is_action_pressed("select"):
		if event is InputEventMouseMotion:
			var vel = Vector3()
			vel.x -= event.relative.x * sensivity
			vel = vel.rotated(Vector3.UP, rotation.y)
			vel.y += event.relative.y * sensivity


			translation += vel
			
	
	elif Input.is_action_pressed("select"):
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x * sensivity
			rotation.x = clamp(rotation.x-event.relative.y * sensivity, -PI/2, PI/2)
	
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_UP:
				zoom = max(0.1, zoom - sensivity * 50)
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom = min(5, zoom + sensivity * 50)



extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var nav: Navigation2D = get_parent().get_node("Navigation2D")
		position = nav.get_closest_point(get_global_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

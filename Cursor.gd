extends KinematicBody2D

# Honorable Mention
# This guy : https://gist.github.com/pwab/fd8bb562604f1d2b967efb6d5e80487d
# This guy for circle radius(Xydium) : https://www.reddit.com/r/godot/comments/5juo09/testing_if_a_point_is_inside_a_shape/
# Static bodies for line segment : https://godotengine.org/qa/67407/adding-collision-detection-to-line2d-collisionpolygon2d
# Closest point on line : https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/

# RayCast, ignore movement not on available line ?

var line := Line2D.new()
onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")
onready var start_pos = puzzle.get_node("1").global_position

func _ready():
	position = get_global_mouse_position()
	line.default_color = "ffffff"
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	get_parent().call_deferred("add_child", line)
	
	
var orientation = Vector2()
var movement = Vector2()

export(float) var cursor_radius = 10
export(float) var speed = 1.5
export(float) var line_point_spacing = 3 # to make points evenly spaced
		
func stepify_orient_vector(vector: Vector2, step=PI/4):
	var step_angle = stepify(vector.angle(), step)
	return Vector2(cos(step_angle), sin(step_angle))

func _physics_process(delta):
	if not solving:
		position = get_global_mouse_position()
	elif movement != Vector2.ZERO:
		movement = stepify_orient_vector(movement)
		var new_position = puzzle.get_move_along_puzzle_path(position, movement, delta*speed)
		if new_position != position:
			orientation = (new_position - position).normalized()
			position = new_position
		
			if puzzle.get_move_dir() == puzzle.MOVE_BACKWARD:
				move_backward()
			else:
				move_forward()


	movement = Vector2.ZERO
	
func move_backward():
	if line.get_point_count() > 1:
		line.remove_point(0)
	
func move_forward():
	line.add_point(position, 0)

# ========== Input ============

var solving = false

func reset_solving():
	solving = false
	line.clear_points()
	
	orientation = Vector2()
	movement = Vector2()
	puzzle.reset_puzzle()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		movement = event.relative.normalized()
	elif not solving and event.is_action_pressed("click") and position.distance_to(start_pos) < 14:
		solving = true
		line.add_point(start_pos, 0)
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		reset_solving()

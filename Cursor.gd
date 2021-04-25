extends Position2D

# Honorable Mention
# This guy : https://gist.github.com/pwab/fd8bb562604f1d2b967efb6d5e80487d
# This guy for circle radius(Xydium) : https://www.reddit.com/r/godot/comments/5juo09/testing_if_a_point_is_inside_a_shape/
# Static bodies for line segment : https://godotengine.org/qa/67407/adding-collision-detection-to-line2d-collisionpolygon2d
# Closest point on line : https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/

# ==========> Init <==============

onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")
onready var start_pos = puzzle.to_global(puzzle.points["1"].position)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	position = Vector2.ZERO
	
# ==========> Movement <==============	

var movement = Vector2()

func _process(delta):
	if not solving:
		position = get_global_mouse_position()
	elif movement != Vector2.ZERO:
		movement = stepify_orient_vector(movement)
		puzzle.move_along_puzzle_path(self, movement, delta)
			
	movement = Vector2.ZERO
	update()
	
func stepify_orient_vector(vector: Vector2, step=PI/4):
	var step_angle = stepify(vector.angle(), step)
	return Vector2(cos(step_angle), sin(step_angle))
	
func _draw():
	draw_circle(Vector2.ZERO, 3, "444444ff")

# ========== Input ============

var solving = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		movement = event.relative.normalized()
	elif not solving and event.is_action_pressed("click") and position.distance_to(start_pos) < 14:
		solving = true
		puzzle.start()
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		solving = false
		puzzle.reset()

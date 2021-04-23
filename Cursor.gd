extends KinematicBody2D

# Honorable Mention
# This guy : https://gist.github.com/pwab/fd8bb562604f1d2b967efb6d5e80487d
# This guy for circle radius(Xydium) : https://www.reddit.com/r/godot/comments/5juo09/testing_if_a_point_is_inside_a_shape/
# Static bodies for line segment : https://godotengine.org/qa/67407/adding-collision-detection-to-line2d-collisionpolygon2d

var line_body := StaticBody2D.new() 
var line := Line2D.new()
onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")
onready var start_pos = puzzle.get_node("1").global_position

func _ready():
	position = get_global_mouse_position()
	line_body.add_child(line)
	get_parent().call_deferred("add_child", line_body)
	line.default_color = "ffffff"
	
var orientation = Vector2()
var line_segments = []
var seg_to_place = []
var global_delta_move = 0
var last_point = Vector2()

export(float) var cursor_radius = 10
export(float) var speed = 150.0
export(float) var line_point_spacing = 3 # to make points evenly spaced

func is_move_backwards():
	if line_segments.size() > 0:
		var slide_count = get_slide_count()
		var collider
		if slide_count:
			collider = get_slide_collision(slide_count - 1).collider
		
		for seg in line_segments.slice(0, 5):
			if collider == seg:
				return true
	return false

func _physics_process(_delta):
	if not solving:
		position = get_global_mouse_position()
	elif not orientation.is_equal_approx(Vector2.ZERO):
		# is not normalized, so perfect, it is the movement distance
		var actual_orient = move_and_slide(orientation.normalized()*speed)
		global_delta_move += (position - last_point).length()
		
		if is_move_backwards():
			move_backward()
			global_delta_move = 0
		elif global_delta_move > line_point_spacing:
			var orthogonal = Vector2(-actual_orient.y, actual_orient.x).normalized()
			var seg = create_segment(last_point, position, position + orthogonal*5, line.get_point_count())
			seg_to_place.append(seg)
			place_queued_segments()
			global_delta_move -= line_point_spacing
			last_point = position

	orientation = Vector2.ZERO
	
func move_backward():
	if line.get_point_count() > 1:
		line_segments[0].queue_free()
		line_segments.remove(0)
		seg_to_place.clear()
		line.remove_point(0)
		last_point = start_pos if line_segments.size() == 0 else line_segments[0].get_child(0).polygon[1]
	
func create_segment(a_point, b_point, c_point, id):
	var seg = StaticBody2D.new()
	seg.position = Vector2(0,0)
	seg.name = "_"+str(id)
	
	var collision = CollisionPolygon2D.new()
	collision.polygon = PoolVector2Array([a_point, b_point, c_point])
	seg.add_child(collision)
	return seg

func place_queued_segments():
	for seg in seg_to_place.duplicate():
		var poly = seg.get_child(0).polygon
		if poly[1].distance_to(position) > cursor_radius:
			line.add_point(poly[1], 0)
			get_parent().add_child(seg)
			line_segments.insert(0, seg)
			seg_to_place.remove(0)
		else:
			break

# ========== Input ============

var solving = false

func reset_solving():
	last_point = Vector2()
	solving = false
	line.clear_points()
	
	# reset segments
	for seg in line_segments + seg_to_place:
		if seg != null:
			seg.queue_free()
	line_segments.clear()
	seg_to_place.clear()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		orientation = event.relative
	elif not solving and event.is_action_pressed("click") and position.distance_to(start_pos) < 3:
		solving = true
		line.add_point(start_pos, 0)
		last_point = start_pos
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		reset_solving()

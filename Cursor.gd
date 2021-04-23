extends KinematicBody2D

onready var line: Line2D = Line2D.new()
var line_segments = []
var collision_shapes = []
var visual = Line2D.new()
onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")

func _ready():
	position = get_global_mouse_position()
	get_parent().call_deferred("add_child", line)
	get_parent().call_deferred("add_child", visual)
	visual.default_color = "#f22f"
	line.default_color = "ffffff"

var orientation = Vector2()
var last_intended_orient = Vector2()
var orthogonal = Vector2()
var last_ortho = Vector2()
var change_angle_count = 0
var threshold_angle_count = 1
var backward = false
var solving = false

export(float) var speed = 150.0
export(float) var cursor_offset = 20

func draw_visual_help(vec):
	visual.clear_points()
	visual.add_point(global_position)
	visual.add_point(visual.points[0] + vec*20)
	
func collision_with_line(body):
	var i = 0
	for seg in line_segments.duplicate():
		if seg.overlaps_body(body):
			seg.queue_free()
			line_segments.remove(i)
			line.remove_point(0)
			print("went back")
		else:
			break
		i += 1
	
func place_segment(from, to):
	var seg = Area2D.new()
	seg.position = Vector2(0,0)
	seg.name = "_"+str(line_segments.size())
	
	var collision = CollisionShape2D.new()
	collision.shape = SegmentShape2D.new()
	collision.shape.a = from
	collision.shape.b = to
	seg.add_child(collision)
	seg.connect("body_entered", self, "collision_with_line")
	get_parent().add_child(seg)
	
	line_segments.insert(0, seg)
	collision_shapes.insert(0, collision)

var point_to_offset = null
var a_point = Vector2()

func _physics_process(delta):
	if not solving:
		translate(orientation)
	elif not orientation.is_equal_approx(Vector2.ZERO):
		
		var actual_orient = move_and_slide(orientation.normalized()*speed)
		var new_orthogonal = Vector2(actual_orient.y, -actual_orient.x)
		#draw_visual_help(new_orthogonal)
			
		if backward and line.get_point_count() > 1:
			line.remove_point(0)
		else:
			line.add_point(position.round(), 0)
			
			if not point_to_offset:
				var distance = a_point.distance_to(position)
				print(distance)
				if distance > cursor_offset:
					point_to_offset = position
			else:
				if a_point.distance_to(position) > cursor_offset * 2:
					place_segment(a_point, point_to_offset)
					a_point = point_to_offset
					point_to_offset = null
			
			

	orientation = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		orientation = get_global_mouse_position() - position
	elif not solving and event.is_action_pressed("click") and close_to("1"):
		backward = false
		solving = true
		line.add_point(puzzle.get_node("1").global_position.round(), 0)
		a_point = line.points[0]
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		solving = false
		line.clear_points()
		visual.clear_points()
		for seg in line_segments:
			seg.free()
		line_segments.clear()
		
func close_to(puzzle_point_id):
	return global_position.distance_to(puzzle.get_node(str(puzzle_point_id)).global_position) < 3





# Ancient stuff we probably don't need anymore
# But you know...
# Just in case
		
var current_seg = Line2D.new()		

func move_along_current_path(delta):
	if orientation != Vector2.ZERO:
		var seg_vec = current_seg.points[1] - current_seg.points[0]
		var trans = orientation.normalized().project(seg_vec)
		move_and_slide(trans*speed)
		
		line.add_point(position.round())
		
func set_current_path(paths):
	var closest_path = paths[0]
	var longest_projection = Vector2()
	for p in paths:
		var vec_path = p.points[1] - p.points[0]
		var projection = orientation.project(vec_path)
		
		# must in the same orientation of path
		# and has the longest projection  amongst available paths
		if projection.sign() == vec_path.sign() and projection.length() > longest_projection.length():
			closest_path = p
			longest_projection = projection
			
	current_seg = closest_path
	
func available_paths():
	for point_id in puzzle.segments.keys():
		if close_to(point_id):
			return puzzle.segments[point_id]


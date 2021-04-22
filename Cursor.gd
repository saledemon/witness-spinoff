extends KinematicBody2D


export(float) var speed = 100.0

var orientation = Vector2()

onready var line: Line2D = Line2D.new()
onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")

var solving = false
var current_seg = Line2D.new()

func close_to(puzzle_point_id):
	return global_position.distance_to(puzzle.get_node(str(puzzle_point_id)).global_position) < 3

func _ready():
	position = Vector2(0, 0)
	get_parent().call_deferred("add_child", line)
	
func available_paths():
	for point_id in puzzle.segments.keys():
		if close_to(point_id):
			return puzzle.segments[point_id]

func set_current_path(paths):
	var closest_path = paths[0]
	var longest_projection = Vector2()
	for p in paths:
		var vec_path = p.points[1] - p.points[0]
		var projection = orientation.project(vec_path)
		
		# must in the same orientaiton of path
		# and has the longest projection  amongst available paths
		if projection.sign() == vec_path.sign() and projection.length() > longest_projection.length():
			closest_path = p
			longest_projection = projection
			
	current_seg = closest_path

func move_along_current_path(delta):
	if orientation != Vector2.ZERO:
		var seg_vec = current_seg.points[1] - current_seg.points[0]
		var trans = orientation.normalized().project(seg_vec)
		move_and_slide(trans*speed)
		line.add_point(position)

func _physics_process(delta):
	if not solving:
		position += orientation
	else:
		var paths = available_paths()
		if paths:
			set_current_path(paths)
		move_along_current_path(delta)
	orientation = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		orientation = get_global_mouse_position() - position
	elif not solving and event.is_action_pressed("click") and close_to("1"):
		solving = true
		line.add_point(position)
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		solving = false
		line.clear_points()


extends Polygon2D

var segments = [
	"1/2",
	"1/5",
	"1/4",
	"2/5",
	"2/3",
	"3/6",
	"4/5",
	"4/7",
	"5/8",
	"5/6",
	"6/9",
	"7/8",
	"8/9",
	"9/10"
]

var points = {}

# =============> Init <================

var line := Line2D.new()

func _ready():
	# initialize empty arrays for every point
	for point in get_children():
		if point.get_class() == "Position2D":
			points[point.name] = PuzzlePoint.new(point.position.round(), point.name)
	
	for seg in segments:
		var point_ids = seg.split('/')
		
		var p0: PuzzlePoint = points[point_ids[0]]
		var p1: PuzzlePoint = points[point_ids[1]]
		
		p0.connect_point(p1)
		p1.connect_point(p0)
	
	line.default_color = "ffffff"
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(line)

func reset():
	current_path = null
	t = 0
	point_trace.clear()
	for p in points:
		points[p].unlock()
	line.clear_points()

func start():
	line.add_point(points["1"].position)
	point_trace.insert(0, points["1"])
			
# =============> Movement <================

var move_dir = FORWARD
const FORWARD = "forward"
const BACKWARD = "backward"

var point_trace = []
var current_path
var length
var t = 0
export(float) var cursor_speed_per_frame = 5
export(float) var collision_dist = 10

func move_along_puzzle_path(cursor: Position2D, orientation, delta):
	
	if not current_path: # set to beginning of puzzle when starting
		set_current_path(determine_path(orientation, points["1"].paths))
		
	var incr = cursor_speed_per_frame * delta / length
	
	if t <= 0 or t >= 1: # means it's on an intersection
		
		var path_end = current_path[1].paths.size() == 1 and t > 1
		var from_paths = current_path[round(t)].paths if not path_end else [current_path, invert_path(current_path)]
		var intended_path = determine_path(orientation, from_paths)

		if point_trace.size() > 1 and intended_path[1] == point_trace[1]: # has gone back
			print("back")
			move_dir = BACKWARD
			if point_trace.size() > 1: # always keep starting point
				point_trace.remove(0)
			set_current_path(invert_path(intended_path))
			t = 1 - incr * 2
		elif path_end:
			print("no move")
			if point_trace[0] != current_path[1]:
				point_trace.insert(0, current_path[1])
			set_current_path(intended_path)
			t = 1.05
		else:
			print("forward")
			print_path(intended_path)
			move_dir = FORWARD
			if t >= 1:
				point_trace.insert(0, current_path[1])
			set_current_path(intended_path)
			t = incr
		#print_trace()
	else: # still on the same path
		var intended_path = determine_path(orientation, [current_path, invert_path(current_path)])
		if intended_path != current_path: # means it's going back
			t -= incr
			move_dir = BACKWARD
		else:
			move_dir = FORWARD
			t += incr
	
	var new_pos = current_path[0].position.linear_interpolate(current_path[1].position, clamp(t, 0, 1))
	
	if current_path[1] in point_trace: # check if there could be a collision
		var dist = new_pos.distance_to(current_path[1].position)
		if  dist < collision_dist:
			t -= incr # cancel move
			return # don't move because too close to collision
	
	if new_pos != to_local(cursor.position):
		update_line(new_pos)
		cursor.position = to_global(new_pos)
	
func update_line(line_head_pos):
	line.clear_points()
	line.add_point(line_head_pos)
	for p in point_trace:
		line.add_point(p.position)
	line.add_point(points["1"].position)

func set_current_path(path):
	current_path = path
	length = (current_path[1].position - current_path[0].position).length()

func determine_path(dir, from_paths):
	var dir_path
	var smallest_angle = PI
	for path in from_paths:
		var angle = abs(dir.angle_to(path[1].position - path[0].position))
		if angle < smallest_angle:
			smallest_angle = angle
			dir_path = path
	return dir_path
	
func invert_path(path):
	return [path[1], path[0]]
	
# ==============> DEBUG <==================

func find_point_by_position(pos):
	for p in points.keys():
		if points[p].position == pos:
			return points[p]
			
func print_path(path):
	print("("+path[0].name+","+path[1].name+")")

func print_trace():
	var trace_str = "trace : "
	for point in point_trace:
		trace_str += "("+point.name+")"
		trace_str += " "
	print(trace_str)
	
func print_locked_points():
	var lockstr = "locked : "
	for p in points:
		if points[p].locked:
			lockstr += p + " "
	print(lockstr)


			

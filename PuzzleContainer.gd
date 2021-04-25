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

func reset_puzzle():
	current_path = null
	t = 0
	path_trace.clear()
	
	for p in points:
		points[p].unlock()
			
# =============> Movement <================

var move_dir = FORWARD
const FORWARD = "forward"
const BACKWARD = "backward"

var path_trace = []
var current_path
var length
var t = 0
export(float) var cursor_speed_per_frame = 5
export(float) var collision_dist = 10

func get_move_along_puzzle_path(pos: Vector2, orientation, delta):
	
	if not current_path: # set to beginning of puzzle when starting
		var start_point = points["1"]
		set_current_path(determine_path(orientation, start_point.paths))
		
	var lock_forward = false
	var incr = cursor_speed_per_frame * delta / length
		
	if current_path[1].locked: # check if should lock forward direction because of collision
		var dist = to_local(pos).distance_to(current_path[1].position)
		lock_forward =  dist < collision_dist
	
	if t < 0 or t > 1: # means it's on an intersection
		
		var path_end = current_path[1].paths.size() == 1 and t > 1
		var from_paths = current_path[round(t)].paths if not path_end else [current_path, invert_path(current_path)]
		var intended_path = determine_path(orientation, from_paths)
	
		if path_trace.size() > 0 and invert_path(intended_path) == path_trace[0]: # has gone back
			print_path(invert_path(intended_path))
			move_back_on_path(invert_path(intended_path))
			t = 1 - incr
		elif path_end:
			if path_trace[0] != current_path:
				path_trace.insert(0, current_path)
			t = 1.05
		else:
			move_to_new_path(intended_path)
			t = incr
		# print_trace()
	else: # still on the same path
		var intended_path = determine_path(orientation, [current_path, invert_path(current_path)])
		if intended_path != current_path: # means it's going back
			t -= incr
			move_dir = BACKWARD
		elif not lock_forward:
			move_dir = FORWARD
			t += incr
	
	return to_global(current_path[0].position.linear_interpolate(current_path[1].position, clamp(t, 0, 1)))
	
func move_to_new_path(new_path):
	move_dir = FORWARD
	if t >= 1:
		if path_trace.size() > 0:
			path_trace[0][0].lock() # lock the third to last (so we can go back)
		path_trace.insert(0, current_path)
	set_current_path(new_path)
	
func move_back_on_path(old_path):
	move_dir = BACKWARD
	path_trace.remove(0)
	if path_trace.size() > 0:
		path_trace[0][0].unlock()
	set_current_path(old_path)
	
func set_current_path(path):
	current_path = path
	length = (current_path[1].position - current_path[0].position).length()

func determine_path(dir, from_paths, min_angle=PI*2):
	var dir_path
	var smallest_angle = min_angle
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
	for path in path_trace:
		trace_str += "("+path[0].name+","+path[1].name+")"
		trace_str += " "
	print(trace_str)
	
func print_locked_points():
	var lockstr = "locked : "
	for p in points:
		if points[p].locked:
			lockstr += p + " "
	print(lockstr)


			

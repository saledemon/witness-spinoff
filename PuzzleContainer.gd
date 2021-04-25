extends Polygon2D

var segments = [
	"1/2",
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

var points = []

var paths = {}

# check for doubled segments
func _ready():
	# initialize empty arrays for every point
	for point in get_children():
		if point.get_class() == "Position2D":
			paths[point.position.round()] = []
			point.position = point.position.round()
			points.append(point)
	
	for seg in segments:
		var points = seg.split('/')
		var pos0 = get_node(points[0]).position.round()
		var pos1 = get_node(points[1]).position.round()
		var dir := PoolVector2Array([pos0, pos1])
		var _dir = invert_path(dir)
		
		paths[pos0].append(dir)
		paths[pos1].append(_dir)

func reset_puzzle():
	current_path = null
	t = 0
	path_trace.clear()
	locked_points.clear()
			
func find_point_by_id(point_id):
	for p in points:
		if p.name == point_id:
			return p
			
func find_point_by_position(pos):
	for p in points:
		if p.position == pos:
			return p

func get_path_for_point(point_id):
	return paths[point_id]

var current_path
var t = 0

func get_orthogonal_to_direction():
	return Vector2(current_path)
	
func invert_path(path):
	return PoolVector2Array([path[1], path[0]])
	
var move_dir = NO_MOVE
const MOVE_FORWARD = "forward"
const MOVE_BACKWARD = "backward"
const NO_MOVE = "no_move"

var path_trace = []
var locked_points = []

func get_move_dir():
	return move_dir

func print_path(path):
	print("("+find_point_by_position(path[0]).name+","+find_point_by_position(path[1]).name+")")

func print_trace():
	var trace_str = "trace : "
	for path in path_trace:
		trace_str += "("+find_point_by_position(path[0]).name+","+find_point_by_position(path[1]).name+")"
		trace_str += " "
	print(trace_str)

func check_collision(with_path):
	var with_inverted_path = invert_path(with_path)
	for p in path_trace:
		if p == with_path or p == with_inverted_path:
			return true
	return false

func get_move_along_puzzle_path(pos: Vector2, orientation, delta):
	t += delta
	
	if not current_path:
		var start_point = find_point_by_id("1").position.round()
		current_path = determine_path(orientation, paths[start_point])
	
	
	
	# means it's on an intersection
	if t <= 0 or t >= 1:
		var intended_path = determine_path(orientation, paths[current_path[round(t)]])
		var invert_intended_path = invert_path(intended_path)
		if path_trace.size() > 0 and invert_intended_path == path_trace[0]:
			move_dir = MOVE_BACKWARD
			path_trace.remove(0)
			#locked_points.remove(0)
			current_path = invert_intended_path
			t = 1 - delta * 3  # added *3 for bigger space, otherwise micro movements fait chier
		else:
			if t >= 1:
				path_trace.insert(0, current_path)
				locked_points.insert(0, current_path[0])
			current_path = intended_path
			t = delta
			move_dir = MOVE_FORWARD
		print_trace()
	else:
		var intended_path = determine_path(orientation, [current_path, invert_path(current_path)])
		
		move_dir = MOVE_FORWARD
		# go back
		if intended_path != current_path:
			t -= delta*2
			move_dir = MOVE_BACKWARD

	# interpolate
	var new_pos = current_path[0].linear_interpolate(current_path[1], clamp(t, 0, 1))
	
	
	# if approaching locked point
	var index = locked_points.find(current_path[1])
	if index >= 0:
		var dist = to_local(pos).distance_to(locked_points[index])
		if dist < 5:
			move_dir = NO_MOVE
			print("no_move")
			return pos
	
	return to_global(new_pos)

func get_collision_with_trace_point(point):
	var locked_points = []
	for path in path_trace:
		for p in path:
			if p == point:
				print(p)
				return true
	return false

func determine_path(dir, from_paths):
	var dir_path
	var smallest_angle = PI
	for path in from_paths:
		var angle = abs(dir.angle_to(path[1] - path[0]))
		if angle < smallest_angle:
			smallest_angle = angle
			dir_path = path
	return dir_path
			
		



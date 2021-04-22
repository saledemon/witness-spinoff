extends Navigation2D

onready var line : Line2D = $SolvingLine
var puzzle_points = PoolVector2Array()

func _ready():
	puzzle_points.append($PuzzlePosition.position)
	for p in $PuzzlePosition.get_children():
		if p.get_class() == "Position2D":
			puzzle_points.append($PuzzlePosition.to_global(p.position))

func puzzle_closest_point(point: Vector2):
	var min_dist = 15
	var closest_point = null
	for p in puzzle_points:
		var dist = (point - p).length()
		if dist < min_dist:
			closest_point = p
			min_dist = dist
	return closest_point
	
func close_to(value: int, desired_values, offset=5):
	for desired_value in desired_values:
		if value < desired_value + offset and value > desired_value - offset:
			return true
	return false

func are_points_connected(p1: Vector2, p2: Vector2):
	
	var angle = int(rad2deg(p2.angle_to_point(p1)))
	print(angle)
	return close_to(angle, [90, 180, -90, -180, 0, 270, -270])

# The "click" event is a custom input action defined in
# Project > Project Settings > Input Map tab.
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		extend_line()
	elif event.is_action_pressed("kill"):
		print("kill line")
		line.clear_points()
		$PuzzlePosition/EndBubble.visible = false
		$PuzzlePosition/BeginBubble.visible = false
			
	#elif event is InputEventMouseMotion && line.points.size() > 0:
	#	extend_line()
		
func extend_line():
	var mpos = get_local_mouse_position()
	var puzzle_point = puzzle_closest_point(mpos)
	if not puzzle_point:
		return
		
	if line.get_point_count() == 0:
		if puzzle_point == $PuzzlePosition.position:
			$PuzzlePosition/BeginBubble.visible = true
			line.add_point(puzzle_point, 0)
		return
	
	var connected = are_points_connected(puzzle_point, line.get_point_position(0))
	if not puzzle_point in line.points:
		if connected:
			line.add_point(puzzle_point, 0)
	else:
		var i = 0
		while line.get_point_position(i) != puzzle_point:
			line.remove_point(0)
			



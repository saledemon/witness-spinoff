extends Line2D

var last_point := Vector2()
var puzzle_points = PoolVector2Array()

func _ready():
	for l in $PuzzlePosition.get_children():
		if l.get_class() == "Line2D":
			puzzle_points.append_array(l.points)

func puzzle_closest_point(point: Vector2):
	var min_dist = 2000
	var closest_point = null
	for p in puzzle_points:
		var dist = (point - p).length()
		if dist < min_dist:
			closest_point = p
			min_dist = dist
	return closest_point

# The "click" event is a custom input action defined in
# Project > Project Settings > Input Map tab.
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		if points.size() == 0:
			print("start line")
			extend_line()
		else:
			print("kill line")
			clear_points()
			
	elif event is InputEventMouseMotion && points.size() > 0:
		extend_line()
		
func extend_line():
	var mpos = $PuzzlePosition.get_local_mouse_position()
	var puzzle_point: Vector2 = puzzle_closest_point(mpos)
	if puzzle_point:
		var global_point = $PuzzlePosition.to_global(puzzle_point)
		if last_point != global_point:
			add_point(global_point)
			last_point = global_point
			print(points)
	
			



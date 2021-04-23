extends KinematicBody2D

var line = Line2D.new()
var visual = Line2D.new()
onready var puzzle: Polygon2D = get_parent().get_node("PuzzleContainer")

func _ready():
	visual.default_color = "red"
	get_parent().call_deferred("add_child", line)
	get_parent().call_deferred("add_child", visual)
	print("Global Pos : "+str(global_position.round()))
		
export(int) var threshold_direction_change = 5
var change_count = 0
var forward = true


var orientation = Vector2()
var last_intended_orient = null
var threshold_angle_count = 1
var change_angle_count = 0

func compute_orientation_change(intended_orient):
	if not last_intended_orient:
		orientation = intended_orient
		last_intended_orient = orientation
		return
		
	if not intended_orient.is_equal_approx(orientation):
		if intended_orient.is_equal_approx(last_intended_orient):
			change_angle_count += 1
		else:
			last_intended_orient = intended_orient
			change_angle_count = 0
			
		if change_angle_count > threshold_angle_count:
			orientation = intended_orient
			last_intended_orient = orientation
			change_angle_count = 0
			# print("orientation changed :" + str(round(rad2deg(orientation.angle()))))
	

var orthogonal = Vector2()

func _physics_process(delta):
	if not solving:
		translate(orientation)
	elif solving and orientation != null and orientation != Vector2.ZERO:
		move_and_slide(orientation * 200)
	orientation = Vector2.ZERO
	
func _process(delta):
	if forward:
		line.add_point(global_position, 0)
	else:
		line.remove_point(0)
		
var solving = false

# add angle and orthogonal vector
# remove points when go back behind vec_plane
func _unhandled_input(event):
	if solving and event is InputEventMouseMotion:
		compute_orientation_change(event.relative.normalized())

		var turn_over_vector = Vector2(-orthogonal.x, -orthogonal.y)
		orthogonal = Vector2(-orientation.y, orientation.x)
		
		if orthogonal.is_equal_approx(turn_over_vector):
			forward = not forward
			print("backward")
			
	elif not solving and event.is_action_pressed("click") and close_to("1"):
		forward = true
		solving = true
		line.add_point(puzzle.get_node("1").global_position.round())
	elif solving and (event.is_action_pressed("kill") or event.is_action_pressed("click")):
		solving = false
		line.clear_points()
		
		# Visual help for orientation, draws the orthogonal
		# visual.clear_points()
		# visual.add_point(get_global_mouse_position())
		# visual.add_point(visual.points[0] + orthogonal*20)
		# print(str(round(rad2deg(orientation.angle_to(orthogonal)))))

func close_to(puzzle_point_id):
	return global_position.distance_to(puzzle.get_node(str(puzzle_point_id)).global_position) < 3

# now try with coloring a line
# and it goes backward
# and it is kind of smooth		
func test3(event):
	if event is InputEventMouseMotion:
		#compute_direction_change(event.relative)
		if not forward: 
			print("backward")
			if line.get_point_count() > 1:
				line.remove_point(0)
		else:
			line.add_point(get_global_mouse_position(), 0)
			
# try with motion	
func test2(event):
	if event is InputEventMouseMotion:
		print(event.relative.y)
		if event.relative.y > 0: 
			print("backward")
	
var first_click	
# static click		
func test1(event):
	if event.is_action_pressed("click"):
		if not first_click:
			first_click = get_global_mouse_position()
		else:
			var mpos = get_global_mouse_position()
			print((mpos - first_click).y)
			if (mpos - first_click).y > 0: 
				print("backward")
			first_click = null
			



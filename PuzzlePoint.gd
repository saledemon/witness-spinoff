class_name PuzzlePoint

var locked := false
var position := Vector2()
var name := ""
var connected_points = []
var paths = []

func _init(pos, id):
	self.position = pos
	self.name = id
	
func lock():
	locked = true
	
func unlock():
	locked = false
	
func connect_point(ppoint):
	connected_points.append(ppoint)
	paths.append([self, ppoint])

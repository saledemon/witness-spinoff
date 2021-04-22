extends Polygon2D

var segments = {
	1: [2, 4],
	2: [1, 3, 5],
	3: [2, 6],
	4: [1, 5, 7],
	5: [4, 2, 6, 8],
	6: [3, 5, 9],
	7: [4, 8],
	8: [7, 5, 9],
	9: [8, 6, 10],
	10: [9]
}

func _ready():
	for point_id in segments.keys():
		var root_pos: Vector2 = get_node(str(point_id)).position
		var vec_pool = []
		for seg in segments[point_id]:
			var seg2d = Line2D.new()
			seg2d.add_point(root_pos)
			seg2d.add_point(get_node(str(seg)).position)
			seg2d.name = str(point_id) + "->" + str(seg)
			vec_pool.append(seg2d)
		segments[point_id] = vec_pool
	print_segments()

func print_segments():
	for key in segments.keys():
		for line in segments[key]:
			print(str(key) + " : " + line.name)


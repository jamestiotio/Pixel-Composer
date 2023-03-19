function _find_polygon_edges(triangles) {
    var polygon = [];
	
    for (var i = 0; i < array_length(triangles); i++) {
        var triangle = triangles[i];
        for (var j = 0; j < 3; j++) {
            var edge_start = triangle[j];
            var edge_end   = triangle[(j + 1) % 3];
            var shared     = false;

            for (var k = 0; k < array_length(triangles); k++) {
				if(k == i) continue;
                if (_shares_edge(triangles[k], edge_start, edge_end)) {
                    shared = true;
                    break;
                }
            }

            if (!shared) {
                array_push(polygon, edge_start);
                array_push(polygon, edge_end);
            }
        }
    }

    return polygon;
}

function _shares_vertex(triangle1, triangle2) {
    for (var i = 0; i < 3; i++)
    for (var j = 0; j < 3; j++) {
        if (triangle1[i].equal(triangle2[j])) 
            return true;
    }
	
    return false;
}

function _shares_edge(triangle, edge_start, edge_end) {
    var count = 0;

    for (var i = 0; i < 3; i++) {
        if (triangle[i].equal(edge_start) || triangle[i].equal(edge_end))
            count++;
    }

    return count == 2;
}

function _create_super_triangle(points) {
    var min_x = points[0].x, max_x = min_x, min_y = points[0].y, max_y = min_y;

    for (var i = 1; i < array_length(points); i++) {
        var point = points[i];
        min_x = min(min_x, point.x);
        max_x = max(max_x, point.x);
        min_y = min(min_y, point.y);
        max_y = max(max_y, point.y);
    }

    var dx = max_x - min_x, dy = max_y - min_y;
    var d_max = max(dx, dy);
    var center_x = (min_x + max_x) / 2, center_y = (min_y + max_y) / 2;

    return [
        new Point(center_x - 2 * d_max, center_y - d_max),
        new Point(center_x, center_y + 2 * d_max),
        new Point(center_x + 2 * d_max, center_y - d_max)
    ];
}

function _triangle_is_ccw(triangle) {
	var a = triangle[0], b = triangle[1], c = triangle[2];
    return ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) > 0;
}

function _point_in_circumcircle(point, triangle) {
    var a = triangle[0], b = triangle[1], c = triangle[2];
	if(!_triangle_is_ccw(triangle)) {
		b = triangle[2];
		c = triangle[1];
	}
	
    // Calculate the determinant
    var ax = a.x - point.x, ay = a.y - point.y;
    var bx = b.x - point.x, by = b.y - point.y;
    var cx = c.x - point.x, cy = c.y - point.y;

    var det = (ax * ax + ay * ay) * (bx * cy - cx * by)
            - (bx * bx + by * by) * (ax * cy - cx * ay)
            + (cx * cx + cy * cy) * (ax * by - bx * ay);

    return det > 0;
}

function array_remove_triangles(arr, target) {
    for (var i = array_length(arr) - 1; i >= 0; i--) {
        var triangle = arr[i];
        var match_count = 0;
		
        for (var j = 0; j < 3; j++)
        for (var k = 0; k < 3; k++) {
            if (triangle[j].equal(target[k])) {
                match_count += 1;
                break;
            }
        }
		
        if (match_count == 3) 
            array_delete(arr, i, 1);
    }
}
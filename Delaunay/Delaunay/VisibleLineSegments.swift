
	
func visibleLineSegments(_ edges:[Edge]) -> [LineSegment]
{
    var segments:[LineSegment] =  [LineSegment]();

    for edge in edges{
        if (edge.visible)
        {
<<<<<<< Updated upstream
            let p1 = edge.clippedVertices[LR.left]!;
            let p2 = edge.clippedVertices[LR.right]!;
=======
            var p1 = edge.clippedVertices[LR.left]!;
            var p2 = edge.clippedVertices[LR.right]!;
>>>>>>> Stashed changes
            segments.append( LineSegment(p0: p1, p1: p2));
        }
    }
    
    return segments;
}

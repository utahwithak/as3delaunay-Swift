
	
func visibleLineSegments(edges:[Edge]) -> [LineSegment]
{
    var segments:[LineSegment] =  [LineSegment]();

    for edge in edges{
        if (edge.visible)
        {
            let p1 = edge.clippedVertices[LR.LEFT]!;
            let p2 = edge.clippedVertices[LR.RIGHT]!;
            segments.append( LineSegment(p0: p1, p1: p2));
        }
    }
    
    return segments;
}

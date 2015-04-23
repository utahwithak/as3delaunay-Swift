
	
func selectEdgesForSitePoint(coord:Point, edgesToTest:[Edge])->[Edge]
{
    return edgesToTest.filter{(edge:Edge) in
          return ((edge.leftSite != nil && edge.leftSite!.coord == coord) ||  (edge.rightSite != nil && edge.rightSite!.coord == coord));
    }
    
}
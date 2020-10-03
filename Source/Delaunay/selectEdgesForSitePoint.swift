
	
func selectEdgesForSitePoint(_ coord:Point, edgesToTest:[Edge])->[Edge] {
    return edgesToTest.filter {
        (($0.leftSite != nil && $0.leftSite!.coord == coord) || ($0.rightSite != nil && $0.rightSite!.coord == coord))
    }
    
}

import Foundation

public final class Site: ICoord, IDisposable, CustomStringConvertible {
    
    fileprivate static var pool:[Site] = [Site]()
    
    public static func create(_ p: Point, index: Int, weight: Double, color: UInt) -> Site {
        if (pool.count > 0) {
            return pool.removeLast().refresh(p, index: index, weight: weight, color: color)
        } else {
            return Site( p: p, index: index, weight: weight, color: color)
        }
    }
    
    static func sortSites(_ sites: inout [Site]) {
        sites.sort(by: Site.compare)
    }
    
    
    /**
     * sort sites on y, then x, coord
     * also change each site's _siteIndex to match its new position in the list
     * so the _siteIndex can be used to identify the site for nearest-neighbor queries
     *
     * haha "also" - means more than one responsibility...
     *
     */
    fileprivate static func compare(_ s1: Site, s2: Site) -> Bool {
        let returnValue = Voronoi.compareByYThenX(s1, s2: s2)
        
        // swap _siteIndex values if necessary to match new ordering:
        var tempIndex: Int
        if (returnValue == -1) {
            if (s1.siteIndex > s2.siteIndex) {
                tempIndex = s1.siteIndex
                s1.siteIndex = s2.siteIndex
                s2.siteIndex = tempIndex
            }
        } else if (returnValue == 1) {
            if (s2.siteIndex > s1.siteIndex) {
                tempIndex = s2.siteIndex
                s2.siteIndex = s1.siteIndex
                s1.siteIndex = tempIndex
            }
            
        }
        
        return returnValue < 0
    }
    
    
    fileprivate static let EPSILON: Double = 0.005
    fileprivate static func closeEnough(_ p0: Point, p1: Point) -> Bool {
        return Point.distance(p0, p1) < EPSILON
    }
    
    public var coord: Point!
    
    var color: UInt = 0
    var weight: Double = 0
    
    fileprivate var siteIndex: Int = 0
    
    /// the edges that define this Site's Voronoi region:
    fileprivate var edges = [Edge]()
    
    /// which end of each edge hooks up with the previous edge in _edges:
    fileprivate var edgeOrientations: [LR]!
    /// ordered list of points that define the region clipped to bounds:
    fileprivate var region = [Point]()
    
    public init( p: Point, index: Int, weight: Double, color: UInt) {
        refresh(p, index: index, weight: weight, color: color)
    }

    @discardableResult
    fileprivate func refresh(_ p: Point, index: Int, weight: Double, color: UInt) -> Site {
        coord = p
        siteIndex = index
        self.weight = weight
        self.color = color
        edges.removeAll(keepingCapacity: true)
        region.removeAll(keepingCapacity: true)
        return self
    }

    public var description:String {
        return "Site \(siteIndex):\(String(describing: coord))"
    }
    
    fileprivate func move(_ p: Point) {
        clear()
        coord = p
    }
    
    public func dispose() {
        coord = nil
        clear()
        Site.pool.append(self)
    }
    
    fileprivate func clear() {
        edges.removeAll(keepingCapacity: true)
        edgeOrientations = nil
        region.removeAll(keepingCapacity: true)
    }
    
    func addEdge(_ edge: Edge) {
        edges.append(edge)
    }
    
    func nearestEdge() -> Edge {
        edges.sort { Edge.compareSitesDistances($0, edge1: $1) < 0 }
        return edges[0]
    }
    
    func neighborSites() -> [Site] {
        if (edges.count == 0) {
            return []
        }
        
        if (edgeOrientations == nil) {
            reorderEdges()
        }
        
        return edges.compactMap { neighborSite($0) }
    }
    
    fileprivate func neighborSite(_ edge: Edge) -> Site? {
        if (self === edge.leftSite) {
            return edge.rightSite
        }
        
        if (self === edge.rightSite) {
            return edge.leftSite
        }
        
        return nil
    }
    
    func region(_ clippingBounds: Rectangle) -> [Point] {
        if (edges.count == 0) {
            return []
        }
        
        if (edgeOrientations == nil) {
            reorderEdges()
            region = clipToBounds(clippingBounds)
            if ((Polygon(vertices: region)).winding() == Winding.clockwise) {
                region = region.reversed()
            }
        }
        
        return region
    }
    
    fileprivate func reorderEdges() {
        //trace("_edges:", _edges)
        let reorderer:EdgeReorderer = EdgeReorderer(origEdges: edges, criterion: .vertex)
        edges = reorderer.edges
        //trace("reordered:", _edges)
        edgeOrientations = reorderer.edgeOrientations
        reorderer.dispose()
    }
    
    fileprivate func clipToBounds(_ bounds: Rectangle) -> [Point] {
        var points = [Point]()
        let n = edges.count
        var i:Int = 0
        var edge: Edge
        
        while (i < n && (edges[i].visible == false)) {
            i += 1
        }
        
        if (i == n) {
            // no edges visible
            return []
        }
        
        edge = edges[i]
        let orientation: LR = edgeOrientations[i]
        points.append(edge.clippedVertices[orientation]!)
        points.append(edge.clippedVertices[LR.other(orientation)]!)
        
        for j in (i + 1)..<n {
            edge = edges[j]
            
            if (edge.visible == false) {
                continue
            }
            
            connect(&points, j: j, bounds: bounds)
        }
        // close up the polygon by adding another corner point of the bounds if needed:
        connect(&points, j: i, bounds: bounds, closingUp: true)
        
        return points
    }
    
    fileprivate func connect(_ points: inout [Point], j: Int, bounds: Rectangle, closingUp: Bool = false) {
        let rightPoint = points[points.count - 1]
        let newEdge = edges[j]
        let newOrientation: LR = edgeOrientations[j]
        
        // the point that  must be connected to rightPoint:
        let newPoint:Point = newEdge.clippedVertices[newOrientation]!
        if (!Site.closeEnough(rightPoint, p1: newPoint)) {
            // The points do not coincide, so they must have been clipped at the bounds
            // see if they are on the same border of the bounds:
            if (rightPoint.x != newPoint.x &&  rightPoint.y != newPoint.y) {
                // They are on different borders of the bounds
                // insert one or two corners of bounds as needed to hook them up:
                // (NOTE this will not be correct if the region should take up more than
                // half of the bounds rect, for then we will have gone the wrong way
                // around the bounds and included the smaller part rather than the larger)
                let rightCheck:Int = BoundsCheck.check(rightPoint, bounds: bounds)
                let newCheck:Int = BoundsCheck.check(newPoint, bounds: bounds)
                var px:Double, py:Double
                if (rightCheck & BoundsCheck.RIGHT != 0) {
                    px = Double(bounds.maxX)
                    
                    if (newCheck & BoundsCheck.BOTTOM != 0) {
                        py = Double(bounds.minY)
                        points.append(Point(x: px, y: py))
                    }
                    else if (newCheck & BoundsCheck.TOP != 0)
                    {
                        py = Double(bounds.maxY)
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.LEFT != 0)
                    {
                        if (rightPoint.y - Double(bounds.y) + newPoint.y - Double(bounds.y) < Double(bounds.height))
                        {
                            py = bounds.maxY
                        }
                        else
                        {
                            py = bounds.minY
                        }
                        points.append(Point(x:px,y: py))
                        points.append(Point(x:bounds.minX,y: py))
                    }
                }
                else if (rightCheck & BoundsCheck.LEFT != 0)
                {
                    px = bounds.minX
                    if (newCheck & BoundsCheck.BOTTOM != 0)
                    {
                        py = bounds.minY
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.TOP != 0)
                    {
                        py = bounds.maxY
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.RIGHT != 0)
                    {
                        if (rightPoint.y - bounds.y + newPoint.y - bounds.y < bounds.height)
                        {
                            py = bounds.maxY
                        }
                        else
                        {
                            py = bounds.minY
                        }
                        points.append(Point(x:px,y: py))
                        points.append(Point(x:bounds.maxX,y: py))
                    }
                }
                else if (rightCheck & BoundsCheck.TOP != 0)
                {
                    py = Double(bounds.maxY)
                    if (newCheck & BoundsCheck.RIGHT != 0)
                    {
                        px = Double(bounds.maxX)
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.LEFT != 0)
                    {
                        px = Double(bounds.minX)
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.BOTTOM != 0)
                    {
                        if (rightPoint.x - Double(bounds.x) + newPoint.x - Double(bounds.x) < Double(bounds.width))
                        {
                            px = Double(bounds.minX)
                        }
                        else
                        {
                            px = Double(bounds.maxX)
                        }
                        points.append(Point(x:px,y: py))
                        points.append(Point(x:px,y: Double(bounds.minY)))
                    }
                }
                else if (rightCheck & BoundsCheck.BOTTOM != 0)
                {
                    py = Double(bounds.minY)
                    if (newCheck & BoundsCheck.RIGHT != 0)
                    {
                        px = Double(bounds.maxX)
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.LEFT != 0)
                    {
                        px = Double(bounds.minX)
                        points.append(Point(x:px,y: py))
                    }
                    else if (newCheck & BoundsCheck.TOP != 0)
                    {
                        if (rightPoint.x - Double(bounds.x) + newPoint.x - Double(bounds.x) < Double(bounds.width))
                        {
                            px = Double(bounds.minX)
                        }
                        else
                        {
                            px = Double(bounds.maxX)
                        }
                        points.append(Point(x:px,y: py))
                        points.append(Point(x:px,y: Double(bounds.maxY)))
                    }
                }
            }
            
            if (closingUp) {
                // newEdge's ends have already been added
                return
            }
            
            points.append(newPoint)
        }
        
        let newRightPoint:Point = newEdge.clippedVertices[LR.other(newOrientation)]!
        
        if (!Site.closeEnough(points[0], p1: newRightPoint)) {
            points.append(newRightPoint)
        }
    }
    
    var x: Double { return coord.x }
    
    var y: Double { return coord.y }
    
    func dist(_ p: ICoord) -> Double {
        return Point.distance(p.coord, coord)
    }
}

open class BoundsCheck {
    public static let TOP:Int = 1
    public static let BOTTOM:Int = 2
    public static let LEFT:Int = 4
    public static let RIGHT:Int = 8
    
    /**
    * 
    * @param point
    * @param bounds
    * @return an int with the appropriate bits set if the Point lies on the corresponding bounds lines
    * 
    */
    public static func check(_ point:Point, bounds:Rectangle)->Int {
        var value: Int = 0
        
        if (point.x == bounds.minX) {
            value |= LEFT
        }
        
        if (point.x == bounds.maxX) {
            value |= RIGHT
        }
        
        if (point.y == bounds.maxY) {
            value |= TOP
        }
        
        if (point.y == bounds.minY) {
            value |= BOTTOM
        }
        
        return value
    }
    
    public init() {
        assert(false, "ILLEGAL TO CREATE ONE!")
    }
    
}

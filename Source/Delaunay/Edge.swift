import Foundation
/**
 * The line segment connecting the two Sites is part of the Delaunay triangulation;
 * the line segment connecting the two Vertices is part of the Voronoi diagram
 * @author ashaw
 *
 */
public final class Edge {
    fileprivate static var pool = [Edge]()
    /**
     * This is the only way to create a new Edge
     * @param site0
     * @param site1
     * @return
     *
     */
    public static func createBisectingEdge(_ site0:Site, site1:Site) -> Edge {
        let dx = site1.x - site0.x
        let dy = site1.y - site0.y
        let absdx = dx > 0 ? dx : -dx
        let absdy = dy > 0 ? dy : -dy
        
        var c = site0.x * dx + site0.y * dy + (dx * dx + dy * dy) * 0.5
        let a: Double
        let b: Double
        
        if (absdx > absdy) {
            a = 1.0
            b = dy / dx
            c /= dx
        } else {
            b = 1.0
            a = dx / dy
            c /= dy
        }
        
        let edge = Edge.create()
        
        edge.leftSite = site0
        edge.rightSite = site1
        site0.addEdge(edge)
        site1.addEdge(edge)
        
        edge.leftVertex = nil
        edge.rightVertex = nil
        
        edge.a = a
        edge.b = b
        edge.c = c
        
        return edge
    }
    
    fileprivate static func create() -> Edge {
        var edge: Edge
        
        if (pool.count > 0) {
            edge = pool.removeLast()
            edge.refresh()
        } else {
            edge = Edge()
        }
        
        return edge
    }
    
    public var delaunayLine: LineSegment {
        // draw a line connecting the input Sites for which the edge is a bisector:
        return LineSegment(p0: leftSite!.coord, p1: rightSite!.coord)
    }
    
    public func voronoiEdge() -> LineSegment {
        if (!visible) {
            return LineSegment()
        }
        return  LineSegment(p0: clippedVertices[LR.left]!, p1: clippedVertices[LR.right]!)
    }
    
    fileprivate static var nedges: Int = 0
    
    static let zero = Edge()
    
    // the equation of the edge: ax + by = c
    var a: Double = 0, b: Double = 0, c: Double = 0
    
    // the two Voronoi vertices that the edge connects
    //		(if one of them is nil, the edge extends to infinity)
    var leftVertex: Vertex? = nil
    var rightVertex: Vertex? = nil
    
    func vertex(_ leftRight:LR) -> Vertex {
        assert(leftRight != .unknown, "INVALID SET VERT!")
        
        return (leftRight == LR.left) ? leftVertex! : rightVertex!
    }
    
    func setVertex(_ leftRight: LR, v: Vertex) {
        assert(leftRight != .unknown, "INVALID SET VERT!")
        
        if (leftRight == LR.left) {
            leftVertex = v
        } else {
            rightVertex = v
        }
    }
    
    func isPartOfConvexHull() -> Bool {
        return (leftVertex == nil || rightVertex == nil)
    }
    
    public func sitesDistance() -> Double {
        return Point.distance(leftSite!.coord, rightSite!.coord)
    }
    
    public static func compareSitesDistancesMAX(_ edge0: Edge, edge1: Edge) -> Int {
        let length0 = edge0.sitesDistance()
        let length1 = edge1.sitesDistance()
        
        if (length0 < length1) {
            return 1
        }
        
        if (length0 > length1) {
            return -1
        }
        
        return 0
    }
    
    public static func compareSitesDistances(_ edge0: Edge, edge1: Edge) -> Int {
        return -1 * compareSitesDistancesMAX(edge0, edge1: edge1)
    }
    
    // Once clipVertices() is called, this Dictionary will hold two Points
    // representing the clipped coordinates of the left and right ends...
    public var clippedVertices: [LR: Point]!
    
    // unless the entire Edge is outside the bounds.
    // In that case visible will be false:
    var visible: Bool {
        return clippedVertices != nil
    }
    
    var leftSite: Site!
    var rightSite: Site!
    
    func site(_ leftRight: LR) -> Site {
        switch (leftRight) {
        case .left: return leftSite
        case .right: return rightSite
        case .unknown: assert(false, "INVALID SITE!")
        }
    }
    
    fileprivate let edgeIndex: Int
    
    public func dispose() {
        leftVertex = nil
        rightVertex = nil
        clippedVertices = nil
        leftSite = nil
        rightSite = nil
        Edge.pool.append(self)
    }
    
    public init() {
        edgeIndex = Edge.nedges
        Edge.nedges += 1
        refresh()
    }
    
    fileprivate func refresh() {
        leftSite = nil
        rightSite = nil
    }
    
    public var description: String {
        let lVert = leftVertex != nil ? "\(leftVertex!.vertexIndex)" : "nil"
        let rVert = rightVertex != nil ? "\(rightVertex!.vertexIndex)" : "nil"
        return "Edge \(edgeIndex); sites \(leftSite!), \(rightSite!); endVertices \(lVert), \(rVert)::"
    }
    
    /**
     * Set clippedVertices to contain the two ends of the portion of the Voronoi edge that is visible
     * within the bounds.  If no part of the Edge falls within the bounds, leave clippedVertices nil.
     * @param bounds
     *
     */
    func clipVertices(_ bounds: Rectangle) {
        let xmin = bounds.minX
        let ymin = bounds.minY
        let xmax = bounds.maxX
        let ymax = bounds.maxY
        
        var x0:Double, x1:Double, y0:Double, y1:Double
        
        
        let vertex0: Vertex?
        let vertex1: Vertex?
        
        if (a == 1.0 && b >= 0.0) {
            vertex0 = rightVertex
            vertex1 = leftVertex
        } else {
            vertex0 = leftVertex
            vertex1 = rightVertex
        }
        
        if (a == 1.0) {
            y0 = ymin
            if (vertex0 != nil && vertex0!.y > ymin) {
                y0 = vertex0!.y
            }
            if (y0 > ymax) {
                return
            }
            x0 = c - b * y0
            
            y1 = ymax
            if (vertex1 != nil && vertex1!.y < ymax) {
                y1 = vertex1!.y
            }
            
            if (y1 < ymin) {
                return
            }
            
            x1 = c - b * y1
            
            if ((x0 > xmax && x1 > xmax) || (x0 < xmin && x1 < xmin)) {
                return
            }
            
            if (x0 > xmax) {
                x0 = xmax
                y0 = (c - x0) / b
            } else if (x0 < xmin) {
                x0 = xmin
                y0 = (c - x0) / b
            }
            
            if (x1 > xmax) {
                x1 = xmax
                y1 = (c - x1) / b
            } else if (x1 < xmin) {
                x1 = xmin
                y1 = (c - x1) / b
            }
        } else {
            x0 = xmin
            if (vertex0 != nil && vertex0!.x > xmin) {
                x0 = vertex0!.x
            }
            
            if (x0 > xmax) {
                return
            }
            y0 = c - a * x0
            
            x1 = xmax
            if (vertex1 != nil && vertex1!.x < xmax) {
                x1 = vertex1!.x
            }
            
            if (x1 < xmin) {
                return
            }
            
            y1 = c - a * x1
            
            if ((y0 > ymax && y1 > ymax) || (y0 < ymin && y1 < ymin)) {
                return
            }
            
            if (y0 > ymax) {
                y0 = ymax
                x0 = (c - y0) / a
            } else if (y0 < ymin) {
                y0 = ymin
                x0 = (c - y0) / a
            }
            
            if (y1 > ymax) {
                y1 = ymax
                x1 = (c - y1) / a
            } else if (y1 < ymin) {
                y1 = ymin
                x1 = (c - y1) / a
            }
        }
        
        clippedVertices = [LR:Point]()
        if (vertex0 === leftVertex) {
            clippedVertices[LR.left] = Point(x: x0, y: y0)
            clippedVertices[LR.right] = Point(x: x1, y: y1)
        } else {
            clippedVertices[LR.right] = Point(x: x0, y: y0)
            clippedVertices[LR.left] = Point(x: x1, y: y1)
        }
    }
}

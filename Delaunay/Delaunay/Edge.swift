import Foundation
/**
* The line segment connecting the two Sites is part of the Delaunay triangulation;
* the line segment connecting the two Vertices is part of the Voronoi diagram
* @author ashaw
*
*/
public final class Edge
{
    private static var pool = [Edge]()
    /**
    * This is the only way to create a new Edge
    * @param site0
    * @param site1
    * @return
    *
    */
    public static func createBisectingEdge(site0:Site, site1:Site)->Edge
    {
        
        let dx = site1.x - site0.x;
        let dy = site1.y - site0.y;
        let absdx = dx > 0 ? dx : -dx;
        let absdy = dy > 0 ? dy : -dy;

        var c = site0.x * dx + site0.y * dy + (dx * dx + dy * dy) * 0.5;
        let a:Double
        let b:Double
        if (absdx > absdy)
        {
            a = 1.0;
            b = dy / dx;
            c /= dx;
        }
        else
        {
            b = 1.0;
            a = dx / dy;
            c /= dy;
        }
        
        let edge = Edge.create();
        
        edge.leftSite = site0;
        edge.rightSite = site1;
        site0.addEdge(edge);
        site1.addEdge(edge);
        
        edge.leftVertex = nil;
        edge.rightVertex = nil;
        
        edge.a = a;
        edge.b = b;
        edge.c = c;
        //trace("createBisectingEdge: a ", edge.a, "b", edge.b, "c", edge.c);
        return edge;
    }
    
    private static func create()->Edge
    {
        var edge:Edge;
        if (pool.count > 0)
        {
            edge = pool.removeLast()
            edge.refresh();
        }
        else
        {
            edge = Edge();
        }
        return edge;
    }
    
    //		private static let LINESPRITE:Sprite =  Sprite();
    //		private static let GRAPHICS:Graphics = LINESPRITE.graphics;
    //
    //		private var delaunayLineBmp:BitmapData;
    //		func get delaunayLineBmp()->BitmapData
    //		{
    //			if (!delaunayLineBmp)
    //			{
    //				delaunayLineBmp = makeDelaunayLineBmp();
    //			}
    //			return delaunayLineBmp;
    //		}
    //
    //		// making this available to Voronoi; running out of memory in AIR so I cannot cache the bmp
    //		func makeDelaunayLineBmp()->BitmapData
    //		{
    //			var p0:Point = leftSite.coord;
    //			var p1:Point = rightSite.coord;
    //
    //			GRAPHICS.clear();
    //			// clear() resets line style back to undefined!
    //			GRAPHICS.lineStyle(0, 0, 1.0, false, LineScaleMode.NONE, CapsStyle.NONE);
    //			GRAPHICS.moveTo(p0.x, p0.y);
    //			GRAPHICS.lineTo(p1.x, p1.y);
    //
    //			var w:Int = int(Math.ceil(Math.max(p0.x, p1.x)));
    //			if (w < 1)
    //			{
    //				w = 1;
    //			}
    //			var h:Int = int(Math.ceil(Math.max(p0.y, p1.y)));
    //			if (h < 1)
    //			{
    //				h = 1;
    //			}
    //			var bmp:BitmapData = new BitmapData(w, h, true, 0);
    //			bmp.draw(LINESPRITE);
    //			return bmp;
    //		}
    //
    public var delaunayLine:LineSegment
    {
        // draw a line connecting the input Sites for which the edge is a bisector:
        return LineSegment(p0: leftSite!.coord, p1: rightSite!.coord);
    }
    
    public func voronoiEdge()->LineSegment
    {
        if (!visible){
            return LineSegment();
        }
        return  LineSegment(p0:clippedVertices[LR.LEFT]!, p1:clippedVertices[LR.RIGHT]!);
    }
    
    private static var nedges:Int = 0;
    
    static let DELETED:Edge = Edge();
    
    // the equation of the edge: ax + by = c
    var a:Double = 0, b:Double = 0, c:Double = 0;
    
    // the two Voronoi vertices that the edge connects
    //		(if one of them is nil, the edge extends to infinity)
    var leftVertex:Vertex? = nil;
    var rightVertex:Vertex? = nil;
    
    func vertex(leftRight:LR)->Vertex
    {
        assert(leftRight != .Unknown, "INVALID SET VERT!")

        return (leftRight == LR.LEFT) ? leftVertex! : rightVertex!;
    }
    func setVertex(leftRight:LR, v:Vertex)
    {
        assert(leftRight != .Unknown, "INVALID SET VERT!")
        if (leftRight == LR.LEFT)
        {
            leftVertex = v;
        }
        else
        {
            rightVertex = v;
        }
    }
    
    func isPartOfConvexHull()->Bool
    {
        return (leftVertex == nil || rightVertex == nil);
    }
    
    public func sitesDistance()->Double
    {
        return Point.distance(leftSite!.coord, rightSite!.coord);
    }
    //
    public static func compareSitesDistancesMAX(edge0:Edge, edge1:Edge)->Int
    {
        let length0:Double = edge0.sitesDistance();
        let length1:Double = edge1.sitesDistance();
        if (length0 < length1)
        {
            return 1;
        }
        if (length0 > length1)
        {
            return -1;
        }
        return 0;
    }
    
    public static func compareSitesDistances(edge0:Edge, edge1:Edge)->Int
    {
        return -1 * compareSitesDistancesMAX(edge0, edge1:edge1);
    }
    //
    //		// Once clipVertices() is called, this Dictionary will hold two Points
    //		// representing the clipped coordinates of the left and right ends...
    public var clippedVertices:[LR:Point]!
    
    //		// unless the entire Edge is outside the bounds.
    //		// In that case visible will be false:
    var visible:Bool{
        return clippedVertices != nil;
    }

    var leftSite:Site!
    var rightSite:Site!
    var tempSite:Site!
    func site(leftRight:LR)->Site
    {
        switch (leftRight)
        {
        case .LEFT:
            tempSite = leftSite
        case .RIGHT:
            tempSite = rightSite
        case .Unknown:
            assert(false, "INVALID SITE!")
        }
        return tempSite
    }
    //
    private let edgeIndex:Int;
    //
    public func dispose()
    {
        //			if (delaunayLineBmp)
        //			{
        //				delaunayLineBmp.dispose();
        //				delaunayLineBmp = nil;
        //			}
        leftVertex = nil;
        rightVertex = nil;
        clippedVertices = nil
        leftSite = nil;
        rightSite = nil
        Edge.pool.append(self);
    }
    
    public init()
    {
        edgeIndex = Edge.nedges + 1;
        refresh();
    }
    //
    private func refresh()
    {
        leftSite = nil;
        rightSite = nil
    }
    
    public var description:String{
        let lVert = leftVertex != nil ? "\(leftVertex!.vertexIndex)" : "nil"
        let rVert = rightVertex != nil ? "\(rightVertex!.vertexIndex)" : "nil"
    	return "Edge \(edgeIndex); sites \(leftSite), \(rightSite); endVertices \(lVert), \(rVert)::";
    }
    
    /**
    * Set clippedVertices to contain the two ends of the portion of the Voronoi edge that is visible
    * within the bounds.  If no part of the Edge falls within the bounds, leave clippedVertices nil.
    * @param bounds
    *
    */
    func clipVertices(bounds:Rectangle)
    {
        let xmin = Double(bounds.minX)
        let ymin = Double(bounds.minY)
        let xmax = Double(bounds.maxX)
        let ymax = Double(bounds.maxY)

        var x0:Double, x1:Double, y0:Double, y1:Double;
        
        
        let vertex0:Vertex?
        let vertex1:Vertex?;

        if (a == 1.0 && b >= 0.0){
            vertex0 = rightVertex;
            vertex1 = leftVertex;
        }
        else{
            vertex0 = leftVertex;
            vertex1 = rightVertex;
        }
        
        if (a == 1.0) {
            y0 = ymin;
            if (vertex0 != nil && vertex0!.y > ymin) {
                y0 = vertex0!.y;
            }
            if (y0 > ymax) {
                return;
            }
            x0 = c - b * y0;
            
            y1 = ymax;
            if (vertex1 != nil && vertex1!.y < ymax) {
                y1 = vertex1!.y;
            }
            if (y1 < ymin) {
                return;
            }
            x1 = c - b * y1;
            
            if ((x0 > xmax && x1 > xmax) || (x0 < xmin && x1 < xmin)){
                return;
            }
            
            if (x0 > xmax){
                x0 = xmax;
                y0 = (c - x0)/b;
            }
            else if (x0 < xmin){
                x0 = xmin;
                y0 = (c - x0)/b;
            }
            
            if (x1 > xmax){
                x1 = xmax;
                y1 = (c - x1)/b;
            }
            else if (x1 < xmin){
                x1 = xmin;
                y1 = (c - x1)/b;
            }
        }
        else{
            x0 = xmin;
            if (vertex0 != nil && vertex0!.x > xmin){
                x0 = vertex0!.x;
            }
            if (x0 > xmax){
                return;
            }
            y0 = c - a * x0;
            
            x1 = xmax;
            if (vertex1 != nil && vertex1!.x < xmax){
                x1 = vertex1!.x;
            }
            if (x1 < xmin){
                return;
            }
            y1 = c - a * x1;
            
            if ((y0 > ymax && y1 > ymax) || (y0 < ymin && y1 < ymin))
            {
                return;
            }
            
            if (y0 > ymax)
            {
                y0 = ymax;
                x0 = (c - y0)/a;
            }
            else if (y0 < ymin)
            {
                y0 = ymin;
                x0 = (c - y0)/a;
            }
            
            if (y1 > ymax)
            {
                y1 = ymax;
                x1 = (c - y1)/a;
            }
            else if (y1 < ymin)
            {
                y1 = ymin;
                x1 = (c - y1)/a;
            }
        }
        
        clippedVertices = [LR:Point]()
        if (vertex0 === leftVertex)
        {
            clippedVertices[LR.LEFT] = Point(x: x0, y: y0);
            clippedVertices[LR.RIGHT] = Point(x: x1, y: y1);
        }
        else
        {
            clippedVertices[LR.RIGHT] = Point(x: x0, y: y0);
            clippedVertices[LR.LEFT] = Point(x: x1, y: y1);
        }
    }
}
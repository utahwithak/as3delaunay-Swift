import Foundation

public final class Halfedge:CustomStringConvertible{
<<<<<<< Updated upstream
    fileprivate static var pool:[Halfedge] = [Halfedge]();

    public static func create(_ edge:Edge?, lr:LR)->Halfedge
    {
        if (pool.count > 0)
        {
            let last = pool.removeLast()
            return last.reset(edge, lr: lr);
        }
        else
        {
            return Halfedge(edge: edge, lr: lr);
        }
    }

    public static func createDummy()->Halfedge
    {
        return create(nil, lr:.unknown);
    }
=======
		fileprivate static var pool:[Halfedge] = [Halfedge]();
    
		public static func create(_ edge:Edge?, lr:LR)->Halfedge
		{
			if (pool.count > 0)
			{
                let last = pool.removeLast()
				return last.reset(edge, lr: lr);
			}
			else
			{
				return Halfedge(edge: edge, lr: lr);
			}
		}

        public static func createDummy()->Halfedge
		{
			return create(nil, lr:.unknown);
		}

		public var edgeListLeftNeighbor:Halfedge? = nil
        public var edgeListRightNeighbor:Halfedge? = nil
		public var nextInPriorityQueue:Halfedge? = nil;
		
		public var edge:Edge!;
		public var leftRight:LR = .unknown;
		public var vertex:Vertex? = nil;
>>>>>>> Stashed changes

    public var edgeListLeftNeighbor:Halfedge?
    public var edgeListRightNeighbor:Halfedge?
    public var nextInPriorityQueue:Halfedge?
    
    public var edge:Edge!;
    public var leftRight:LR = .unknown;
    public var vertex:Vertex?

<<<<<<< Updated upstream
    // the vertex's y-coordinate in the transformed Voronoi space V*
    public var ystar:Double = 0;

    public init(edge:Edge? = nil, lr:LR = .unknown)
    {
        reset(edge, lr: lr);
    }

    @discardableResult
    public func reset(_ edge:Edge?, lr:LR)->Halfedge{
        self.edge = edge;
        leftRight = lr;
        nextInPriorityQueue = nil;
        vertex = nil;
        return self
    }

    public var description:String
    {
        return "Halfedge (leftRight: \(leftRight); vertex: \(vertex))";
    }
    
    public func dispose()
    {
        if (edgeListLeftNeighbor != nil || edgeListRightNeighbor != nil)
=======
		public init(edge:Edge? = nil, lr:LR = .unknown)
		{
			reset(edge, lr: lr);
		}

        public func reset(_ edge:Edge?, lr:LR)->Halfedge{
            self.edge = edge;
            leftRight = lr;
            nextInPriorityQueue = nil;
            vertex = nil;
            return self
        }

        public var description:String
		{
			return "Halfedge (leftRight: \(leftRight); vertex: \(vertex))";
		}
		
		public func dispose()
		{
			if (edgeListLeftNeighbor != nil || edgeListRightNeighbor != nil)
			{
				// still in EdgeList
				return;
			}
			if (nextInPriorityQueue != nil)
			{
				// still in PriorityQueue
				return;
			}
			edge = nil;
			leftRight = .unknown;
			vertex = nil;
			Halfedge.pool.append(self);
		}
		
		public func reallyDispose()
		{
			edgeListLeftNeighbor = nil;
			edgeListRightNeighbor = nil;
			nextInPriorityQueue = nil;
			edge = nil;
			leftRight = .unknown;
			vertex = nil;
            Halfedge.pool.append(self);
		}

		func isLeftOf(_ p:Point)->Bool
>>>>>>> Stashed changes
        {
            // still in EdgeList
            return;
        }
        if (nextInPriorityQueue != nil)
        {
            // still in PriorityQueue
            return;
        }
        edge = nil;
        leftRight = .unknown;
        vertex = nil;
        Halfedge.pool.append(self);
    }
    
    public func reallyDispose()
    {
        edgeListLeftNeighbor = nil;
        edgeListRightNeighbor = nil;
        nextInPriorityQueue = nil;
        edge = nil;
        leftRight = .unknown;
        vertex = nil;
        Halfedge.pool.append(self);
    }

    func isLeftOf(_ p:Point)->Bool
    {

<<<<<<< Updated upstream
        var above:Bool
        
        let topSite = edge.rightSite!;
        let rightOfSite = p.x > topSite.x;
        
        if (rightOfSite && leftRight == LR.left)
        {
            return true;
        }
        if (!rightOfSite && leftRight == LR.right)
        {
            return false;
        }
        
        if (edge!.a == 1.0)
        {
            let dyp = p.y - topSite.y;
            let dxp = p.x - topSite.x;
            var fast = false;
            if ((!rightOfSite && edge.b < 0.0) || (rightOfSite && edge.b >= 0.0) )
            {
                above = dyp >= edge.b * dxp;
                fast = above;
            }
            else 
            {
                above = p.x + p.y * edge.b > edge!.c;
                if (edge.b < 0.0)
                {
                    above = !above;
                }
                if (!above)
                {
                    fast = true;
                }
            }
            if (!fast)
            {
                let dxs = topSite.x - edge.leftSite!.x;
                let lhs = edge.b * (dxp * dxp - dyp * dyp)
                let rhs =  dxs * dyp * (1.0 + 2.0 * dxp/dxs + edge!.b * edge!.b)
                above =  lhs < rhs
                if (edge!.b < 0.0)
                {
                    above = !above;
                }
            }
        }
        else  /* edge.b == 1.0 */
        {
            let yl = edge.c - edge.a * p.x;
            let t1 = p.y - yl;
            let t2 = p.x - topSite.x;
            let t3 = yl - topSite.y;
            above = t1 * t1 > t2 * t2 + t3 * t3;
        }
        return leftRight == LR.left ? above : !above;
    }
=======
			var above:Bool
			
			let topSite = edge.rightSite!;
			let rightOfSite = p.x > topSite.x;
            
			if (rightOfSite && leftRight == LR.left)
			{
				return true;
			}
			if (!rightOfSite && leftRight == LR.right)
			{
				return false;
			}
			
			if (edge!.a == 1.0)
			{
				let dyp = p.y - topSite.y;
				let dxp = p.x - topSite.x;
				var fast = false;
				if ((!rightOfSite && edge.b < 0.0) || (rightOfSite && edge.b >= 0.0) )
				{
					above = dyp >= edge.b * dxp;
					fast = above;
				}
				else 
				{
					above = p.x + p.y * edge.b > edge!.c;
					if (edge.b < 0.0)
					{
						above = !above;
					}
					if (!above)
					{
						fast = true;
					}
				}
				if (!fast)
				{
					let dxs = topSite.x - edge.leftSite!.x;
					above = edge.b * (dxp * dxp - dyp * dyp) <
					        dxs * dyp * (1.0 + 2.0 * dxp/dxs + edge!.b * edge!.b);
					if (edge!.b < 0.0)
					{
						above = !above;
					}
				}
			}
			else  /* edge.b == 1.0 */
			{
				let yl = edge.c - edge.a * p.x;
				let t1 = p.y - yl;
				let t2 = p.x - topSite.x;
				let t3 = yl - topSite.y;
				above = t1 * t1 > t2 * t2 + t3 * t3;
			}
			return leftRight == LR.left ? above : !above;
		}
>>>>>>> Stashed changes

}

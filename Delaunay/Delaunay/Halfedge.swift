import Foundation

public final class Halfedge:CustomStringConvertible{
		private static var pool:[Halfedge] = [Halfedge]();
    
		public static func create(edge:Edge?, lr:LR)->Halfedge
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
			return create(nil, lr:.Unknown);
		}

		public var edgeListLeftNeighbor:Halfedge? = nil
        public var edgeListRightNeighbor:Halfedge? = nil
		public var nextInPriorityQueue:Halfedge? = nil;
		
		public var edge:Edge!;
		public var leftRight:LR = .Unknown;
		public var vertex:Vertex? = nil;

		// the vertex's y-coordinate in the transformed Voronoi space V*
		public var ystar:Double = 0;

		public init(edge:Edge? = nil, lr:LR = .Unknown)
		{
			reset(edge, lr: lr);
		}

        public func reset(edge:Edge?, lr:LR)->Halfedge{
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
			leftRight = .Unknown;
			vertex = nil;
			Halfedge.pool.append(self);
		}
		
		public func reallyDispose()
		{
			edgeListLeftNeighbor = nil;
			edgeListRightNeighbor = nil;
			nextInPriorityQueue = nil;
			edge = nil;
			leftRight = .Unknown;
			vertex = nil;
            Halfedge.pool.append(self);
		}

		func isLeftOf(p:Point)->Bool
        {

			var above:Bool
			
			let topSite = edge.rightSite!;
			let rightOfSite = p.x > topSite.x;
            
			if (rightOfSite && leftRight == LR.LEFT)
			{
				return true;
			}
			if (!rightOfSite && leftRight == LR.RIGHT)
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
			return leftRight == LR.LEFT ? above : !above;
		}

}
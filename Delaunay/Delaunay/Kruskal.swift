import Foundation
/**
*  Kruskal's spanning tree algorithm with union-find
 * Skiena: The Algorithm Design Manual, p. 196ff
 * Note: the sites are implied: they consist of the end points of the line segments
*/

public enum SpanningType{
    case Minimum
    case Maximum
}

public func Kruskal(lineSegs:[LineSegment], type:SpanningType = .Minimum)->[LineSegment]
{
    var lineSegments = lineSegs
    var nodes = [Point:Node]()
    var mst:[LineSegment] = [LineSegment]();
    var nodePool:[Node] = Node.pool;

    switch (type)
    {
        // note that the compare funcs are the reverse of what you'd expect
        // because (see below) we traverse the lineSegments in reverse order for speed
        case .Maximum:
            lineSegments.sort{ return LineSegment.compareLengths($0,edge1: $1) < 0;}
        default:
            lineSegments.sort{return LineSegment.compareLengths_MAX($0,segment1: $1) < 0;}
    }

    for (var i:Int = lineSegments.count - 1; i > -1; i--)
    {
        var lineSegment:LineSegment = lineSegments[i];
        
        var node0:Node? = nodes[lineSegment.p0];
        var rootOfSet0:Node;
        if (node0 == nil)
        {
            node0 = nodePool.count > 0 ? nodePool.last : Node();
            // intialize the node:
            node0!.parent = node0;
            rootOfSet0 = node0!
            node0!.treeSize = 1;
        
            nodes[lineSegment.p0] = node0;
        }
        else
        {
            rootOfSet0 = find(node0!);
        }
        
        var node1:Node? = nodes[lineSegment.p1];
        var rootOfSet1:Node;
        if (node1 == nil)
        {
            node1 = nodePool.count > 0 ? nodePool.removeLast() :  Node();
            // intialize the node:
            node1!.parent = node1;
            rootOfSet1 = node1!
            node1!.treeSize = 1;
        
            nodes[lineSegment.p1] = node1;
        }
        else
        {
            rootOfSet1 = find(node1!);
        }
        
        if (rootOfSet0 !== rootOfSet1)	// nodes not in same set
        {
            mst.append(lineSegment);
            
            // merge the two sets:
            var treeSize0:Int = rootOfSet0.treeSize;
            var treeSize1:Int = rootOfSet1.treeSize;
            if (treeSize0 >= treeSize1)
            {
                // set0 absorbs set1:
                rootOfSet1.parent = rootOfSet0;
                rootOfSet0.treeSize += treeSize1;
            }
            else
            {
                // set1 absorbs set0:
                rootOfSet0.parent = rootOfSet1;
                rootOfSet1.treeSize += treeSize0;
            }
        }
    }
    
    for (point,node) in nodes{
        nodePool.append(node);
    }

    return mst;

}

func find(node:Node)->Node
{
	if (node.parent === node)
	{
		return node;
	}
	else
	{
		var root = find(node.parent!);
		// this line is just to speed up subsequent finds by keeping the tree depth low:
		node.parent = root;
		return root;
	}
}

class Node
{
    static var pool = [Node]();

    var parent:Node!
    var treeSize:Int = 0;
	init() {
    }
}

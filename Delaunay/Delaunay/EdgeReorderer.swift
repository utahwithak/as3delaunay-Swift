import Foundation

public class EdgeReorderer{
    var edges:[Edge];
    var edgeOrientations:[LR];
    
    public enum Criteria{
        case Vertex
        case Site
    }
    public init(origEdges:[Edge], criterion:Criteria)
    {
        edges =  [Edge]();
        edgeOrientations = [LR]();
        if (origEdges.count > 0)
        {
            edges = reorderEdges(origEdges, criterion: criterion);
        }
    }
    //
    public func dispose()
    {
        edges.removeAll(keepCapacity: false)
        edgeOrientations.removeAll(keepCapacity: false)
    }
    
    private func reorderEdges(origEdges:[Edge], criterion:Criteria)->[Edge]
    {
        var i:Int = 0;
        var j:Int;
        var n:Int = origEdges.count;
        // we're going to reorder the edges in order of traversal
        var done = [Bool](count:n, repeatedValue:false);
        var nDone = 0;
        var newEdges = [Edge]();
        
        let useVert = criterion == Criteria.Vertex
        
        var edge = origEdges[i];
        newEdges.append(edge);
        edgeOrientations.append(LR.LEFT);
        var firstPoint:ICoord? = useVert ? edge.leftVertex : edge.leftSite;
        var lastPoint:ICoord?  = useVert ? edge.rightVertex : edge.rightSite;
        
        if (firstPoint === Vertex.VERTEX_AT_INFINITY || lastPoint === Vertex.VERTEX_AT_INFINITY)
        {
            return [Edge]();
        }
        
        done[i] = true;
        ++nDone;
        
        while (nDone < n)
        {
            for (i = 1; i < n; ++i)
            {
                if (done[i])
                {
                    continue;
                }
                edge = origEdges[i];
                var leftPoint:ICoord? = useVert ? edge.leftVertex : edge.leftSite;
                var rightPoint:ICoord? = useVert ? edge.rightVertex : edge.rightSite;
                if (leftPoint === Vertex.VERTEX_AT_INFINITY || rightPoint === Vertex.VERTEX_AT_INFINITY)
                {
                    return [Edge]();
                }
                if (leftPoint === lastPoint)
                {
                    lastPoint = rightPoint;
                    edgeOrientations.append(LR.LEFT);
                    newEdges.append(edge);
                    done[i] = true;
                }
                else if (rightPoint === firstPoint)
                {
                    firstPoint = leftPoint;
                    edgeOrientations.insert(LR.LEFT, atIndex: 0);
                    newEdges.insert(edge,atIndex:0);
                    done[i] = true;
                }
                else if (leftPoint === firstPoint)
                {
                    firstPoint = rightPoint;
                    edgeOrientations.insert(LR.RIGHT, atIndex:0);
                    newEdges.insert(edge, atIndex: 0)
                    done[i] = true;
                }
                else if (rightPoint === lastPoint)
                {
                    lastPoint = leftPoint;
                    edgeOrientations.append(LR.RIGHT);
                    newEdges.append(edge);
                    done[i] = true;
                }
                if (done[i])
                {
                    ++nDone;
                }
            }
        }
        
        return newEdges;
    }
    
    
}
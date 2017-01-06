import Foundation

open class EdgeReorderer{
    var edges:[Edge];
    var edgeOrientations:[LR];
    
    public enum Criteria{
        case vertex
        case site
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
    open func dispose()
    {
        edges.removeAll(keepingCapacity: false)
        edgeOrientations.removeAll(keepingCapacity: false)
    }
    
    fileprivate func reorderEdges(_ origEdges:[Edge], criterion:Criteria)->[Edge]
    {
<<<<<<< Updated upstream
        let n:Int = origEdges.count;
=======
        var j:Int;
        var n:Int = origEdges.count;
>>>>>>> Stashed changes
        // we're going to reorder the edges in order of traversal
        var done = [Bool](repeating: false, count: n);
        var nDone = 0;
        var newEdges = [Edge]();
        
        let useVert = criterion == Criteria.vertex
        
        var edge = origEdges[0];
        newEdges.append(edge);
        edgeOrientations.append(LR.left);
        var firstPoint:ICoord? = useVert ? edge.leftVertex : edge.leftSite;
        var lastPoint:ICoord?  = useVert ? edge.rightVertex : edge.rightSite;
        
        if (firstPoint === Vertex.VERTEX_AT_INFINITY || lastPoint === Vertex.VERTEX_AT_INFINITY)
        {
            return [Edge]();
        }
        
        done[0] = true;
        nDone += 1;
        
<<<<<<< Updated upstream
        while (nDone < n) {
=======
        while (nDone < n)
        {
>>>>>>> Stashed changes
            for i in 1..<n {
                if (done[i])
                {
                    continue;
                }
                edge = origEdges[i];
                let leftPoint:ICoord? = useVert ? edge.leftVertex : edge.leftSite;
                let rightPoint:ICoord? = useVert ? edge.rightVertex : edge.rightSite;
                if (leftPoint === Vertex.VERTEX_AT_INFINITY || rightPoint === Vertex.VERTEX_AT_INFINITY)
                {
                    return [Edge]();
                }
                if (leftPoint === lastPoint)
                {
                    lastPoint = rightPoint;
                    edgeOrientations.append(LR.left);
                    newEdges.append(edge);
                    done[i] = true;
                }
                else if (rightPoint === firstPoint)
                {
                    firstPoint = leftPoint;
                    edgeOrientations.insert(LR.left, at: 0);
                    newEdges.insert(edge,at:0);
                    done[i] = true;
                }
                else if (leftPoint === firstPoint)
                {
                    firstPoint = rightPoint;
                    edgeOrientations.insert(LR.right, at:0);
                    newEdges.insert(edge, at: 0)
                    done[i] = true;
                }
                else if (rightPoint === lastPoint)
                {
                    lastPoint = leftPoint;
                    edgeOrientations.append(LR.right);
                    newEdges.append(edge);
                    done[i] = true;
                }
                if (done[i])
                {
                    nDone += 1;
                }
            }
        }
        
        return newEdges;
    }
    
    
}

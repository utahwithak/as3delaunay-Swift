import Foundation

public final class EdgeList{
    fileprivate let deltax:Double;
    fileprivate let xmin:Double;
    
    fileprivate let hashsize:Int;
    fileprivate var hash:[Halfedge?];
    
    public var leftEnd:Halfedge;
    public var rightEnd:Halfedge;
    
    
    
    public func dispose()
    {
        var halfEdge:Halfedge = leftEnd;
        var prevHe:Halfedge;
        while (halfEdge !== rightEnd)
        {
            prevHe = halfEdge;
            halfEdge = halfEdge.edgeListRightNeighbor!;
            prevHe.dispose();
        }
        
        for i in 0..<hashsize
        {
            hash[i] = nil;
        }
        hash.removeAll(keepingCapacity: false)
    }
    
    public init(xmin:Double, deltax:Double, sqrt_nsites:Int)
    {
        self.xmin = xmin;
        self.deltax = deltax;
        self.hashsize = 2 * sqrt_nsites;
        
        
        // two dummy Halfedges:
        leftEnd = Halfedge.createDummy();
        rightEnd = Halfedge.createDummy();

        hash = [Halfedge?](repeating: nil, count: hashsize)
        
        leftEnd.edgeListLeftNeighbor = nil;
        leftEnd.edgeListRightNeighbor = rightEnd;
        rightEnd.edgeListLeftNeighbor = leftEnd;
        rightEnd.edgeListRightNeighbor = nil;
        hash[0] = leftEnd;
        hash[hashsize - 1] = rightEnd;
    }
    
    

    
    /**
    * Insert newHalfedge to the right of lb
    * @param lb
    * @param newHalfedge
    *
    */
    public func insert(_ lb:Halfedge, newHalfedge:Halfedge)
    {
        newHalfedge.edgeListLeftNeighbor = lb;
        newHalfedge.edgeListRightNeighbor = lb.edgeListRightNeighbor;
        lb.edgeListRightNeighbor!.edgeListLeftNeighbor = newHalfedge;
        lb.edgeListRightNeighbor = newHalfedge;
    }
    
    /**
    * This func only removes the Halfedge from the left-right list.
    * We cannot dispose it yet because we are still using it.
    * @param halfEdge
    *
    */
    public func remove(_ halfEdge:Halfedge)
    {
        halfEdge.edgeListLeftNeighbor!.edgeListRightNeighbor = halfEdge.edgeListRightNeighbor;
        halfEdge.edgeListRightNeighbor!.edgeListLeftNeighbor = halfEdge.edgeListLeftNeighbor;
        halfEdge.edge = Edge.DELETED;
        halfEdge.edgeListLeftNeighbor = nil
        halfEdge.edgeListRightNeighbor = nil;
    }
    
    /**
    * Find the rightmost Halfedge that is still left of p
    * @param p
    * @return
    *
    */
    public func edgeListLeftNeighbor(_ p:Point) -> Halfedge
    {
        /* Use hash table to get close to desired halfedge */
        var bucket = Int((p.x - xmin)/deltax) * hashsize;
        if (bucket < 0)
        {
            bucket = 0;
        }
        if (bucket >= hashsize)
        {
            bucket = hashsize - 1;
        }
        var halfEdge = getHash(bucket);
        if(halfEdge == nil)
        {
<<<<<<< Updated upstream
            var i = 1
            while (true)
            {
=======
            var i = 0
            while i > -1 {
>>>>>>> Stashed changes
                if let h = getHash(bucket - i){
                    halfEdge = h
                    break;
                }
                else if let h = getHash(bucket + i){
                    halfEdge = h
                    break;
                }
                i += 1
            }
        }
        /* Now search linear list of halfedges for the correct one */
        if (halfEdge === leftEnd  || (halfEdge !== rightEnd && halfEdge!.isLeftOf(p))){
            repeat{
                halfEdge = halfEdge!.edgeListRightNeighbor;
            }
            while (halfEdge !== rightEnd && halfEdge!.isLeftOf(p));
            halfEdge = halfEdge!.edgeListLeftNeighbor;
        }
        else {
            repeat{
                halfEdge = halfEdge!.edgeListLeftNeighbor;
            }
            while (halfEdge !== leftEnd && !halfEdge!.isLeftOf(p));
        }
        
        /* Update hash table and reference counts */
        if (bucket > 0 && bucket < hashsize - 1)
        {
            hash[bucket] = halfEdge;
        }
        return halfEdge!;
    }
    
    /* Get entry from hash table, pruning any deleted nodes */
    fileprivate func getHash(_ b:Int)->Halfedge?
    {
        if (b < 0 || b >= hashsize)
        {
            return nil;
        }
        let halfEdge = hash[b];
        if (halfEdge != nil && halfEdge!.edge === Edge.DELETED)
        {
            /* Hash table points to deleted halfedge.  Patch as necessary. */
            hash[b] = nil;
            // still can't dispose halfEdge yet!
            return nil;
        }
        else{
            return halfEdge;
        }
    }
}

import Foundation

open class HalfedgePriorityQueue // also known as heap
{
    fileprivate var hash = [Halfedge?]();
    fileprivate var count:Int = 0;
    fileprivate var minBucket:Int = 0;
    fileprivate var hashsize:Int = 0;
    
    fileprivate var ymin:Double = 0;
    fileprivate var deltay:Double = 0;

    public init(ymin:Double, deltay:Double, sqrtnsites:Int)
    {
        self.ymin = ymin;
        self.deltay = deltay;
        hashsize = 4 * sqrtnsites;
        initialize();
    }

    open func dispose()
    {
        // get rid of dummies
        for i in 0..<hashsize {
            if let edge = hash[i]{
                edge.dispose();
            }
            hash[i] = nil;
        }
        hash.removeAll(keepingCapacity: false);
    }

    fileprivate func initialize()
    {    
        count = 0;
        minBucket = 0;
        hash = [Halfedge?](repeating: nil, count: hashsize);
        // dummy Halfedge at the top of each hash
        for i in 0..<hashsize {
            hash[i] = Halfedge.createDummy();
            hash[i]!.nextInPriorityQueue = nil;
        }
    }

    open func insert(_ halfEdge:Halfedge)
    {
        var previous:Halfedge?, next:Halfedge?;
        let insertionBucket = bucket(halfEdge);
        if (insertionBucket < minBucket)
        {
            minBucket = insertionBucket;
        }
        previous = hash[insertionBucket];
        next = previous!.nextInPriorityQueue
        while (next != nil && (halfEdge.ystar  > next!.ystar || (halfEdge.ystar == next!.ystar && halfEdge.vertex!.x > next!.vertex!.x)))
        {
            previous = next;
            next = previous!.nextInPriorityQueue
        }
        halfEdge.nextInPriorityQueue = previous!.nextInPriorityQueue;
        previous!.nextInPriorityQueue = halfEdge;
        count += 1;
    }

    open func remove(_ halfEdge:Halfedge)
    {
        var previous:Halfedge;
        let removalBucket:Int = bucket(halfEdge);
        
        if (halfEdge.vertex != nil)
        {
            previous = hash[removalBucket]!;
            while (previous.nextInPriorityQueue !== halfEdge)
            {
                previous = previous.nextInPriorityQueue!;
            }
            previous.nextInPriorityQueue = halfEdge.nextInPriorityQueue;
            count -= 1;
            halfEdge.vertex = nil;
            halfEdge.nextInPriorityQueue = nil;
            halfEdge.dispose();
        }
    }

    fileprivate func bucket(_ halfEdge:Halfedge)->Int
    {
        var theBucket:Int = Int((halfEdge.ystar - ymin) / deltay) * hashsize;
        if (theBucket < 0){
            theBucket = 0;
        }
        if (theBucket >= hashsize){
            theBucket = hashsize - 1;

        }
        return theBucket;
    }

    fileprivate func isEmpty(_ bucket:Int)->Bool
    {
        return (hash[bucket]!.nextInPriorityQueue == nil);
    }
    
    /**
     * move minBucket until it contains an actual Halfedge (not just the dummy at the top); 
     * 
     */
    fileprivate func adjustMinBucket()
    {
        while (minBucket < hashsize - 1 && isEmpty(minBucket))
        {
            minBucket += 1;
        }
    }

    open func empty()->Bool
    {
        return count == 0;
    }

    /**
     * @return coordinates of the Halfedge's vertex in V*, the transformed Voronoi diagram
     * 
     */
    open func min()->Point
    {
        adjustMinBucket();
        let answer:Halfedge = hash[minBucket]!.nextInPriorityQueue!;
        return Point(x:answer.vertex!.x,y: answer.ystar);
    }

    /**
     * remove and return the min Halfedge
     * @return 
     * 
     */
    open func extractMin()->Halfedge
    {
        var answer:Halfedge;
    
        // get the first real Halfedge in minBucket
        answer = hash[minBucket]!.nextInPriorityQueue!;
        
        hash[minBucket]!.nextInPriorityQueue = answer.nextInPriorityQueue;
        count -= 1;
        answer.nextInPriorityQueue = nil;
        
        return answer;
    }

}

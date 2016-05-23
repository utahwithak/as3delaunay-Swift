import Foundation

public class HalfedgePriorityQueue // also known as heap
{
    private var hash = [Halfedge?]();
    private var count:Int = 0;
    private var minBucket:Int = 0;
    private var hashsize:Int = 0;
    
    private var ymin:Double = 0;
    private var deltay:Double = 0;

    public init(ymin:Double, deltay:Double, sqrtnsites:Int)
    {
        self.ymin = ymin;
        self.deltay = deltay;
        hashsize = 4 * sqrtnsites;
        initialize();
    }

    public func dispose()
    {
        // get rid of dummies
        for i:Int in 0 ..< hashsize
        {
            if let edge = hash[i]{
                edge.dispose();
            }
            hash[i] = nil;
        }
        hash.removeAll(keepCapacity: false);
    }

    private func initialize()
    {
        count = 0;
        minBucket = 0;
        hash = [Halfedge?](count:hashsize, repeatedValue:nil);
        // dummy Halfedge at the top of each hash
        for i:Int in 0 ..< hashsize
        {
            hash[i] = Halfedge.createDummy();
            hash[i]!.nextInPriorityQueue = nil;
        }
    }

    public func insert(halfEdge:Halfedge)
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

    public func remove(halfEdge:Halfedge)
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

    private func bucket(halfEdge:Halfedge)->Int
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

    private func isEmpty(bucket:Int)->Bool
    {
        return (hash[bucket]!.nextInPriorityQueue == nil);
    }
    
    /**
     * move minBucket until it contains an actual Halfedge (not just the dummy at the top); 
     * 
     */
    private func adjustMinBucket()
    {
        while (minBucket < hashsize - 1 && isEmpty(minBucket))
        {
            minBucket += 1;
        }
    }

    public func empty()->Bool
    {
        return count == 0;
    }

    /**
     * @return coordinates of the Halfedge's vertex in V*, the transformed Voronoi diagram
     * 
     */
    public func min()->Point
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
    public func extractMin()->Halfedge
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

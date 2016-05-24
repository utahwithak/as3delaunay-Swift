import Foundation

public class LineSegment{
    public static func compareLengths_MAX(segment0:LineSegment, segment1:LineSegment) -> Int {
        let length0 = Point.distance(segment0.p0, segment0.p1);
        let length1 = Point.distance(segment1.p0, segment1.p1);
        if length0 < length1{
            return 1
        }
        if length0 > length1{
            return -1
        }
        return 0
    }
    
    public static func compareLengths(edge0:LineSegment, edge1:LineSegment) -> Int{
        return -1 * compareLengths_MAX(edge0, segment1: edge1);
    }

    public let p0:Point!;
    public let p1:Point!;
    
    public init(p0:Point, p1:Point)
    {
        self.p0 = p0;
        self.p1 = p1;
    }
    public init(){
        p0 = nil
        p1 = nil
    }
}
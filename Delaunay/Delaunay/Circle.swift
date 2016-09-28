import Foundation

open class Circle:CustomStringConvertible{
    open let center:Point;
    open let radius:Double;
    
    public init(centerX:Double, centerY:Double, radius:Double)
    {
        self.center = Point(x:centerX, y:centerY);
        self.radius = radius;
    }
    
    open var description:String{
        return "Circle (center: \( center) + ; radius: \(radius))";
    }

}

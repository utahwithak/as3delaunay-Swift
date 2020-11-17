import Foundation

open class Circle:  CustomStringConvertible {
    
    public let center: Point
    public let radius: Double
    
    public init(centerX: Double, centerY: Double, radius: Double) {
        self.center = Point(x: centerX, y: centerY)
        self.radius = radius
    }
    
    open var description: String {
        return "Circle (center: \( center) + ; radius: \(radius))"
    }

}

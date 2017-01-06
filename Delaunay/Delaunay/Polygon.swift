import Foundation

open class Polygon
{
    fileprivate let vertices:[Point];

    public init(vertices:[Point]){
        self.vertices = vertices;
    }

    open func area() -> Double{
        return abs(signedDoubleArea() * 0.5);
    }

    open func winding()->Winding{
<<<<<<< Updated upstream
        let sDoubleArea = signedDoubleArea();
=======
        var sDoubleArea = signedDoubleArea();
>>>>>>> Stashed changes
        if (sDoubleArea < 0)
        {
            return Winding.clockwise;
        }
        if (sDoubleArea > 0)
        {
            return Winding.counterclockwise;
        }
        return Winding.none;
    }

    fileprivate func signedDoubleArea()->Double{
        let n = vertices.count;
        var signedDoubleArea:Double = 0;
    
        for i in 0..<n{
            let nextIndex = (i + 1) % n;
            let point = vertices[i]
            let next = vertices[nextIndex]
            signedDoubleArea += point.x * next.y - next.x * point.y;
        }
        return signedDoubleArea;
    }
}

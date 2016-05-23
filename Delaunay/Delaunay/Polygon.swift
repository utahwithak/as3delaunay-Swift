import Foundation

public class Polygon
{
    private let vertices:[Point];

    public init(vertices:[Point]){
        self.vertices = vertices;
    }

    public func area() -> Double{
        return abs(signedDoubleArea() * 0.5);
    }

    public func winding()->Winding{
        let sDoubleArea = signedDoubleArea();
        if (sDoubleArea < 0)
        {
            return Winding.CLOCKWISE;
        }
        if (sDoubleArea > 0)
        {
            return Winding.COUNTERCLOCKWISE;
        }
        return Winding.NONE;
    }

    private func signedDoubleArea()->Double{
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

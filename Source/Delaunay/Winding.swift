import Foundation

public enum Winding: String, CustomStringConvertible {
    
    case clockwise
    case counterclockwise
    case none
    
    public var description: String {
        return self.rawValue.uppercased()
    }
}



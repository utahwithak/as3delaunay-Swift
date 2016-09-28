import Foundation

public enum Winding:CustomStringConvertible{
		case clockwise
		case counterclockwise
		case none
    
    public var description:String{
        switch(self){
        case .clockwise:
            return "CLOCKWISE"
        case .counterclockwise:
            return "COUNTERCLOCKWISE"
        case .none:
            return "NONE"
        }
    }
}



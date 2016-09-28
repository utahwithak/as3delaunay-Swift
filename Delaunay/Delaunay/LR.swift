import Foundation

public enum LR:CustomStringConvertible{
    case left
    case right
    case unknown
    public static func other(_ leftRight:LR)->LR
	{
        return leftRight == left ? right : left;
    }
    
    public var description:String{
        switch(self){
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .unknown:
            return "UNKNOWN!"
        }
    }
}


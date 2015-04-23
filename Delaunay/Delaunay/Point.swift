//
//  Point.swift
//  Map Generator
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
public class Point:Printable{
    public var x:Double
    public var y:Double
    public init(x:Double, y:Double){
        self.x = x;
        self.y = y
    }
    
    public var description:String{
        let xstr = String(format:"%.2f",x)
        let ystr = String(format:"%.2f",y)
        return "(\(xstr), \(ystr))"
    }
}


extension Point :Hashable{
    static func distance( lhs:Point, _ rhs:Point)->Double{
        let dx = lhs.x - rhs.x;
        let dy = lhs.y - rhs.y;
        return sqrt((dx * dx) + (dy * dy))
    }
    
    public var hashValue : Int {
            return self.x.hashValue^self.y.hashValue
    }
}

public func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

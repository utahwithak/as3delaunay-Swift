//
//  Point.swift
//  Map Generator
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
public class Point:CustomStringConvertible{
    public static let zeroPoint = {return Point(x:0,y:0)}()
    
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
    
    public var length:Double{
        return Point.distance(self, Point.zeroPoint)
    }
    public func distance(p:Point)->Double{
        return Point.distance(self, p)
    }
    
    public static func interpolate(p1:Point, p2:Point, t:Double)->Point{
        let dx = (p2.x - p1.x) * t
        let dy = (p2.y - p1.y) * t
        return Point(x: p1.x + dx, y: p1.y + dy)

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

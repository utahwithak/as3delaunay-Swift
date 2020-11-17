//
//  Point.swift
//  Map Generator
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation

open class Point: CustomStringConvertible {
    
    public static let zero = Point(x: 0, y: 0)
    
    open var x: Double
    open var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    open var description: String {
        return String(format: "(%.2f, %.2f)", x, y)
    }
    
    open var length: Double {
        return Point.distance(self, .zero)
    }
    
    open func distance(_ p: Point) -> Double {
        return Point.distance(self, p)
    }
    
    public static func interpolate(_ p1: Point, p2: Point, t: Double) -> Point {
        let dx = (p2.x - p1.x) * t
        let dy = (p2.y - p1.y) * t
        return Point(x: p1.x + dx, y: p1.y + dy)
        
    }
}

 extension Point: Hashable {
    
    static func distance( _ lhs:Point, _ rhs:Point)->Double{
        let dx = lhs.x - rhs.x;
        let dy = lhs.y - rhs.y;
        return sqrt((dx * dx) + (dy * dy))
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

public func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

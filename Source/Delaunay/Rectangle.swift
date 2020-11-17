//
//  Rectangle.swift
//  Map Generator
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation

open class Rectangle {
    
    public static let zero = Rectangle(x: 0, y: 0, width: 0,height: 0)
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = Double(x)
        self.y = Double(y)
        self.width = Double(width)
        self.height = Double(height)
    }
    
    open var bottom: Double {
        return x + height
    }
    
    open var left: Double {
        return x
    }
    
    open var right: Double {
        return x + width
    }
    
    open var top: Double {
        return y
    }
    
    open var minX:Double {
        return x
    }
    
    open var maxX: Double {
        return x + width
    }
    
    open var minY: Double {
        return y
    }
    
    open var maxY: Double {
        return y + height
    }
    
    
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    
}

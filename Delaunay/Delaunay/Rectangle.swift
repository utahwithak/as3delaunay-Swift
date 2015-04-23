//
//  Rectangle.swift
//  Map Generator
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation

public class Rectangle{
    public static let zeroRect = Rectangle(x: 0,y: 0,width: 0,height: 0)
    
    public init(x:Double, y:Double, width:Double, height:Double){
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public init(x:Int, y:Int, width:Int, height:Int){
        self.x = Double(x)
        self.y = Double(y)
        self.width = Double(width)
        self.height = Double(height)
    }
    
    
    
    public var bottom:Double
    {
        return x + height;
    }
    
    public var left:Double
    {
        return x;
    }
    
    public var right:Double
    {
        return x + width;
    }
    
    public var top:Double
    {
        return y;
    }
    public var minX:Double{
        return x
    }
    public var maxX:Double{
        return x + width
    }
    public var minY:Double{
        return y
    }
    public var maxY:Double{
        return y + height
    }
    
    
    let x:Double
    let y:Double
    let width:Double
    let height:Double
    
}
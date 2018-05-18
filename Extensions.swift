//
//  Extensions.swift
//  WitchOfDewmal
//
//  Created by Bullough, Amber on 5/18/18.
//  Copyright © 2018 CTEC. All rights reserved.
//

//  Extensions.swift

import CoreGraphics
import SpriteKit

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

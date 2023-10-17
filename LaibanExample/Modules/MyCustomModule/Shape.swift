//
//  Shape.swift
//  LaibanExample
//
//  Created by Dan Nilsson on 2023-10-10.
//

import SwiftUI

struct Splash: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let point = CGPoint(x: 0, y: 100)
        path.move(to: point)
        path.addLine(to: CGPoint(x: 12, y: 213))
        
        return path.applying(CGAffineTransform(translationX: 0, y: 20))
    }
}

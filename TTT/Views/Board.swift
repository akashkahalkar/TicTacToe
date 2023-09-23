//
//  Board.swift
//  TTT
//
//  Created by Akash kahalkar on 30/04/19.
//  Copyright © 2019 Akashka. All rights reserved.
//

import UIKit

@IBDesignable class Board: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(red: 4/255, green: 39/255, blue: 105/255, alpha: 1)
    @IBInspectable var endColor: UIColor = UIColor(red: 1/255, green: 91/255, blue: 168/255, alpha: 1)
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addCornerRadius(rect)
        drawGradient()
        drawLines(rect)
        dropShadow(scale: true)
    }
    
    func addCornerRadius(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: 10.0, height: 10.0))
        path.addClip()
    }
    
    func drawGradient() {
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)!
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }
    
    private func drawLines(_ rect: CGRect) {
        let line = UIBezierPath()
        line.lineWidth = 7.0
        //vertical line no. 1
        line.move(to: CGPoint(x: rect.width/3.0, y: 10.0))
        line.addLine(to: CGPoint(x: rect.width/3.0, y: rect.height-10.0))
        //vertical line no. 2
        line.move(to: CGPoint(x: ((rect.width/3.0)*2.0), y: 10.0))
        line.addLine(to: CGPoint(x: ((rect.width/3.0)*2.0), y: rect.height-10.0))
        //horizontal line no. 1
        line.move(to: CGPoint(x: 10.0, y: rect.height/3.0))
        line.addLine(to: CGPoint(x: rect.width-10.0 , y: rect.height/3.0 ))
        //horizontal line no. 2
        line.move(to: CGPoint(x: 10.0, y: (rect.height/3.0)*2.0))
        line.addLine(to: CGPoint(x: rect.width-10.0 , y: (rect.height/3.0)*2.0))
        
        UIColor.white.withAlphaComponent(0.7).setStroke()
        line.stroke()
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -2, height: 2)
        layer.shadowRadius = 10
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}


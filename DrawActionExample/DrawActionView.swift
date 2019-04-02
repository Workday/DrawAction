/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import UIKit
import DrawAction

class DrawActionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        let exampleHeight: CGFloat = 30
        let padding: CGFloat = 10
        
        var remainderRect = rect.insetBy(dx: padding, dy: padding)
        var currentRect: CGRect = CGRect.zero
        
        let examples = [drawExample1, drawExample2, drawExample3]
        
        for example in examples {
            remainderRect.origin.y += 10
            (currentRect, remainderRect) = remainderRect.divided(atDistance: exampleHeight, from: .minYEdge)
            example(currentRect)
        }
    }
    
    fileprivate func drawExample1(_ rect: CGRect) {
        // Fill a blue rect with a red border
        DrawFill(color: UIColor.blue).add(DrawBorder(color: UIColor.red, lineWidth: 2)).drawRect(rect, inContext: UIGraphicsGetCurrentContext())
    }
    
    fileprivate func drawExample2(_ rect: CGRect) {
        // Fill two rects next to each other, one with a shadow the other without.
        let leftRect = DrawFill(color: UIColor.blue)
        let rightRect = DrawShadow(color: UIColor.black, blur: 2, offset: CGSize(width: -1, height: 1)).add(DrawFill(color: UIColor.red))
        
        DrawDivide(amount: rect.width/2 - 5, padding: 10, edge: .minXEdge, slice: leftRect, next: rightRect).drawRect(rect, inContext: UIGraphicsGetCurrentContext())
    }
    
    fileprivate func drawExample3(_ rect: CGRect) {
        // Draw a rounded rect with a border gradient, background gradient and shadow, with "Hello world" printed in the middle with a shadow
        
        let backgroundAction = DrawAction.chainActions([
            DrawShadow(color: UIColor.black, blur: 1, offset: CGSize(width: 0, height: 1)),
            DrawTransparency(), // All subsequent drawing operations will be in a separate 'transparency layer', so the shadow will be applied even for the gradient
            DrawInset(uniformInset: 2),
            DrawPath(roundedRectRadius: 5),
            DrawClip(), // Gradients don't respect context paths by default so we clip to the path
            DrawGradient(colors: [UIColor.lightGray, UIColor.darkGray], horizontal: true),
            DrawBorderGradient(colors: [UIColor.darkGray, UIColor.lightGray], lineWidth: 4, inset: 0)
        ])
        
        // White text with shadow
        let textAction = DrawShadow(color: UIColor.black, blur: 0, offset: CGSize(width: 1, height: 1)).add(
            DrawText(text: "Hello World", font: UIFont.preferredFont(forTextStyle: .body), color: UIColor.white, alignment: .center, lineBreakMode: .byTruncatingTail))
        
        let drawSize = CGSize(width: 100, height: 30)
        let drawRect = CGRect(origin: CGPoint(x: rect.midX - drawSize.width/2, y: rect.midY - drawSize.height/2), size: drawSize)
        
        DrawSplit(split: backgroundAction, next: textAction).drawRect(drawRect, inContext: UIGraphicsGetCurrentContext())
    }
}

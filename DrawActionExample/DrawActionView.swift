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
        contentMode = .Redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .Redraw
    }
    
    override func drawRect(rect: CGRect) {
        let exampleHeight: CGFloat = 30
        let padding: CGFloat = 10
        
        var remainderRect = CGRectInset(rect, padding, padding)
        var currentRect: CGRect = CGRectZero
        
        let examples = [drawExample1, drawExample2, drawExample3]
        
        for example in examples {
            remainderRect.origin.y += 10
            CGRectDivide(remainderRect, &currentRect, &remainderRect, exampleHeight, .MinYEdge)
            example(currentRect)
        }
    }
    
    private func drawExample1(rect: CGRect) {
        // Fill a blue rect with a red border
        DrawFill(color: UIColor.blueColor()).add(DrawBorder(color: UIColor.redColor(), lineWidth: 2)).drawRect(rect, inContext: UIGraphicsGetCurrentContext())
    }
    
    private func drawExample2(rect: CGRect) {
        // Fill two rects next to each other, one with a shadow the other without.
        let leftRect = DrawFill(color: UIColor.blueColor())
        let rightRect = DrawShadow(color: UIColor.blackColor(), blur: 2, offset: CGSize(width: -1, height: 1)).add(DrawFill(color: UIColor.redColor()))
        
        DrawDivide(amount: rect.width/2 - 5, padding: 10, edge: .MinXEdge, slice: leftRect, next: rightRect).drawRect(rect, inContext: UIGraphicsGetCurrentContext())
    }
    
    private func drawExample3(rect: CGRect) {
        // Draw a rounded rect with a border gradient, background gradient and shadow, with "Hello world" printed in the middle with a shadow
        
        let backgroundAction = DrawAction.chainActions([
            DrawShadow(color: UIColor.blackColor(), blur: 1, offset: CGSizeMake(0, 1)),
            DrawTransparency(), // All subsequent drawing operations will be in a separate 'transparency layer', so the shadow will be applied even for the gradient
            DrawInset(uniformInset: 2),
            DrawPath(roundedRectRadius: 5),
            DrawClip(), // Gradients don't respect context paths by default so we clip to the path
            DrawGradient(colors: [UIColor.lightGrayColor(), UIColor.darkGrayColor()], horizontal: true),
            DrawBorderGradient(colors: [UIColor.darkGrayColor(), UIColor.lightGrayColor()], lineWidth: 4, inset: 0)
        ])
        
        // White text with shadow
        let textAction = DrawShadow(color: UIColor.blackColor(), blur: 0, offset: CGSizeMake(1, 1)).add(
            DrawText(text: "Hello World", font: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), color: UIColor.whiteColor(), alignment: .Center, lineBreakMode: .ByTruncatingTail))
        
        let drawSize = CGSize(width: 100, height: 30)
        let drawRect = CGRect(origin: CGPoint(x: rect.midX - drawSize.width/2, y: rect.midY - drawSize.height/2), size: drawSize)
        
        DrawSplit(split: backgroundAction, next: textAction).drawRect(drawRect, inContext: UIGraphicsGetCurrentContext())
    }
}
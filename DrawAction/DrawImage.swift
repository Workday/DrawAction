/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that draws the given UIImage
final public class DrawImage : DrawAction {

    private let image: UIImage
    private let contentMode: UIViewContentMode
    private let blendMode: CGBlendMode
    private let alpha: CGFloat

    /**
     Initializes a DrawImage
     
     - parameter image: The image to draw
     - parameter contentMode: The content mode to respect when performing the draw operation. Behavior is undefined if passed `.Redraw`
     - parameter blendMode: The `CGBlendMode` to use when drawing the image
     - parameter alpha: The alpha to apply to the image while drawing
     */
    public init(image: UIImage, contentMode: UIViewContentMode, blendMode: CGBlendMode, alpha: CGFloat) {
        self.image = image
        self.contentMode = contentMode
        self.blendMode = blendMode
        self.alpha = alpha
        super.init()
    }

    /**
     Initializes a DrawImage with a normal blend mode and alpha of 1
     
     - parameter image: The image to draw
     - parameter contentMode: The content mode to respect when performing the draw operation. Behavior is undefined if passed `.Redraw`
     */
    convenience public init(image: UIImage, contentMode: UIViewContentMode) {
        self.init(image: image, contentMode: contentMode, blendMode: .Normal, alpha: 1)
    }

    override func performActionInContext(context: DrawContext) {
        var rect = context.rect
        rect = rectForSize(image.size, inRect: rect, contentMode: contentMode)
        
        UIGraphicsPushContext(context.graphicsContext)
        image.drawInRect(rect, blendMode: blendMode, alpha: alpha)
        UIGraphicsPopContext()
        next?.performActionInContext(context)
    }

    private func aspectRectForImageSize(size: CGSize, inRect rect: CGRect, fit: Bool) -> CGRect {
        
        let widthRatio = rect.width / size.width
        let heightRatio = rect.height / size.height
        
        let ratioToUse: CGFloat
        if fit {
            ratioToUse = min(widthRatio, heightRatio)
        } else {
            ratioToUse = max(widthRatio, heightRatio)
        }
        
        let newSize = CGSizeMake(size.width*ratioToUse, size.height*ratioToUse)
        let newOrigin = CGPoint(x: rect.midX - (newSize.width / 2), y: rect.midY - (newSize.height / 2))
        
        return CGRectIntegral(CGRect(origin: newOrigin, size: newSize))
    }
    
    private func rectForSize(size: CGSize, inRect rect: CGRect, contentMode: UIViewContentMode) -> CGRect {
        guard contentMode != .ScaleToFill else {
            return rect
        }
        
        guard contentMode != .ScaleAspectFit else {
            return aspectRectForImageSize(size, inRect: rect, fit: true)
        }
        
        guard contentMode != .ScaleAspectFill else {
            return aspectRectForImageSize(size, inRect: rect, fit: false)
        }
        
        var newRect = CGRect(origin: CGPointZero, size: size)
        
        // X origin
        switch contentMode {
        case .Top, .Center, .Bottom:
            newRect.origin.x = rect.midX - (size.width / 2)
        case .TopLeft, .Left, .BottomLeft:
            newRect.origin.x = rect.minX
        case .TopRight, .Right, .BottomRight:
            newRect.origin.x = rect.maxX - size.width
        default:
            break // Other cases accounted for above
        }
        
        // Y origin
        switch contentMode {
        case .Left, .Center, .Right:
            newRect.origin.y = rect.midY - (size.height / 2)
        case .TopLeft, .Top, .TopRight:
            newRect.origin.y = rect.minY
        case .BottomLeft, .Bottom, .BottomRight:
            newRect.origin.y = rect.maxY - size.height
        default:
            break // Other cases accounted for above
        }
        
        return newRect
    }
}

/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that draws the given UIImage
final public class DrawImage : DrawAction {

    fileprivate let image: UIImage
    fileprivate let contentMode: UIView.ContentMode
    fileprivate let blendMode: CGBlendMode
    fileprivate let alpha: CGFloat

    fileprivate let tint: UIColor?

    /**
     Initializes a DrawImage
     
     - parameter image: The image to draw
     - parameter contentMode: The content mode to respect when performing the draw operation. Behavior is undefined if passed `.Redraw`
     - parameter blendMode: The `CGBlendMode` to use when drawing the image
     - parameter alpha: The alpha to apply to the image while drawing
     */
    public init(image: UIImage, contentMode: UIView.ContentMode, blendMode: CGBlendMode, alpha: CGFloat) {
        self.image = image
        self.contentMode = contentMode
        self.blendMode = blendMode
        self.alpha = alpha
        self.tint = nil
        super.init()
    }

    /**
     Initializes a DrawImage with a normal blend mode and alpha of 1
     
     - parameter image: The image to draw
     - parameter contentMode: The content mode to respect when performing the draw operation. Behavior is undefined if passed `.Redraw`
     */
    convenience public init(image: UIImage, contentMode: UIView.ContentMode) {
        self.init(image: image, contentMode: contentMode, blendMode: .normal, alpha: 1)
    }

    /**
     Initializase a DrawImage, treating it as a 'template' image, applying the given template color

     - parameter image: The image to use as a template
     - parameter tint: The tint color to render with
     - parameter contentMode: The content mode to respect when performing the draw operation. Behavior is undefined if passed `.Redraw`
     */
    public init(image: UIImage, tint: UIColor, contentMode: UIView.ContentMode) {
        self.image = image
        self.contentMode = contentMode
        self.blendMode = .normal
        self.alpha = 1
        self.tint = tint
        super.init()
    }

    override func performActionInContext(_ context: DrawContext) {
        var rect = context.rect
        rect = rectForSize(image.size, inRect: rect, contentMode: contentMode)
        
        UIGraphicsPushContext(context.graphicsContext)

        if let tint = tint {
            // Render as a template image
            context.performGraphicsActions { ctx in
                tint.setFill()
                // Flip the context since we're using CG apis
                ctx.translateBy(x: 0, y: rect.maxY)
                ctx.scaleBy(x: 1, y: -1)

                rect.origin.y = 0.0
                ctx.clip(to: rect, mask: image.cgImage!)
                ctx.fill(rect)
            }
        } else {
            image.draw(in: rect, blendMode: blendMode, alpha: alpha)
        }

        UIGraphicsPopContext()
        next?.performActionInContext(context)
    }

    fileprivate func aspectRectForImageSize(_ size: CGSize, inRect rect: CGRect, fit: Bool) -> CGRect {
        
        let widthRatio = rect.width / size.width
        let heightRatio = rect.height / size.height
        
        let ratioToUse: CGFloat
        if fit {
            ratioToUse = min(widthRatio, heightRatio)
        } else {
            ratioToUse = max(widthRatio, heightRatio)
        }
        
        let newSize = CGSize(width: size.width*ratioToUse, height: size.height*ratioToUse)
        let newOrigin = CGPoint(x: rect.midX - (newSize.width / 2), y: rect.midY - (newSize.height / 2))
        
        return CGRect(origin: newOrigin, size: newSize).integral
    }
    
    fileprivate func rectForSize(_ size: CGSize, inRect rect: CGRect, contentMode: UIView.ContentMode) -> CGRect {
        guard contentMode != .scaleToFill else {
            return rect
        }
        
        guard contentMode != .scaleAspectFit else {
            return aspectRectForImageSize(size, inRect: rect, fit: true)
        }
        
        guard contentMode != .scaleAspectFill else {
            return aspectRectForImageSize(size, inRect: rect, fit: false)
        }
        
        var newRect = CGRect(origin: CGPoint.zero, size: size)
        
        // X origin
        switch contentMode {
        case .top, .center, .bottom:
            newRect.origin.x = rect.midX - (size.width / 2)
        case .topLeft, .left, .bottomLeft:
            newRect.origin.x = rect.minX
        case .topRight, .right, .bottomRight:
            newRect.origin.x = rect.maxX - size.width
        default:
            break // Other cases accounted for above
        }
        
        // Y origin
        switch contentMode {
        case .left, .center, .right:
            newRect.origin.y = rect.midY - (size.height / 2)
        case .topLeft, .top, .topRight:
            newRect.origin.y = rect.minY
        case .bottomLeft, .bottom, .bottomRight:
            newRect.origin.y = rect.maxY - size.height
        default:
            break // Other cases accounted for above
        }
        
        return newRect
    }
}

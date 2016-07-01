/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/**
 Action that strokes a border on the current rect or path
*/
final public class DrawBorder : DrawAction {
    private let color: UIColor
    private let lineWidth: CGFloat
    private let dashedLineLengths: [CGFloat]?

    /**
     Initializes a DrawBorder
     
     - parameter color: The color of the border
     - parameter lineWidth: The width of the border
     - parameter dashedLineLengths: If non-nil, specifies the lengths of painted and unpainted segments as the border is
     drawn. For example, passing [2,3] would cause the border to draw 2 points of border followed by 3 points of space in a repeating pattern.
     */
    public init(color: UIColor, lineWidth: CGFloat, dashedLineLengths: [CGFloat]?) {
        self.color = color
        self.lineWidth = lineWidth
        self.dashedLineLengths = dashedLineLengths
        super.init()
    }

    /**
     Initializes a DrawBorder with a lineWidth of 1
     
     - parameter color: The color of the border
     */
    convenience public init(color: UIColor) {
        self.init(color: color, lineWidth: 1)
    }

    /**
     Initializes a DrawBorder with the specified lineWidth and color
     
     - parameter color: The color of the border
     - parameter lineWidth: The width of the border
     */
    convenience public init(color: UIColor, lineWidth: CGFloat) {
        self.init(color: color, lineWidth: lineWidth, dashedLineLengths: nil)
    }

    override func performActionInContext(context: DrawContext) {
        context.performGraphicsActions { gContext in
            CGContextSetLineWidth(gContext, lineWidth)
            CGContextSetStrokeColorWithColor(gContext, color.CGColor)

            let strokeClosure = {
                if context.addPathToGraphicsContext() {
                    CGContextStrokePath(gContext)
                } else {
                    CGContextStrokeRect(gContext, context.rect)
                }
            }

            if let lineLengths = dashedLineLengths {
                lineLengths.withUnsafeBufferPointer { pointer in
                    CGContextSetLineDash(gContext, 0, pointer.baseAddress, pointer.count)
                    strokeClosure()
                }
            } else {
                strokeClosure()
            }
        }
        next?.performActionInContext(context)
    }
}

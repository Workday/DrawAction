/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/**
 Action that draws one or more line segments. Points provided to initializers are specified in the unit coordinate system and mapped to the current rect.
 For example the point array [(0, 0), (1, 1)] would draw a line from the top left to the bottom right corner of the rect.
 */
final public class DrawLine : DrawAction {

    private let color: UIColor
    private let lineWidth: CGFloat
    private let points: [CGPoint]
    
    /**
     Initializes a DrawLine
     
     - parameter points: Array of points organized as pairs specifying the start and end of each segment, so there must be an even number of points.
     - parameter color: color to stroke the line segments
     - parameter lineWidth: line width of the segments
     */
    public init(points: [CGPoint], color: UIColor, lineWidth: CGFloat) {
        precondition(points.count > 0 && points.count % 2 == 0, "Need even amount of points")
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        super.init()
    }
    
    /**
     Initializes a DrawLine. Equivalent initializer to `init(points:color:lineWidth)`, but takes an array of NSValues containing CGPoints. For objective-c compatibility
     */
    convenience public init(boxedPoints: [NSValue], color: UIColor, lineWidth: CGFloat) {
        self.init(points: boxedPoints.map{$0.CGPointValue()}, color: color, lineWidth: lineWidth)
    }

    /**
     Initializes a DrawLine with a single line segment
     
     - parameter startPoint: startPoint of the line segment. Defined in the unit coordinate system
     - parameter endPoint: startPoint of the line segment. Defined in the unit coordinate system
     - parameter color: color to stroke the line segments
     - parameter lineWidth: line width of the segments
     */
    convenience public init(startPoint: CGPoint, endPoint: CGPoint, color: UIColor, lineWidth: CGFloat) {
        let points = [startPoint, endPoint]
        self.init(points: points, color: color, lineWidth: lineWidth)
    }

    /**
     Initializes a DrawLine with a single line segment of width 1
     
     - parameter startPoint: startPoint of the line segment. Defined in the unit coordinate system
     - parameter endPoint: startPoint of the line segment. Defined in the unit coordinate system
     - parameter color: color to stroke the line segments
     */
    convenience public init(startPoint: CGPoint, endPoint: CGPoint, color: UIColor) {
        self.init(startPoint: startPoint, endPoint: endPoint, color: color, lineWidth: 1)
    }

    override func performActionInContext(context: DrawContext) {
        context.performGraphicsActions { gContext in
            CGContextSetLineCap(gContext, .Square)
            CGContextSetStrokeColorWithColor(gContext, color.CGColor)
            CGContextSetLineWidth(gContext, lineWidth)

            let rectPoints = pointArrayForUnitPoints(points, inRect: context.rect)
            rectPoints.withUnsafeBufferPointer { pBuffer in
                CGContextStrokeLineSegments(gContext, pBuffer.baseAddress, pBuffer.count)
            }
        }
        next?.performActionInContext(context)
    }

    private func pointArrayForUnitPoints(points: [CGPoint], inRect rect: CGRect) -> [CGPoint] {
        var rect = rect
        rect.size.width -= lineWidth
        rect.size.height -= lineWidth

        return points.map { point in
            var newPoint = CGPoint()
            let xValue = CGFloat(floorf(Float(rect.minX + point.x * rect.width)))
            newPoint.x = xValue + lineWidth/2
            let yValue = CGFloat(floorf(Float(rect.minY + point.y * rect.height)))
            newPoint.y = yValue + lineWidth/2
            return newPoint
        }
    }
}

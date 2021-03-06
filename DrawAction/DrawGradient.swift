/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that draws a linear or radial gradient in the current rect
final public class DrawGradient : DrawAction {

    fileprivate let cgColors: [CGColor]
    fileprivate let locations: [CGFloat]?
    fileprivate var extendEdges: Bool = false

    // Linear
    fileprivate let startPoint: CGPoint
    fileprivate let endPoint: CGPoint

    // Radial
    fileprivate let radial: Bool
    fileprivate let startRadius: CGFloat
    fileprivate let endRadius: CGFloat

    // Cache of draw objects
    fileprivate var gradientCache: CGGradient? = nil

    // MARK: Linear initializers

    /**
     Initializes a linear DrawGradient
     
     - parameter colors: colors to use in the gradient
     - parameter startPoint: CGPoint in the unit coordinate system that specifies where the gradient starts. e.g., a point of (0.5, 0) would start the gradient at the top middle of the rect.
     - parameter endPoint: CGPoint in the unit coordinate system that specifies where the gradient ends
     - parameter locations: If supplied, specifies the relative location along the gradient line where the color stops occur. Must be a value from 0-1. Each location corresponds to a color in the color array. If nil, the locations are spread uniformly from 0 - 1, with the first color having a value of 0 and the last color having a value of 1
     - parameter extendEdges: If true the starting and ending colors will continue to draw beyond the start and end point respectively.
     */
    public init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [CGFloat]?, extendEdges: Bool) {
        self.cgColors = DrawGradient.cgColorsFromUIColors(colors)
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
        self.extendEdges = extendEdges

        radial = false
        startRadius = 0
        endRadius = 0
        super.init()
    }
    
    /**
     Initializes a linear DrawGradient that does not extend edges
     
     - parameter colors: colors to use in the gradient
     - parameter startPoint: CGPoint in the unit coordinate system that specifies where the gradient starts. e.g., a point of (0.5, 0) would start the gradient at the top middle of the rect.
     - parameter endPoint: CGPoint in the unit coordinate system that specifies where the gradient ends
     - parameter locations: If supplied, specifies the relative location along the gradient line where the color stops occur. Must be a value from 0-1. Each location corresponds to a color in the color array. If nil, the locations are spread uniformly from 0 - 1, with the first color having a value of 0 and the last color having a value of 1
     */
    convenience public init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [CGFloat]?) {
        self.init(colors: colors, startPoint: startPoint, endPoint: endPoint, locations: locations, extendEdges: false)
    }

    /**
     Initializes a linear DrawGradient that's either horizontal or vertical
     
     - parameter colors: colors to use in the gradient
     - parameter horizontal: If true, specifies a start point and end point to draw the gradient horizontally across the rect. Otherwise it will draw it vertically across the rect.
     - parameter locations: If supplied, specifies the relative location along the gradient line where the color stops occur. Must be a value from 0-1. Each location corresponds to a color in the color array. If nil, the locations are spread uniformly from 0 - 1, with the first color having a value of 0 and the last color having a value of 1
     */
    convenience public init(colors: [UIColor], horizontal: Bool, locations: [CGFloat]?) {
        if horizontal {
            self.init(colors: colors, startPoint: CGPoint(x:0, y: 0.5), endPoint: CGPoint(x:1, y: 0.5), locations: locations)
        } else {
            self.init(colors: colors, startPoint: CGPoint(x:0.5, y: 0), endPoint: CGPoint(x:0.5, y: 1), locations: locations)
        }
    }

    /**
     Initializes a linear DrawGradient that's either horizontal or vertical with default locations
     
     - parameter colors: colors to use in the gradient
     - parameter horizontal: If true, specifies a start point and end point to draw the gradient horizontally across the rect. Otherwise it will draw it vertically across the rect.
     */
    convenience public init(colors: [UIColor], horizontal: Bool) {
        self.init(colors: colors, horizontal: horizontal, locations: nil)
    }

    // MARK: Radial initializers

    /**
     Initializes a radial DrawGradient
     
     - parameter colors: colors to use in the gradient
     - parameter startRadius: CGFloat specifying at which radius the first color begins. The origin of the circle is the center of the current rect
     - parameter endRadius: CGFloat specifycing at which radius the last color ends.
     - parameter locations: If supplied, specifies the relative location along the gradient radii where the color stops occur. Must be a value from 0-1. Each location corresponds to a color in the color array. If nil, the locations are spread uniformly from 0 - 1, with the first color having a value of 0 and the last color having a value of 1
     - parameter extendEdges: If true the starting and ending colors will continue to draw beyond the start and end point respectively.
     */
    public init(colors: [UIColor], startRadius: CGFloat, endRadius: CGFloat, locations: [CGFloat]?, extendEdges: Bool) {
        self.cgColors = DrawGradient.cgColorsFromUIColors(colors)
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.locations = locations
        self.extendEdges = extendEdges

        radial = true
        startPoint = CGPoint.zero
        endPoint = CGPoint.zero
        super.init()
    }
    
    /**
     Initializes a radial DrawGradient that does not extend edges
     
     - parameter colors: colors to use in the gradient
     - parameter startRadius: CGFloat specifying at which radius the first color begins. The origin of the circle is the center of the current rect
     - parameter endRadius: CGFloat specifycing at which radius the last color ends.
     - parameter locations: If supplied, specifies the relative location along the gradient radii where the color stops occur. Must be a value from 0-1. Each location corresponds to a color in the color array. If nil, the locations are spread uniformly from 0 - 1, with the first color having a value of 0 and the last color having a value of 1
     */
    convenience public init(colors: [UIColor], startRadius: CGFloat, endRadius: CGFloat, locations: [CGFloat]?) {
        self.init(colors: colors, startRadius: startRadius, endRadius: endRadius, locations: locations, extendEdges: false)
    }

    /**
     Initializes a radial DrawGradient with the default locations
     
     - parameter colors: colors to use in the gradient
     - parameter startRadius: CGFloat specifying at which radius the first color begins. The origin of the circle is the center of the current rect
     - parameter endRadius: CGFloat specifycing at which radius the last color ends.
     */
    convenience public init(colors: [UIColor], startRadius: CGFloat, endRadius: CGFloat) {
        self.init(colors: colors, startRadius: startRadius, endRadius: endRadius, locations: nil)
    }

    // MARK:

    override func performActionInContext(_ context: DrawContext) {
        if gradientCache == nil {
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let locations = locations {
                locations.withUnsafeBufferPointer { locationBuffer in
                    gradientCache = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locationBuffer.baseAddress)
                }
            } else {
                gradientCache = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: nil)
            }
        }

        guard let gradient = gradientCache else {
            assert(false, "Somehow do not have a gradient")
            return
        }

        let rect = context.rect
        
        let options: CGGradientDrawingOptions = extendEdges ? [.drawsBeforeStartLocation, .drawsAfterEndLocation] : []

        if radial {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let minDimension = min(rect.width, rect.height) / 2
            context.graphicsContext.drawRadialGradient(gradient, startCenter: center, startRadius: startRadius * minDimension, endCenter: center, endRadius: endRadius * minDimension, options: options)
        } else {
            let start = pointInRect(rect, fromNormalizedPoint: startPoint)
            let end = pointInRect(rect, fromNormalizedPoint: endPoint)
            context.graphicsContext.drawLinearGradient(gradient, start: start, end: end, options: options)
        }
        next?.performActionInContext(context)
    }

    // MARK: Helpers

    fileprivate func pointInRect(_ rect: CGRect, fromNormalizedPoint point: CGPoint) -> CGPoint {
        var newPoint = CGPoint()
        newPoint.x = rect.minX + rect.width*point.x
        newPoint.y = rect.minY + rect.height*point.y
        return newPoint
    }

    // class function so we don't break the swift initializer contract
    fileprivate class func cgColorsFromUIColors(_ colors: [UIColor]) -> [CGColor] {
        return colors.map{ $0.cgColor }
    }
}


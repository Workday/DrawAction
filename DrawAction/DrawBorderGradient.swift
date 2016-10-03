/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation
import CoreGraphics

/// Action that strokes a border filled with a gradient
final public class DrawBorderGradient : DrawAction {


    fileprivate let colors: [UIColor]
    fileprivate let lineWidth: CGFloat
    fileprivate let inset: CGFloat
    fileprivate let horizontal: Bool
    
    /**
     Initializes a DrawBorderGradient
     
     - parameter colors: The colors to use in the gradient
     - parameter lineWidth: The width of the border
     - parameter inset: if non-zero, the amount to try and inset the border relative to the path. The current path's bounding box is used as a to calculate how to scale the path in each dimension by `inset`. This is not expected to work with more complex paths
     - parameter horizontal: If true the gradient is applied left to right, otherwise top to bottom
     */
    public init(colors: [UIColor], lineWidth: CGFloat, inset: CGFloat, horizontal: Bool) {
        self.colors = colors
        self.lineWidth = lineWidth
        self.inset = inset
        self.horizontal = horizontal
        super.init()
    }

    /**
     Initalizes a non-horizontal DrawBorderGradient
     
     - parameter colors: The colors to use in the gradient
     - parameter lineWidth: The width of the border
     - parameter inset: if non-zero, the amount to try and inset the border relative to the path. The current path's bounding box is used as a to calculate how to scale the path in each dimension by `inset`. This is not expected to work with more complex paths
     */
    public convenience init(colors: [UIColor], lineWidth: CGFloat, inset: CGFloat) {
        self.init(colors: colors, lineWidth: lineWidth, inset: inset, horizontal: false)
    }

    /**
     Initializes a non horizontal DrawBorderGradient with a line width 1 and no inset
     
     - parameter colors: The colors to use in the gradient
     */
    public convenience init(colors: [UIColor]) {
        self.init(colors: colors, lineWidth: 1.0, inset: 0.0)
    }

    override func performActionInContext(_ context: DrawContext) {
        guard let path = context.path else {
            assert(false, "No path provided for border gradient draw action")
            return
        }

        context.performDrawActions {
            let pathBounds = path.bounds
            var insetTransform = CGAffineTransform.identity
            if inset != 0 {
                insetTransform = insetTransform.translatedBy(x: pathBounds.midX, y: pathBounds.midY)
                insetTransform = insetTransform.scaledBy(x: (pathBounds.width - inset * 2) / pathBounds.width, y: (pathBounds.height - inset * 2) / pathBounds
                .height)
                insetTransform = insetTransform.translatedBy(x: -pathBounds.midX, y: -pathBounds.midY)
            }

            let insetPath = CGPath(__byStroking: path.cgPath, transform: &insetTransform, lineWidth: lineWidth, lineCap: .butt, lineJoin: .miter, miterLimit: 1.0)!
            context.path = UIBezierPath(cgPath: insetPath)

            // Reuse other actions to clip/gradient with new path
            DrawClip().add(DrawGradient(colors: colors, horizontal: horizontal)).performActionInContext(context)
        }

        next?.performActionInContext(context)
    }
}

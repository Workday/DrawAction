/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that defines a new path for subsequent draw actions
final public class DrawPath : DrawAction {

    private let path: UIBezierPath?
    private let pathGenerator: (CGSize -> UIBezierPath)?

    // Passes in current size of context rect. Gets run at draw time
    /**
     Initializes a DrawPath that generates a path at draw time
     
     - parameter pathGenerator: A closure that gets run at draw time. The size passed in is the size of the current rect. The return value should be a UIBezierPath. 
     The path should be defined relative to the rect with origin zero and the specified size. It then gets translated according to the current rect origin.
     */
    public init(pathGenerator: CGSize -> UIBezierPath) {
        self.pathGenerator = pathGenerator
        path = nil
        super.init()
    }

    /**
     Initializes a DrawPath with a predefined path
     
     - parameter path: A UIBezierPath to apply to future actions. Path will be relative to the current rect at the time of drawing
     */
    public init(path: UIBezierPath) {
        self.path = path
        pathGenerator = nil
        super.init()
    }
    
    /**
     Initializes a DrawPath with a rounded rect path for the current rect
     
     - parameter roundedCorners: the corners to round. Corners not specified will draw right angles
     - parameter radii: A CGSize specifying the horizontal and vertical radii to use for the rounded oval corners.
     */
    convenience public init(roundedCorners corners: UIRectCorner, radii: CGSize) {
        self.init(pathGenerator: { size in
            let rect = CGRect(origin: CGPointZero, size: size)
            return UIBezierPath(roundedRect:CGRectInset(rect, 0.5, 0.5), byRoundingCorners: corners, cornerRadii: radii)
        })
    }

    /**
     Initializes a DrawPath with a rounded rect path for the current rect
     
     - parameter roundedRectRadius: The radius to use for all corners. So each corner will be quarter circles of the specified radius.
     */
    convenience public init(roundedRectRadius radius: CGFloat) {
        self.init(roundedCorners: .AllCorners, radii: CGSize(width: radius, height: radius))
    }

    /**
     Initializes a DrawPath with a path that runs the perimeter of the current rect
     */
    override convenience public init() {
        self.init(pathGenerator: { size in
            return UIBezierPath(rect: CGRect(origin: CGPointZero, size: size))
        })
    }

    /**
     Initializes a DrawPath optionally with an oval in the current rect
     
     - parameter oval: If true, the path defines an oval in the current rect. Otherwise this is the same as calling `init()`

     */
    convenience public init(oval: Bool) {
        if oval {
            self.init(pathGenerator: { size in
                return UIBezierPath(ovalInRect: CGRect(origin: CGPointZero, size: size))
            })
        } else {
            self.init()
        }
    }

    override func performActionInContext(context: DrawContext) {
        guard let path = pathGenerator?(context.rect.size) ?? self.path else {
            // Nil path is valid case if we want to skip path
            next?.performActionInContext(context)
            return
        }

        context.performDrawActions {
            context.path = path
            next?.performActionInContext(context)
        }
    }
}

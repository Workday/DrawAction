/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that applies a clip to all subsequent draw actions based on the current path or rect
final public class DrawClip : DrawAction {

    private let evenOddFill: Bool
    /**
     Initializes a DrawClip
     
     - parameter evenOddFill: Specifies which rule is used to calculate what part of the path should be clipped. If true, uses the even-odd rule, otherwise uses the winding number rule.
     */
    public init(evenOddFill: Bool) {
        self.evenOddFill = evenOddFill
        super.init()

    }

    /**
     Initializes a DrawClip that uses the winding number rule
     */
    override public init() {
        evenOddFill = false
        super.init()
    }

    override func performActionInContext(context: DrawContext) {
        if !context.addPathToGraphicsContext() {
            context.addRectToGraphicsContext()
        }

        context.performGraphicsActions { gContext in
            if evenOddFill {
                CGContextEOClip(gContext)
            } else {
                CGContextClip(gContext)
            }
            next?.performActionInContext(context)
        }
    }
}

/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that sets the opacity of subsequent draw actions. Useful when you want to apply transparency to an entire chain of draw actions without modifying the involved colors.
final public class DrawAlpha : DrawAction {

    fileprivate let alpha: CGFloat
    /**
     Initializes a DrawAlpha
     
     - parameter alpha: The opacity value to apply to subsequent draw actions
    */
    public init(alpha: CGFloat) {
        self.alpha = alpha
        super.init()
    }

    override func performActionInContext(_ context: DrawContext) {
        context.performDrawAndGraphicsActions { gContext in
            gContext.setAlpha(alpha);
            next?.performActionInContext(context)
        }
    }
}

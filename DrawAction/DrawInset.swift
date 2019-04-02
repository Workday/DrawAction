/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that insets the current rect for subsequent draw actions
final public class DrawInset : DrawAction {

    fileprivate let insets: UIEdgeInsets

    /**
     Initializes a DrawInset
     
     - parameter insets: The UIEdgeInsets to apply to the current rect
     */
    public init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init()
    }

    /**
     Initializes a DrawInset
     
     - parameter widthInset: The inset to apply to the left and right side of the current rect
     - parameter heightInset: the inset to apply to the top and bottom side of the current rect
     */
    convenience public init(widthInset: CGFloat, heightInset: CGFloat) {
        let insets = UIEdgeInsets(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)
        self.init(insets: insets)
    }

    /**
     Initializes a DrawInset
     
     - parameter uniformInset: The inset to apply to all sides of the current rect
     */
    convenience public init(uniformInset: CGFloat) {
        let insets = UIEdgeInsets(top: uniformInset, left: uniformInset, bottom: uniformInset, right: uniformInset)
        self.init(insets: insets)
    }

    override func performActionInContext(_ context: DrawContext) {
        context.performDrawActions {
            context.rect = context.rect.inset(by: insets)
            next?.performActionInContext(context)
        }
    }
}

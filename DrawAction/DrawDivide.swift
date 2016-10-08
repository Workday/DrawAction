//
/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that divides the current rect into two pieces, optionally applying a separate action chain to the 'slice' of the rect
final public class DrawDivide : DrawAction {

    fileprivate let amount: CGFloat
    fileprivate let padding: CGFloat
    fileprivate let edge: CGRectEdge
    fileprivate let slice: DrawAction?
    
    /**
     Initializes a DrawDivide. Any actions added after this one (via `add` or `chainActions`) will have their rect set to the remainder rect the results from the divide action.
     
     - parameter amount: The amount, starting from `edge`, that should be carved off the current rect and used as the rect for `slice`
     - parameter padding: Amount to leave off between the slice and the remaining rect
     - parameter edge: The edge of the rect to base the slice from
     - parameter slice: Optional `DrawAction` that will have its rect set to the slice rect.
     */
    public init(amount: CGFloat, padding: CGFloat, edge: CGRectEdge, slice: DrawAction?) {
        self.amount = amount
        self.padding = padding
        self.edge = edge
        self.slice = slice
        super.init()
    }

    /**
     Initializes a DrawDivide. Any actions added after this one (via `add` or `chainActions`) will have their rect set to the remainder rect the results from the divide action.
     
     - parameter amount: The amount, starting from `edge`, that should be carved off the current rect and used as the rect for `slice`
     - parameter edge: The edge of the rect to base the slice from
     - parameter slice: Optional `DrawAction` that will have its rect set to the slice rect.
     */
    public convenience init(amount: CGFloat, edge: CGRectEdge, slice: DrawAction?) {
        self.init(amount: amount, padding: 0, edge: edge, slice: slice)
    }

    /**
     Initializes a DrawDivide allowing you to provide the next action in addition to the slice. This is equivalent to initializing it with just the slice action and then calling `add` with next.
     
     - parameter amount: The amount, starting from `edge`, that should be carved off the current rect and used as the rect for `slice`
     - parameter edge: The edge of the rect to base the slice from
     - parameter slice: Optional `DrawAction` that will have its rect set to the slice rect.
     - parameter next: `DrawAction` to add to the divide. Its rect will be the remainder of the divide operation.
     */
    public convenience init(amount: CGFloat, edge: CGRectEdge, slice: DrawAction?, next: DrawAction) {
        self.init(amount: amount, edge: edge, slice: slice)
        self.add(next)
    }

    /**
     Initializes a DrawDivide. Any actions added after this one (via `add` or `chainActions`) will have their rect set to the remainder rect the results from the divide action.
     
     - parameter amount: The amount, starting from `edge`, that should be carved off the current rect and used as the rect for `slice`
     - parameter padding: Amount to leave off between the slice and the remaining rect
     - parameter edge: The edge of the rect to base the slice from
     - parameter slice: Optional `DrawAction` that will have its rect set to the slice rect.
     - parameter next: `DrawAction` to add to the divide. Its rect will be the remainder of the divide operation.
     */
    public convenience init(amount: CGFloat, padding: CGFloat, edge: CGRectEdge, slice: DrawAction?, next: DrawAction) {
        self.init(amount: amount, padding: padding, edge: edge, slice: slice)
        self.add(next)
    }

    override func performActionInContext(_ context: DrawContext) {

        var sliceRect = CGRect()
        var remainderRect = CGRect()
        (sliceRect, remainderRect) = context.rect.divided(atDistance: amount, from: edge)
        
        if self.padding > 0 {
            (_, remainderRect) = remainderRect.divided(atDistance: padding, from: edge)
        }
        
        context.performDrawActions {
            context.rect = sliceRect
            slice?.performActionInContext(context)
        }

        context.performDrawActions {
            context.rect = remainderRect
            next?.performActionInContext(context)
        }
    }

}

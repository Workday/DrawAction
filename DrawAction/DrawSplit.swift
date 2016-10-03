/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/**
 Action that defines a separate action chain to run before the main chain
 
 Splits define a chain of actions to run before the main chain, resetting state (shadow, path, rect, etc.)
 For example in the following code
 let leftAction = DrawPath(roundedRectRadius: 5).add(DrawFill(color: UIColor.redColor()))
 let rightAction = DrawFill(color: UIColor.blueColor())
 let action = DrawSplit(split: leftAction, next: rightAction)
 
 When `action` is drawn, it will first draw a red oval, followed by a blue rect in the current rect.
 */
final public class DrawSplit : DrawAction {

    fileprivate let split: DrawAction
    
    /**
     Initializes a DrawSplit with the specified chain
     
     - parameter split: A `DrawAction` that will run before any actions that are added after this one
     */
    public init(split: DrawAction) {
        self.split = split
    }

    /**
     Initializes a DrawSplit with the specified chain
     
     - parameter split: A `DrawAction` that will run before any actions that are added after this one
     - parameter next: A `DrawAction` to add, will be run after the split is run.
     */
    convenience public init(split: DrawAction, next: DrawAction) {
        self.init(split: split)
        let _ = self.add(next)
    }

    override func performActionInContext(_ context: DrawContext) {
        split.performActionInContext(context)
        next?.performActionInContext(context)
    }
}

/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Abstract superclass for all actions. By default does nothing other than forward context onto the next action.
@objc public class DrawAction : NSObject {

    private(set) var next: DrawAction?

    override public init()  {}

    /**
     Convenience method for chaining an array of actions together.
     
     - parameter actions:  Array of actions. For each item in the array, it is added to the previous
     */
    final public class func chainActions(actions: [DrawAction]) -> DrawAction {
        guard var finalAction = actions.first else {
            fatalError("Cannot chain an empty array of actions!")
        }

        for action in actions.dropFirst() {
            finalAction = finalAction.add(action)
        }

        return finalAction
    }

    /**
     Add an action to the chain that self is currently a part of. This operation is always an append, it will follow the existing chain until it hits the end. It does not insert it between existing actions
     
     - parameter newNext: The action to add to the chain
    */
    public func add(newNext: DrawAction) -> DrawAction {
        if let next = next {
            next.add(newNext)
        } else {
            next = newNext
        }
        return self
    }

    /**
     Draw the current action and following chain in the specified rect and CGContext
     
     - parameter rect: The rect to initialize the action chain with
     - parameter context: The CGContext to perform the draw operations in.
     */
    public func drawRect(rect: CGRect, inContext context: CGContextRef?) {
        guard let context = context else {
            assertionFailure("Told to draw in a nil context!")
            return
        }
        let drawContext = DrawContext(graphicsContext: context, rect: rect)
        performActionInContext(drawContext)
    }

    // MARK: Subclass methods

    func performActionInContext(context: DrawContext) {
        next?.performActionInContext(context)
    }
}

class DrawContext {
    let graphicsContext: CGContextRef
    var rect: CGRect
    var path: UIBezierPath?

    private var contextStack: [(CGRect, UIBezierPath?)] = []

    init(graphicsContext: CGContextRef, rect: CGRect) {
        self.graphicsContext = graphicsContext
        self.rect = rect
    }

    private func saveState() {
        let currentValue = (rect, path)
        contextStack.append(currentValue)
    }

    private func restoreState() {
        guard let (rect, path) = contextStack.popLast() else {
            assert(false, "Unbalanced calls to saveState / restoreState")
            return
        }

        self.rect = rect
        self.path = path
    }

    // Performs 'action' inside a save/restore of the draw context (which tracks the current rect/path of the draw)
    func performDrawActions(@noescape action: Void -> Void) {
        saveState()
        action()
        restoreState()
    }

    // Performs 'action' inside a CGContext save/restore state batch, passing in the context for convenience
    func performGraphicsActions(@noescape action: CGContextRef -> Void) {
        CGContextSaveGState(graphicsContext)
        action(graphicsContext)
        CGContextRestoreGState(graphicsContext)
    }

    // Combines the two above for one closure for both save/restores
    func performDrawAndGraphicsActions(@noescape action: CGContextRef -> Void) {
        saveState()
        CGContextSaveGState(graphicsContext)
        action(graphicsContext)
        CGContextRestoreGState(graphicsContext)
        restoreState()
    }

    // Returns whether the path was added or not
    func addPathToGraphicsContext() -> Bool {
        guard let path = path else {
            return false
        }

        CGContextSaveGState(graphicsContext)
        CGContextTranslateCTM(graphicsContext, rect.minX, rect.minY)
        CGContextAddPath(graphicsContext, path.CGPath)
        CGContextRestoreGState(graphicsContext)
        return true
    }

    func addRectToGraphicsContext() {
        CGContextAddRect(graphicsContext, rect)
    }
}

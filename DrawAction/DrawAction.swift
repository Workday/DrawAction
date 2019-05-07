/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Abstract superclass for all actions. By default does nothing other than forward context onto the next action.
@objcMembers open class DrawAction : NSObject {

    fileprivate(set) var next: DrawAction?

    override public init()  {}

    /**
     Convenience method for chaining an array of actions together.
     
     - parameter actions:  Array of actions. For each item in the array, it is added to the previous
     */
    final public class func chainActions(_ actions: [DrawAction]) -> DrawAction {
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
    @discardableResult open func add(_ newNext: DrawAction) -> DrawAction {
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
    open func drawRect(_ rect: CGRect, inContext context: CGContext?) {
        guard let context = context else {
            assertionFailure("Told to draw in a nil context!")
            return
        }
        let drawContext = DrawContext(graphicsContext: context, rect: rect)
        performActionInContext(drawContext)
    }

    // MARK: Subclass methods

    func performActionInContext(_ context: DrawContext) {
        next?.performActionInContext(context)
    }
}

class DrawContext {
    let graphicsContext: CGContext
    var rect: CGRect
    var path: UIBezierPath?

    fileprivate var contextStack: [(CGRect, UIBezierPath?)] = []

    init(graphicsContext: CGContext, rect: CGRect) {
        self.graphicsContext = graphicsContext
        self.rect = rect
    }

    fileprivate func saveState() {
        let currentValue = (rect, path)
        contextStack.append(currentValue)
    }

    fileprivate func restoreState() {
        guard let (rect, path) = contextStack.popLast() else {
            assert(false, "Unbalanced calls to saveState / restoreState")
            return
        }

        self.rect = rect
        self.path = path
    }

    // Performs 'action' inside a save/restore of the draw context (which tracks the current rect/path of the draw)
    func performDrawActions(_ action: () -> Void) {
        saveState()
        action()
        restoreState()
    }

    // Performs 'action' inside a CGContext save/restore state batch, passing in the context for convenience
    func performGraphicsActions(_ action: (CGContext) -> Void) {
        graphicsContext.saveGState()
        action(graphicsContext)
        graphicsContext.restoreGState()
    }

    // Combines the two above for one closure for both save/restores
    func performDrawAndGraphicsActions(_ action: (CGContext) -> Void) {
        saveState()
        graphicsContext.saveGState()
        action(graphicsContext)
        graphicsContext.restoreGState()
        restoreState()
    }

    // Returns whether the path was added or not
    func addPathToGraphicsContext() -> Bool {
        guard let path = path else {
            return false
        }

        graphicsContext.saveGState()
        graphicsContext.translateBy(x: rect.minX, y: rect.minY)
        graphicsContext.addPath(path.cgPath)
        graphicsContext.restoreGState()
        return true
    }

    func addRectToGraphicsContext() {
        graphicsContext.addRect(rect)
    }
}

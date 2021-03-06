/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that performs a fill on the current path or rect
final public class DrawFill : DrawAction {

    fileprivate let color: UIColor
    fileprivate let blendMode: CGBlendMode
    
    /**
     Initializes a DrawFill
     
     - parameter color: color to fill with
     - parameter blendMode: The `CGBlendMode` to use during the fill operation
     */
    public init(color: UIColor, blendMode: CGBlendMode) {
        self.color = color
        self.blendMode = blendMode
    }

    /**
     Initializes a DrawFill using `CGBlendMode.Normal` blend mode
     
     - parameter color: color to fill with
     
     */
    public convenience init(color: UIColor) {
        self.init(color: color, blendMode: .normal)
    }

    override func performActionInContext(_ context: DrawContext) {
        context.performGraphicsActions { gContext in
            gContext.setBlendMode(blendMode)
            gContext.setFillColor(color.cgColor)
            if context.addPathToGraphicsContext() {
                gContext.fillPath()
            } else {
                gContext.fill(context.rect)
            }
        }
        next?.performActionInContext(context)
    }

}

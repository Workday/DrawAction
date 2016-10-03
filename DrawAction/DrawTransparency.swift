/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/**
 Action that begins a separate CGContext transparency layer. All actions performed after this action will be treated as one atomic drawing operation for the current context.
 For example, if a DrawShadow is earlier in the chain, and two DrawFills with different rects are defined later in the chain, the shadow will be applied once to the union of the fill operations, rather
 than once for each fill (preventing shadow overlap)
 
 If you're looking to adjust the transparency of all drawing, see 'DrawAlpha' instead
 */
final public class DrawTransparency : DrawAction {

    override func performActionInContext(_ context: DrawContext) {
        context.performDrawAndGraphicsActions { gContext in
            gContext.clip(to: context.rect)
            gContext.beginTransparencyLayer(auxiliaryInfo: nil)
            next?.performActionInContext(context)
            gContext.endTransparencyLayer()
        }
    }
}

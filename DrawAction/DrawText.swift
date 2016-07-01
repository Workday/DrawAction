/*
 * Copyright 2016 Workday, Inc.
 *
 * This software is available under the MIT license.
 * Please see the LICENSE.txt file in this project.
 */

import Foundation

/// Action that renders text in the current rect
final public class DrawText : DrawAction {
    
    private let attributedText: NSAttributedString
    private let drawingOptions: NSStringDrawingOptions
    
    /**
     Initializes a DrawText with the specified attributed string
     
     - parameter attributedText: NSAttributedString to render. See NSAttributedString documentation for the supported attributes
     - parameter drawOptions: Drawing options to use when rendering the attributed text. See `NSStringDrawingOptions` in the `NSString` documentation for the possible values and their implications.
     */
    public init(attributedText: NSAttributedString, drawOptions:NSStringDrawingOptions) {
        self.attributedText = attributedText
        self.drawingOptions = drawOptions
        super.init()
    }
    
    /**
     Initializes a DrawText with the specified attributed string. Drawing is done with the `UsesLineFragmentOrigin` and `UsesFontLeading` draw options.
     
     - parameter attributedText: NSAttributedString to render
     */
    convenience public init(attributedText: NSAttributedString) {
        self.init(attributedText: attributedText, drawOptions: [.UsesLineFragmentOrigin, .UsesFontLeading])
    }
    
    /**
     Initializes a DrawText with the specified properties
     
     - parameter text: The string to render
     - parameter font: The font to render the text with
     - parameter color: The color to stroke the font with
     - parameter alignment: Text alignment to use when rendering
     - parameter lineBreakMode: Line break mode to use when rendering
     - parameter underlineStyle: Specifies how to underline the text
     */
    convenience public init(text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment, lineBreakMode: NSLineBreakMode, underlineStyle: NSUnderlineStyle) {
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = alignment
        
        let attributes: [String : AnyObject] = [
            NSFontAttributeName : font,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: color,
            NSUnderlineStyleAttributeName: underlineStyle.rawValue
        ]
        
        self.init(attributedText: NSAttributedString(string: text, attributes: attributes))
    }

    /**
     Initializes a DrawText with the specified properties
     
     - parameter text: The string to render
     - parameter font: The font to render the text with
     - parameter color: The color to stroke the font with
     - parameter alignment: Text alignment to use when rendering
     - parameter lineBreakMode: Line break mode to use when rendering
     */
    convenience public init(text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment, lineBreakMode: NSLineBreakMode) {
        self.init(text: text, font: font, color: color, alignment: alignment, lineBreakMode: lineBreakMode, underlineStyle: .StyleNone)
    }
    
    /**
     Initializes a DrawText with the specified properties
     
     - parameter text: The string to render
     - parameter font: The font to render the text with
     - parameter color: The color to stroke the font with
     */
    convenience public init(text: String, font: UIFont, color: UIColor) {
        self.init(text: text, font: font, color: color, alignment: .Left, lineBreakMode: .ByWordWrapping)
    }
    
    /**
     Initializes a DrawText with the specified properties
     
     - parameter text: The string to render
     - parameter font: The font to render the text with
     */
    convenience public init(text: String, font: UIFont) {
        self.init(text: text, font: font, color: UIColor.blackColor())
    }
    
    override func performActionInContext(context: DrawContext) {
        var textRect = context.rect
        let textHeight = attributedText.boundingRectWithSize(textRect.size, options: self.drawingOptions, context:nil).height
        
        textRect.origin.y += (textRect.size.height - textHeight) / 2
        context.performGraphicsActions { gContext in
            UIGraphicsPushContext(gContext)
            attributedText.drawWithRect(CGRectIntegral(textRect), options: drawingOptions, context: nil)
            UIGraphicsPopContext()
        }
        next?.performActionInContext(context)
    }
}

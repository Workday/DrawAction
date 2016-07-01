# DrawAction

DrawAction is a simple swift library for composing drawing operations in iOS. 

### Usage

The `DrawAction` class is the abstract superclass for every action. It defines the base ability to add additional actions to the end of the current chain, and to initiate drawing by supplying a CGRect and a CGGraphicsContext. 

### Actions

The different available actions can be thought of as belonging to one of two categories: Graphics Actions and Composing Actions

##### Graphics Actions

These actions do the actual drawing, and don't affect the state of drawing other than whatever action is being performed. This includes actions like `DrawBorder`, `DrawFill`, `DrawLine`, etc.

##### Composing Actions

These actions change the context of later actions. This includes changing the current rect or path future actions can use, or creating a separate branch of drawing actions in the chain. This includes actions like `DrawInset`, `DrawPath`, `DrawSplit` etc.

Refer to the comments in the source for further information on specific actions

### Examples

Fill a blue rect with a red border  

    DrawFill(color: UIColor.blueColor()).add(DrawBorder(color: UIColor.redColor())).drawRect(rect, inContext: UIGraphicsGetCurrentContext())

Fill two rects next to each other, one with a shadow the other without.

    let leftRect = DrawFill(color: UIColor.blueColor())
    let rightRect = DrawShadow(color: UIColor.blackColor(), blur: 2, offset: CGSize(width: -1, height: 1)).add(DrawFill(color: UIColor.redColor()))
    DrawDivide(amount: rect.width/2 - 5, padding: 10, edge: .MinXEdge, slice: leftRect, next: rightRect).drawRect(rect, inContext: UIGraphicsGetCurrentContext())


Draw a rounded rect with a border gradient, background gradient and shadow, with "Hello world" printed in the middle with a shadow

    let backgroundAction = DrawAction.chainActions([
            DrawShadow(color: UIColor.blackColor(), blur: 1, offset: CGSizeMake(0, 1)),
            DrawTransparency(), // All subsequent drawing operations will be in a separate 'transparency layer', so the shadow will be applied even for the gradient
            DrawInset(uniformInset: 2),
            DrawPath(roundedRectRadius: 5),
            DrawClip(), // Gradients don't respect context paths by default so we clip to the path
            DrawGradient(colors: [UIColor.lightGrayColor(), UIColor.darkGrayColor()], horizontal: true),
            DrawBorderGradient(colors: [UIColor.darkGrayColor(), UIColor.lightGrayColor()], lineWidth: 4, inset: 0)
    ])

    // White text with shadow
    let textAction = DrawShadow(color: UIColor.blackColor(), blur: 0, offset: CGSizeMake(1, 1)).add(
            DrawText(text: "Hello World", font: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), color: UIColor.whiteColor(), alignment: .Center, lineBreakMode: .ByTruncatingTail))

    let drawSize = CGSize(width: 100, height: 30)
    let drawRect = CGRect(origin: CGPoint(x: rect.midX - drawSize.width/2, y: rect.midY - drawSize.height/2), size: drawSize)

    DrawSplit(split: backgroundAction, next: textAction).drawRect(drawRect, inContext: UIGraphicsGetCurrentContext())

To see these examples in action, and to test other actions, run the `DrawActionExample` app in the project

### License

DrawAction is available under the MIT license. See the LICENSE file for more info.

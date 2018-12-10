//
//  ParagraphStyleView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/3.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ParagraphStyleView.h"
#import <CoreText/CoreText.h>

@implementation ParagraphStyleView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor brownColor];
    }
    return self;
}

NSAttributedString *applyParagraph(CFStringRef fontName, CGFloat pointSize, NSString *plainText,CGFloat lineSpaceInc) {
    // Create font so we can determine its height.
    CTFontRef font = CTFontCreateWithName(fontName, pointSize, NULL);
    
    // Set linespacing.
//    CGFloat lineSpacing = (CTFontGetLeading(font) + lineSpaceInc) * 2;
    
    // Set a specifier property and assign the value attached the valueSize.
    CTParagraphStyleSetting setting;
    setting.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
//    setting.valueSize = sizeof(CGFloat);
//    setting.value = &lineSpacing;
    
    CTParagraphStyleRef paraStyle = CTParagraphStyleCreate(&setting, 1);
    // Add paragraph style to dictionary.
    NSDictionary *dict = @{
                           (__bridge id)kCTFontAttributeName:(__bridge id)font,
                           (__bridge id)kCTParagraphStyleAttributeName: (__bridge id)paraStyle
                           };
    CFRelease(paraStyle);
    CFRelease(font);
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:plainText attributes:dict];
    return attributeString;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Initialize graphics context in iOS
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip context coordinates, only in iOS
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set text matrix
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CFStringRef fontName = CFSTR("Didot-Italic");
    CGFloat pointSize = 24.0;
    CFStringRef string = CFSTR("Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one,and I look at it, until it begins to shine.");
    // Apply Para stype
    NSAttributedString *attrString = applyParagraph(fontName, pointSize, (__bridge NSString *)string, 50.0);
    
    // Put the attributed string with applied paragraph stype into a framesetter.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    // Create path fill the view.
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    
    // Create a frame in which to draw.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // Draw para.
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}


@end

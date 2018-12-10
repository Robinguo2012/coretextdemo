//
//  ManualBreaklineView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/3.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ManualBreaklineView.h"
#import <CoreText/CoreText.h>

@implementation ManualBreaklineView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
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
    
    double width = self.bounds.size.width/2;
    CGPoint textPosition = CGPointMake(10.0, 10.0);
    CFAttributedStringRef string = (CFAttributedStringRef)CFBridgingRetain(self.attributeString);
    
    // Create a typesetter using the attributed string
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(string);
    
    // Find a break for line from the beginning of the string to the given width.
    CFIndex start = 0;
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, width);
    
    // Use the retured character count (to the break) to create a line.
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
    
    // Get the offset needed to center the line.
    float flush = 0.5;
    double penOffset = CTLineGetPenOffsetForFlush(line, flush, width);
    
    // Move the given text drawing position by the calculted offset and draw the line.
    CGContextSetTextPosition(context, textPosition.x + penOffset, textPosition.y);
    
    CTLineDraw(line, context);
    CFRelease(typesetter);
    // Move the index beyond the line break.
    start += count;
    
    CFRelease(line);

}


@end

//
//  ParagraphView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/2.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ParagraphView.h"
#import <CoreText/CoreText.h>

@implementation ParagraphView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor greenColor];
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
    
    // Create path which area you will be draw text, the path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple, initialize a rect bounds
    CGRect bounds = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
    CGPathAddRect(path, NULL, bounds);
    
    // Initialize a string,.
    CFStringRef string = CFSTR("Hello, world. I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine");
    
    // Create a attributed string with max length of 0.
    // the max lenght is a hint as how much internal storage to reserve. 0 means no hint.
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    // Copy the textstring into the newly created attrstring
    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), string);
    
    // Create a color that will be added as an attribute to the attrString.
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = { 1.0, 0.0, 0.0, 0.8 };
    CGColorRef red = CGColorCreate(rgbColorSpace, components);
    CFRelease(rgbColorSpace);
    
    // Set the first 12 character to red.
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 12), kCTForegroundColorAttributeName, red);
    
    // Create framesetter with the attributed string
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    // Create a frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, context);
    
    // Release the objects we used.
    CFRelease(framesetter);
    CFRelease(path);
    CFRelease(frame);
}



@end

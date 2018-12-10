//
//  ColumnarTextView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/2.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "ColumnarTextView.h"
#import <CoreText/CoreText.h>

@implementation ColumnarTextView
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (CFArrayRef)createColumnsWithColumncount:(NSInteger)columnCount {
    int column;
    CGRect *columnRects = (CGRect *)calloc(columnCount, sizeof(*columnRects));
    // Set the first column cover entire view.
    columnRects[0] = self.bounds;
    
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(self.bounds)/columnCount;
    for (column = 0; column < columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column], &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    // Insert all columns by a few pixels margin.
    for (column = 0; column < columnCount; column++) {
        columnRects[column] = CGRectInset(columnRects[column], 10, 10);
    }
    
    // Create an array of layout paths, one for each column.
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, columnCount, &kCFTypeArrayCallBacks);
    for (column = 0; column < columnCount; column++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRects[column]);
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    free(columnRects);
    return array;
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
    
    CFArrayRef array = [self createColumnsWithColumncount:4];
    
    // Create new framesetter with attributed string.
    CTFramesetterRef framestter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributeString);
    
    // Create frame
    int column;
    CFIndex startIndex = 0;
    CFIndex pathCount = CFArrayGetCount(array);
    
    for (column = 0; column < pathCount; column++) {
        // Get the path for this column.
        CGPathRef path = CFArrayGetValueAtIndex(array, column);
        
        // Create a frame for this column and draw it.
        /*
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = { 0.0, 0.0, 1.0, 0.8 };
        CGColorRef red = CGColorCreate(rgbColorSpace, components);

        CFStringRef keys[] = {kCTBackgroundColorAttributeName};
        CFTypeRef values[] = {red};
        
        CFDictionaryRef attrs = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
         */
        
        CTFrameRef frame = CTFramesetterCreateFrame(framestter, CFRangeMake(startIndex, 0), path, NULL);
        CTFrameDraw(frame, context);
        
        // Start the next frame at the first character not visible in this frame
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
    }
    
    CFRelease(framestter);
    CFRelease(array);
}


@end

//
//  SimpleTextView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/2.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "SimpleTextView.h"
#import <CoreText/CoreText.h>

@implementation SimpleTextView
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // Initialize graphics context in iOS
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip context coordinates, only in iOS
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set text matrix
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CFStringRef string = CFSTR("This is a single line text for core text.This is a single line text for core text.This is a single line text for core text");
    
    CTFontRef font = CTFontCreateWithName(kCTFontSlantTrait, 14.0, NULL);
    CFStringRef keys[] = {kCTFontNameAttribute};
    CFTypeRef values[] = {font};
    CFDictionaryRef attrs = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, string, attrs);

    CFRelease(string);
    CFRelease(attrs);
    
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    // Set text position and draw line in graphics context.
    // TextPosition position where text start render.
    CGContextSetTextPosition(context, 0, 0);
    CTLineDraw(line, context);
    
    CFRelease(line);
}


@end

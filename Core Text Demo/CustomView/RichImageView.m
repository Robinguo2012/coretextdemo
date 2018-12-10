//
//  RichImageView.m
//  Core Text Demo
//
//  Created by Sailer on 2018/12/10.
//  Copyright © 2018 StarLink. All rights reserved.
//

#import "RichImageView.h"
#import <CoreText/CoreText.h>
#import "CTPageInfo.h"

@interface RichImageView()

@property (nonatomic,strong) CTPageInfo *pageInfo;

@end


@implementation RichImageView
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
        _pageInfo = [CTPageInfo new];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /**
     图文混排的点击事件
     第一步 在view 的 touch方法中获取点击到的point,
     1. 首先判断是否点击到图片;
     2. 点击到文字
        1> 遍历每个文字,获取每个文字的CTRun,通过CTRun 获取该字符的glyph 信息.
        2> 根据glyph 获取字符的frame, 通过比对point 是否在frame 中确定是否点击该字符.
     */
    UITouch *touch = [touches anyObject];
    CGPoint point = [self convertPointToiOS:[touch locationInView:self]];
    if ([self isInImgFrame:point]) {
        return;
    }
    [self clickInText:point];
}

// 因为mac OS坐标系原点和iOS坐标系原点不同
- (CGPoint)convertPointToiOS:(CGPoint)point {
    return CGPointMake(point.x, self.bounds.size.height - point.y);
}

- (BOOL)isInImgFrame:(CGPoint)point {
    for (NSValue *rectValue in self.pageInfo.imgsInfo) {
        CGRect imgRect = [rectValue CGRectValue];
        if (CGRectContainsPoint(imgRect, point)) {
            NSLog(@"点击了图片");
            return YES;
        }
    }
    return NO;
}

- (void)clickInText:(CGPoint)point {
    NSArray *allLines = (NSArray *)CTFrameGetLines(self.pageInfo.frame);
    CGPoint origins[allLines.count];
    CFRange ranges[allLines.count];
    /**
     CoreText 中获取所有(如这里获取点或获取字符文本)时,一般是(0,0)
     */
    CTFrameGetLineOrigins(self.pageInfo.frame, CFRangeMake(0, 0), origins);
    
    for (int i=0; i<allLines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)allLines[i];
        ranges[i] = CTLineGetStringRange(line);
    }
    
    for (int j=0; j<self.pageInfo.length; j++) {
        long maxLoc;
        int lineNum;
        for (int k=0; k<allLines.count; k++) {
            CFRange range = ranges[k];
            maxLoc = range.location + range.length - 1;
            if (j<=maxLoc) {
                lineNum = j;
                break;
            }
        }
        
        CTLineRef line = (__bridge CTLineRef)allLines[j];
        CGPoint point = origins[j];
    }
    
}

- (CGRect)frameFromLine:(CTLineRef)line atIndex:(CFIndex)index point:(CGPoint)point {
    CGFloat offsetX = CTLineGetOffsetForStringIndex(line, index, NULL); // 获取字符相对于line 原点的偏移量
    CGFloat offsetX1 = CTLineGetOffsetForStringIndex(line, index + 1, NULL); // 获取下一个字符的偏移量,注意: 当index 大于当前line 的最后一个字符是 offsetX = offsetX + 字符宽;
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip context coordinates, only in iOS
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set text matrix
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    /**
     图文混排
     首先根据根据attributeString 生成一个frameSetter对象,然后通过设置一个图片的占位符.设置CTRunDelegate 设置图片信息的回调,计算图片的frame
     */
    NSString *text = @"首先根据attributeString 生成一个frameSetter对象设置CTRunDelegate 设置图片信息的回调,计算图片的frame";
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.getAscent = &getAscent;
    callBacks.getDescent = &getDescent;
    callBacks.getWidth = &getWidth;
    
    NSDictionary *conDict = @{@"width":@40,@"height":@40};
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *)conDict);
    
    // 插入图片的占位符
    unichar placeHolder = 0xFFFC;
    NSString *str = [NSString stringWithCharacters:&placeHolder length:1];
    NSMutableAttributedString *aPlaceHolder = [[NSMutableAttributedString alloc] initWithString:str];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)aPlaceHolder, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    [attributeString insertAttributedString:aPlaceHolder atIndex:40];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeString.length), path, NULL);
    self.pageInfo.frame = frame;
    
    CTFrameDraw(frame, context);
    
    UIImage *image = [UIImage imageNamed:@"zombie2.jpg"];
    CGRect imgFrame = [self frameForImageWithFrame:frame context:context];
    CGContextDrawImage(context, imgFrame, image.CGImage);
    
    NSValue *imgR = [NSValue valueWithCGRect:imgFrame];
    [self.pageInfo.imgsInfo addObject:imgR];
    
    // 释放CoreText 对象
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}

- (CGRect)frameForImageWithFrame:(CTFrameRef)frame context:(CGContextRef)context {
    NSArray *allLines = (NSArray *)CTFrameGetLines(frame);
    NSInteger count = [allLines count];
    CGPoint points[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);// 获取frame所有line的原点
    
    for (int i = 0; i<count; i++) {
        CTLineRef line = (__bridge CTLineRef)allLines[i];
        NSArray *allRuns = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j=0; j<allRuns.count; j++) {
            CTRunRef run = (__bridge CTRunRef)allRuns[j];
            NSDictionary *dic = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[dic valueForKey:(NSString *)kCTRunDelegateAttributeName];
            if (!delegate) {
                continue;
            }
            NSDictionary *refCon = (NSDictionary *)CTRunDelegateGetRefCon(delegate);
            if (![refCon isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGPoint point = points[i];
            CGFloat ascent;
            CGFloat descent;
            CGRect boundsRun;
            
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent;
            CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            boundsRun.origin.x = offsetX;
            boundsRun.origin.y = point.y - descent;
            CGPathRef path = CTFrameGetPath(frame);
            CGRect colRect = CGPathGetPathBoundingBox(path);
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            return imageBounds;
        }
    }
    
    return CGRectZero;
}



static CGFloat getAscent(void *refCon) {
    NSDictionary *dic = (__bridge NSDictionary *)refCon;
    return [[dic objectForKey:@"height"] floatValue];
}

static CGFloat getDescent(void *refCon) {
    return 0.0f;
}

static CGFloat getWidth(void *refCon) {
    NSDictionary *dic = (__bridge NSDictionary *)refCon;
    return [[dic objectForKey:@"width"] floatValue];
}


@end

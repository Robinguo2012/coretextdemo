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
{
    CTFrameRef _frame;
    long _length;
    CGRect _imgRect;
    NSMutableArray *_arrText;
}
//@property (nonatomic,strong) CTPageInfo *pageInfo;

@end


@implementation RichImageView
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
//        _pageInfo = [CTPageInfo new];
        _arrText = @[].mutableCopy;
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
    CGPoint point = [touch locationInView:self];
    if ([self isInImgFrame:point]) {
        return;
    }
    [self clickInText:point];
}

// 因为mac OS坐标系原点和iOS坐标系原点不同
- (CGPoint)convertPointToiOS:(CGPoint)point {
    return CGPointMake(point.x, self.bounds.size.height - point.y);
}

- (CGRect)convertRect:(CGRect)rect {
    return CGRectMake(rect.origin.x, self.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
}

- (BOOL)isInImgFrame:(CGPoint)point {
//    for (NSValue *rectValue in self.pageInfo.imgsInfo) {
//        CGRect imgRect = [rectValue CGRectValue];
//
//    }
    CGRect textRectFromScreen = [self convertRect:_imgRect];
    if (CGRectContainsPoint(textRectFromScreen, point)) {
        NSLog(@"点击了图片");
        return YES;
    }
    
    return NO;
}

- (void)clickInText:(CGPoint)point {
    
    /**
     这里用有事件的CTRun 的方法来执行字符的点击事件
     更主流的做法是通过
     ```
     CFIndex CTLineGetStringIndexForPosition(CTLineRef, CGPoint);
     ```
     但是这有一个问题, 实际响应区域比预期的响应区域左偏移大概半个字.

     */
    
    [_arrText enumerateObjectsUsingBlock:^(NSValue  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = [obj CGRectValue];
        CGRect textRectFromScreen = [self convertRect:rect];
        if (CGRectContainsPoint(textRectFromScreen, point)) {
            [self click];
            *stop = YES;
        }
    }];
    
//    NSLog(@"你没有点击到文字");
}

- (CGRect)frameFromLine:(CTLineRef)line atIndex:(CFIndex)index point:(CGPoint)origin {
    CGFloat offsetX = CTLineGetOffsetForStringIndex(line, index, NULL); // 获取字符相对于line 原点的偏移量
    CGFloat offsetX1 = CTLineGetOffsetForStringIndex(line, index + 1, NULL); // 获取下一个字符的偏移量,注意: 当index 大于当前line 的最后一个字符是 offsetX = offsetX + 字符宽;
    offsetX += origin.x;
    offsetX1 += origin.x;
    CGFloat offsetY = origin.y; // 获取line的起点Y
    CGFloat lineAscent;
    CGFloat lineDescent;
    CTRunRef currentRun;
    NSArray *allRuns = (NSArray *)CTLineGetGlyphRuns(line);
    for (int i=0; i<allRuns.count; i++) {
        CTRunRef run = (__bridge CTRunRef)allRuns[i];
        CFRange range = CTRunGetStringRange(run);
        NSRange rangeOC = NSMakeRange(range.location, range.length);
        if ([self isIndex:index inRange:rangeOC]) {
            currentRun = run;
            break;
        }
    }
    
    CTRunGetTypographicBounds(currentRun, CFRangeMake(0, 0), &lineAscent, &lineDescent, NULL);
    offsetY -= lineDescent;
    CGFloat height = lineDescent + lineAscent;
    return CGRectMake(offsetX, offsetY, offsetX1 - offsetX, height);
}

- (BOOL)isIndex:(NSInteger)index inRange:(NSRange)range {
    if (index >= range.location && index < range.location + range.length - 1) {
        return YES;
    }
    return NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
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
    NSString *text = @"首先根据 @attributeString  生成一个frameSetter对象设置CTRunDelegate 设置图片信息的回调,计算图片的frame";
    
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
    
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, attributeString.length)];
    
    NSDictionary *activeAttr = @{NSForegroundColorAttributeName:[UIColor redColor],@"click":NSStringFromSelector(@selector(click))};
    [attributeString addAttributes:activeAttr range:NSMakeRange(4, 15)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);

    _frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeString.length), path, NULL);
//    self.pageInfo.frame = frame;
    
    CTFrameDraw(_frame, context);
    
    UIImage *image = [UIImage imageNamed:@"zombie2.jpg"];
    [self handleActiveAttributedString:_frame context:context];
    
    CGContextDrawImage(context, _imgRect, image.CGImage);

    
    // 释放CoreText 对象
    CFRelease(_frame);
    CFRelease(path);
    CFRelease(frameSetter);
}

- (void)handleActiveAttributedString:(CTFrameRef)frame context:(CGContextRef)context {
    NSArray *allLines = (NSArray *)CTFrameGetLines(frame);
    NSInteger count = [allLines count];
    CGPoint points[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);// 获取frame所有line的原点
    
    for (int i = 0; i<count; i++) {
        CTLineRef line = (__bridge CTLineRef)allLines[i];
        NSArray *allGlyphRuns = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j=0; j<allGlyphRuns.count; j++) {
            CTRunRef run = (__bridge CTRunRef)allGlyphRuns[j];
            NSDictionary *dic = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[dic valueForKey:(NSString *)kCTRunDelegateAttributeName];
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            
            if (!delegate) {
                if (attributes[@"click"]) {
                    CGRect runRect = [self rectFromFrame:frame Line:line run:run origin:points[i]];
                    [_arrText addObject:[NSValue valueWithCGRect:runRect]];
                }
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
            _imgRect = imageBounds;
        }
    }
}

- (CGRect)rectFromFrame:(CTFrameRef)frame Line:(CTLineRef)line run:(CTRunRef)run origin:(CGPoint)origin {
    CGFloat descent;
    CGFloat ascent;
    CGRect boundsRect;
    boundsRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
    boundsRect.size.height = descent + ascent;
    CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);// 获取X的偏移量
    boundsRect.origin.x = origin.x + offsetX;
    // 获取boundsRect.origin.y
    boundsRect.origin.y = origin.y - descent;
    CGPathRef path = CTFrameGetPath(frame); // 获取绘制区域
    CGRect colRect = CGPathGetBoundingBox(path); // 获取裁剪区域边框
    CGRect deleteRect = CGRectOffset(boundsRect, colRect.origin.x, colRect.origin.y);
    return deleteRect;
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

- (void)click {
    NSLog(@"click text");
}

@end

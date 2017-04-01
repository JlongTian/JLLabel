//
//  JLLabel.m
//  JLLabel
//
//  Created by 张天龙 on 17/3/31.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "JLLabel.h"
#import <CoreText/CoreText.h>
#import "JLAsyncDisplayLayer.h"


#define JL_RGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kCellTextHighlightColor JL_RGB(82,126,173,1.0)
#define kCellTextHighlightBackgroundColor JL_RGB(191,223,254,1.0)

@interface JLLabel ()
/**
 以“@”开头，以空格结尾的字符串range数组
 */
@property (nonatomic,strong) NSMutableArray *substringRanges;
/**
 当前用户点击的位置
 */
@property (nonatomic,strong) JLSubstringRange  *selectStrRange;
/**
 CTFrameRef
 */
@property (nonatomic,assign) CTFrameRef ctFrame;

/**
 正则表达式数组，可识别一下三种情况的字符串
 1.“@”开头空格结尾 
 2.以“#”开头和结尾 
 3.以http(s)://开头，空格结尾
 */
@property (nonatomic,strong) NSArray *patterns;

@end

@implementation JLLabel

#pragma mark - 初始化

+(Class)layerClass{
    
    return [JLAsyncDisplayLayer class];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.font = [UIFont systemFontOfSize:13.0];
        self.textColor = [UIColor blackColor];
        self.highlightTextColor = kCellTextHighlightColor;
        self.backgroundColor = [UIColor whiteColor];
        self.highlightBg = kCellTextHighlightBackgroundColor;
        _patterns = @[
        @"(@([^@\\s]*)\\s)",
        @"(#([^>#]*)#)",
        @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])"
        ];

    }
    return self;
}

+(instancetype)labelWithText:(NSString *)text font:(UIFont *)font tapCallBack:(JLLabelTapCallBack)tapCallBack{
    
    JLLabel *label = [[self alloc] init];
    label.text = text;
    label.font = font;
    label.tapCallBack = tapCallBack;
    return label;
    
}

- (NSMutableArray *)substringRanges{
    
    if (_substringRanges==nil) {
        _substringRanges = [NSMutableArray array];
    }
    return _substringRanges;
    
}

- (void)setCtFrame:(CTFrameRef)ctFrame{
    
    //要加锁，不然老是刷新，不断操作内存，会崩溃
    @synchronized(self) {
        
        if (_ctFrame!=ctFrame) {
            if (_ctFrame) {
                CFRelease(_ctFrame);
            }
            CFRetain(ctFrame);
            _ctFrame = ctFrame;
        }
    
    }
    
}

- (void)setText:(NSString *)text{
    
    _text = text;
    
    [self regularExpressionWithSearchText:text];
    [self setNeedsDisplay];
    
}

- (void)setFont:(UIFont *)font{
    
    _font = font;
    
    [self setNeedsDisplay];
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    
    //赋值给图层才有颜色
    self.layer.backgroundColor = backgroundColor.CGColor;
    [self setNeedsDisplay];
    
}

- (void)setTextColor:(UIColor *)textColor{
    
    _textColor = textColor;
    [self setNeedsDisplay];
    
}

-(void)setHighlightTextColor:(UIColor *)highlightTextColor{
    
    _highlightTextColor = highlightTextColor;
    [self setNeedsDisplay];
    
}

- (void)setHighlightBg:(UIColor *)highlightBg{
    
    _highlightBg = highlightBg;
    [self setNeedsDisplay];
    
}

#pragma mark - 保存目标字符串的range

/**
 寻找特殊字符串（“@xxx,#xxx#,http(s)://”）
 */
- (void)regularExpressionWithSearchText:(NSString *)searchText{
    
    //清空
    [self.substringRanges removeAllObjects];
    
    for (NSString *pattern in _patterns) {
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
        [regex enumerateMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            [self.substringRanges addObject:[JLSubstringRange rangeWithRange:result.range color:nil customInfo:nil]];
            
            
        }];
        
    }

    
}

#pragma mark - 实现drawRect方法（不实现不会出发layer的display方法）

- (void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
}

#pragma mark - 异步绘制文本代理

-(JLAsyncLayerDisplayTask *)newAsyncDisplayTask{
    
    //字符串不能为空，否则NSMutableAttributedString会报错
    if (!_text) return nil;
    
    JLAsyncLayerDisplayTask *task = [JLAsyncLayerDisplayTask new];
    __weak JLLabel *weakSelf = self;
    task.display = ^(CGContextRef context, CGSize size){
        
        //1.如果根据需要绘制高亮文本
        [weakSelf seekHighlightWithContext:context];
        
        //2.创建属性字符串
        NSDictionary *attributesDict = @{NSFontAttributeName:weakSelf.font,NSForegroundColorAttributeName:weakSelf.textColor};
        NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc] initWithString:weakSelf.text attributes:attributesDict];
        
        //3.拷贝一份，否则一边遍历一遍操作数组线程不安全
        NSArray *substringRanges = [weakSelf.substringRanges copy];
        
        //4.给特殊字符串添加高亮颜色
        for (JLSubstringRange *strRange in substringRanges) {
            
            NSDictionary *atRangeDict = @{NSForegroundColorAttributeName:weakSelf.highlightTextColor,NSFontAttributeName:weakSelf.font};
            [attributeStr setAttributes:atRangeDict range:strRange.range];
            
        }
        
        //5.将字符串画上去
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeStr.length), path, NULL);
        CTFrameDraw(frame, context);
        weakSelf.ctFrame = frame;
        CFRelease(frame);
        CFRelease(path);
        CFRelease(frameSetter);
        
    };
                    
    
    return task;
    
}

#pragma mark - 文本绘制相关工具方法

/**
 根据返回的rect绘制高亮背景
 @param ctx 上下文
 */
- (void)seekHighlightWithContext:(CGContextRef)ctx
{
    if (_selectStrRange)
    {
        if (_selectStrRange.color) {
            [_selectStrRange.color setFill];
        }else{
            [self.highlightBg setFill];
        }
        
        //被点击的范围
        NSRange linkRange = _selectStrRange.range;
        
        //获取每行的原点坐标数组
        CFArrayRef lines = CTFrameGetLines(_ctFrame);
        CFIndex count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
        
        for (CFIndex i = 0; i < count; i++)
        {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CFRange cfLineRange = CTLineGetStringRange(line);
            NSRange lineRange = NSMakeRange(cfLineRange.location, cfLineRange.length);//转换NSRange
            
            //如果两个范围有交集返回最大交集
            NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
            if (intersectedRange.length == 0) {
                continue;//没有交集，跳过，遍历下一个
            }
            
            CGRect highlightRect = [self rectForRange:linkRange line:line lineOrigin:lineOrigins[i]];
            
            //highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
            
            if (!CGRectIsEmpty(highlightRect))
            {
                [self drawHighlightRect:highlightRect ctx:ctx];
                
            }
        }
    }
}


/**
 绘制高亮背景

 @param highlightRect 需要绘制的范围
 @param ctx 图文上下文
 */
- (void)drawHighlightRect:(CGRect)highlightRect ctx:(CGContextRef)ctx{
    
    CGFloat pi = (CGFloat)M_PI;
    
    CGFloat radius = 2;
    
    CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
    CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
    CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius,
                    radius, pi, pi / 2.0f, 1.0f);
    CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius,highlightRect.origin.y + highlightRect.size.height);
    CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                    highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
    CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
    CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius,
                    radius, 0.0f, -pi / 2.0f, 1.0f);
    CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
    CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius,
                    -pi / 2, pi, 1);
    CGContextFillPath(ctx);
    
}

/**
 返回需要高亮状态的rect

 @param range 点击的文本range
 @param line CTLineRef
 @param lineOrigin CTLineRef的原点
 */
- (CGRect)rectForRange:(NSRange)range line:(CTLineRef)line lineOrigin:(CGPoint)lineOrigin
{
    
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    for (CFIndex k = 0; k < runCount; k++)
    {
        
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        CFRange stringRunRange = CTRunGetStringRange(run);
        NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
        
        NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
        
        if (intersectedRunRange.length == 0)
        {
            continue;
        }
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        
        CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,CFRangeMake(0, 0),&ascent,&descent,NULL);
        CGFloat height = ascent + descent;
    
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, intersectedRunRange.location, nil);
        
        CGFloat linkRectX = lineOrigin.x + xOffset;
        CGFloat linkRectY = lineOrigin.y - descent;
        CGFloat linkRectW = (width/lineRunRange.length)*intersectedRunRange.length;
        CGFloat linkRectH = height;
        
        CGRect linkRunRect = CGRectMake(linkRectX, linkRectY, linkRectW, linkRectH);
        
        //roundf四舍五入
        linkRunRect.origin.y = roundf(linkRunRect.origin.y);
        linkRunRect.origin.x = roundf(linkRunRect.origin.x);
        linkRunRect.size.width = roundf(linkRunRect.size.width);
        linkRunRect.size.height = roundf(linkRunRect.size.height);
        
        //CGRectUnion:返回一个可以覆盖两个rect的rect,不断遍历，只要在点击的文本范围内的linkRect都要覆盖，不过一般一个，因为CTRunRef是某行中属性相同的文字集合
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRunRect : CGRectUnion(rectForRange, linkRunRect);
        
    }
    
    return rectForRange;
}


/**
 判断触摸的点是否在高亮文本范围
 */
-(JLSubstringRange *)getSelectRangeWithPoint:(CGPoint)point
{
    CFIndex idx = [self getIndexWithPoint:point];
    for (JLSubstringRange *atRange in _substringRanges)
    {
        //判断是否在已保存的范围里面
        if (NSLocationInRange(idx,atRange.range))
        {
            return atRange;
        }
    }
    return nil;
}


/**
 点击了字符串的哪个位置

 @param point 用户点击的位置
 @return 点击的位置在字符串中的位置，location
 */
- (CFIndex)getIndexWithPoint:(CGPoint)point{
    
    CTFrameRef textFrame = _ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    // 1.获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 2.翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    // 3.遍历每一行，获取point在字符串中的位置
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // 3.1获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        // 3.2转换坐标系
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        // 3.3判断是否在当前line的rect当中
        if (CGRectContainsPoint(rect, point)) {
            
            // 将点击的坐标转换成相对于当前line的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}


/**
 获取每一行的rect

 @param line CTLineRef
 @param point 当前行的坐标原点
 @return 行的rect
 */
- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent+leading;
    
    return CGRectMake(point.x, point.y - descent, width, height);
    
}

#pragma mark - 监听文本点击

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    CGPoint point = [[touches anyObject] locationInView:self];
    _selectStrRange = [self  getSelectRangeWithPoint:point];
    
    if (_selectStrRange) {
        [self setNeedsDisplay];
    }
    
    [super touchesBegan:touches withEvent:event];
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    JLLabelTapCallBack tapCallBack = _tapCallBack;
    if (_selectStrRange && tapCallBack) {
        
        _tapCallBack([_text substringWithRange:_selectStrRange.range],_selectStrRange.range,_selectStrRange.customInfo);
        
    }
    
    [super touchesEnded:touches withEvent:event];
    
    _selectStrRange = nil;
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    //手指移动的时候也要去掉高亮背景
    _selectStrRange = nil;
    [self setNeedsDisplay];
    
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //取消的时候也要去掉高亮背景，否则手指离开了也不恢复普通状态
    [super touchesCancelled:touches withEvent:event];
    _selectStrRange = nil;
    [self setNeedsDisplay];
    
}

- (void)dealloc{
    
    if (_ctFrame!=nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }

}


@end

@implementation JLSubstringRange

+ (instancetype)rangeWithRange:(NSRange)range color:(UIColor *)color customInfo:(NSDictionary *)customInfo{
    
    JLSubstringRange *substringRange = [[self alloc] init];
    substringRange.range =  range;
    substringRange.color = color;
    substringRange.customInfo = customInfo;
    return substringRange;
    
}

@end

//
//  NSString+Calculator.m
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "NSString+Calculator.h"
#import <CoreText/CoreText.h>

@implementation NSString (Calculator)

-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize{
    
    NSDictionary *attributesDict = @{NSFontAttributeName:font};
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:self attributes:attributesDict];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0,0), nil, maxSize, nil);
    CFRelease(frameSetter);
    return textSize;
    
    
}

@end

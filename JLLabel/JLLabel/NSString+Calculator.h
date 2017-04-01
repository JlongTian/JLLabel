//
//  NSString+Calculator.h
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Calculator)

/**
 返回一个属性字符串的大小

 @param font 字体大小
 @param maxSize 计算的最大size
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
@end

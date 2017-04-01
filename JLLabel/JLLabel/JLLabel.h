//
//  JLLabel.h
//  JLLabel
//
//  Created by 张天龙 on 17/3/31.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^JLLabelTapCallBack)(NSString *string,NSRange range,NSDictionary *info);

@interface JLLabel : UIView
/**
 文本
 */
@property (nonatomic,copy) NSString *text;
/**
 字体大小
 */
@property (nonatomic,strong) UIFont *font;
/**
 文本颜色
 */
@property (nonatomic,strong) UIColor *textColor;
/**
 高亮文本颜色
 */
@property (nonatomic,strong) UIColor *highlightTextColor;
/**
 高亮背景颜色
 */
@property(nonatomic,copy) UIColor *highlightBg;
/**
 高亮文本点击回调
 */
@property(nonatomic,copy) JLLabelTapCallBack tapCallBack;

+(instancetype)labelWithText:(NSString *)text font:(UIFont *)font tapCallBack:(JLLabelTapCallBack)tapCallBack;

@end


@interface JLSubstringRange : NSObject

/**
 高亮文本范围
 */
@property(nonatomic) NSRange range;
/**
 高亮文本颜色
 */
@property(nonatomic,strong) UIColor *color;
/**
 高亮文本其它相关信息
 */
@property(nonatomic,strong) NSDictionary *customInfo;

+ (instancetype)rangeWithRange:(NSRange)range color:(UIColor *)color customInfo:(NSDictionary *)customInfo;

@end



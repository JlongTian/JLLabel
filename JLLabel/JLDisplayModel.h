//
//  JLDisplayModel.h
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMargin 5
#define kTextFont [UIFont systemFontOfSize:15.0]

@interface JLDisplayModel : NSObject
/**
 文本
 */
@property (nonatomic,copy) NSString *text;
/**
 文本frame
 */
@property (nonatomic,assign,readonly) CGRect contentF;
/**
 cell高度
 */
@property (nonatomic,assign,readonly) CGFloat cellHeight;

@end

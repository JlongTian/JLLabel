//
//  JLDisplayModel.m
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "JLDisplayModel.h"
#import "NSString+Calculator.h"

@implementation JLDisplayModel

-(void)setText:(NSString *)text{
    
    _text = text;
    
    CGSize contentSize = [text sizeWithFont:kTextFont maxSize:CGSizeMake(kScreenWidth-kMargin*2, MAXFLOAT)];
    _contentF = CGRectMake(kMargin, kMargin, contentSize.width, contentSize.height);
    _cellHeight = contentSize.height+kMargin*2;
    
}

@end

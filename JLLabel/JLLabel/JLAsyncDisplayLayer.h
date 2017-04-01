//
//  JLAsyncDisplayLayer.h
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//  异步绘制文本图层

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class JLAsyncLayerDisplayTask;

typedef void(^DisplayBlock)(CGContextRef context, CGSize size);

@interface  JLAsyncDisplayLayer: CALayer

@end

@protocol JLLayerDelegate <NSObject>
@required

- (JLAsyncLayerDisplayTask *)newAsyncDisplayTask;

@end

@interface JLAsyncLayerDisplayTask : NSObject
/**
 将context回调给label绘制内容
 */
@property (nonatomic, copy) DisplayBlock display;

@end;

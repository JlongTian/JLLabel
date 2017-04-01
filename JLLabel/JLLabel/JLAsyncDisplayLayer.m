//
//  JLAsyncDisplayLayer.m
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "JLAsyncDisplayLayer.h"
#import <CoreText/CoreText.h>

@implementation JLAsyncDisplayLayer

-(void)display{
    
    super.contents = super.contents;
    
    id<JLLayerDelegate> delegate = (id)self.delegate;
    
    JLAsyncLayerDisplayTask *task = nil;
    if ([delegate respondsToSelector:@selector(newAsyncDisplayTask)]){
        task = [delegate newAsyncDisplayTask];
    }
    
    if (!task.display) return;
    
    CGSize size = self.bounds.size;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // 1.创建一个基于位图的上下文(开启一个基于位图的上下文)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        
        //2.旋转坐标系
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);    CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //3.回调context给label绘制
        task.display(context,self.bounds.size);
        
        //4.从上下文中取得制作完毕的UIImage对象
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        //5.结束上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            self.contents = (__bridge id)(image.CGImage);
        
        });
    });
    
}

@end

@implementation JLAsyncLayerDisplayTask
@end

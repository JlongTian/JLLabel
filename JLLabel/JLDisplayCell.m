//
//  JLDisplayCell.m
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "JLDisplayCell.h"
#import "JLLabel.h"

@interface JLDisplayCell ()

@property (nonatomic,weak) JLLabel *contentLabel;

@end

@implementation JLDisplayCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        JLLabel *contentLabel = [[JLLabel alloc] init];
        contentLabel.font = kTextFont;
        contentLabel.tapCallBack = ^(NSString *string,NSRange range,NSDictionary *info){
            
            NSLog(@"%@",string);
            NSLog(@"%@",[NSValue valueWithRange:range]);
            
        };
        [self.contentView addSubview:contentLabel];
        _contentLabel = contentLabel;
        
    }
    
    return self;
    
}

+  (JLDisplayCell *)cellWithTableView:(UITableView *)tableView{
    
    static NSString *cellID = @"JLDisplayCell";
    
    JLDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        
        cell = [[JLDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
    
}

-(void)setModel:(JLDisplayModel *)model{
    
    _model = model;
    
    _contentLabel.text = model.text;
    _contentLabel.frame = model.contentF;
    
}


@end

//
//  JLDisplayCell.h
//  JLLabel
//
//  Created by 张天龙 on 17/4/1.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLDisplayModel.h"

@interface JLDisplayCell : UITableViewCell

@property (nonatomic,strong) JLDisplayModel *model;

+ (JLDisplayCell *)cellWithTableView:(UITableView *)tableView;

@end

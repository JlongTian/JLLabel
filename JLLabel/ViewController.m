//
//  ViewController.m
//  JLLabel
//
//  Created by 张天龙 on 17/3/31.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "ViewController.h"
#import "JLLabel.h"
#import "JLDisplayCell.h"
#import "JLDisplayModel.h"

#define getArrayFromPlist(name) [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(name) ofType:nil]]

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableVIew;

@property (nonatomic,strong) NSMutableArray *datas;

@end

@implementation ViewController

- (NSMutableArray *)datas{
    
    if (_datas==nil) {
        
        _datas = [NSMutableArray array];
        
        NSArray *plistArray = getArrayFromPlist(@"displayText.plist");
        for (NSString *text in plistArray) {
            JLDisplayModel *model = [[JLDisplayModel alloc] init];
            model.text = text;
            [_datas addObject:model];
        }
        
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableVIew = [[UITableView alloc] initWithFrame:CGRectMake(0, kMargin*2, kScreenWidth, kScreenHeight-kMargin*2) style:UITableViewStylePlain];
    _tableVIew.dataSource = self;
    _tableVIew.delegate = self;
    
    [self.view addSubview:self.tableVIew];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    JLDisplayModel *model = self.datas[indexPath.row];
    return model.cellHeight;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JLDisplayCell *cell = [JLDisplayCell cellWithTableView:tableView];
    
    cell.model = self.datas[indexPath.row];
    
    return cell;
    
}


@end

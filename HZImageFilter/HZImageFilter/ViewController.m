//
//  ViewController.m
//  HZImageFilter
//
//  Created by zz go on 2017/4/29.
//  Copyright © 2017年 zzgo. All rights reserved.
//

#import "ViewController.h"


static NSString *DataCellIdentifier      = @"DataCellTableIdentifier";
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, readwrite, strong) UITableView         *tableView;
@property (nonatomic, readwrite, strong) NSArray             *totalArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title=@"HZImageFilter";
    
    NSString *mineListPath = [[NSBundle mainBundle] pathForResource:@"dataList" ofType:@"plist"];
    self.totalArray = [[NSArray alloc] initWithContentsOfFile:mineListPath];
    
    [self.view addSubview:self.tableView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.totalArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:DataCellIdentifier
                                                        forIndexPath:indexPath];

    NSDictionary *dic = self.totalArray[indexPath.row];
    NSString *title=dic[@"title"] ;
//    NSString *imageName=dic[@"imageName"];
    //个人设置
        cell.textLabel.text=title;
    //    cell.imageView.image=[UIImage imageNamed:imageName];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //      if (indexPath.section==0) {
    //        return 100;
    //      }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    NSDictionary *dic = self.totalArray[indexPath.row];
    
    //得到target名，如Target_TabBar。
    NSString *targetClassString = dic[@"vc"];
    //得到方法名，Action_%@: , 如Action_nativeTabBarController
    //    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    Class targetClass = NSClassFromString(targetClassString);
    id target = [[targetClass alloc] init];
    //    SEL action = NSSelectorFromString(actionString);
    if ([target isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:target animated:YES];
    }
}


-(UITableView *)tableView{
    if (!_tableView) {
        //-kNavigationBarHeight
        CGSize size  = [UIScreen mainScreen].bounds.size;
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0, size.width, size.height)
                                                style:UITableViewStyleGrouped];

        [_tableView registerClass:[UITableViewCell class] 
           forCellReuseIdentifier:DataCellIdentifier];
        
//        _tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
        _tableView.delegate=self;
        _tableView.dataSource=self;
        
        //去除footer底下横线
        _tableView.tableFooterView=[UIView new];
    }
    return _tableView;
}
@end

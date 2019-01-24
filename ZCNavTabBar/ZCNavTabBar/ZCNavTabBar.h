//
//  ZCNavTabBar.h
//  AiyoyouCocoapods
//
//  Created by aiyoyou on 2017/8/6.
//  Copyright © 2017年 zoenet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCNavToolBar.h"

@interface ZCNavTabBar : UIView
@property (nonatomic,readonly) ZCNavToolBar         *navToolBar;
@property (nonatomic,assign) BOOL                   scrollEnabled;//default yes
@property (nonatomic,assign) UIViewController       *target;//tabBar附属控制器
@property (nonatomic,assign) NSInteger              currentPage;
@property (nonatomic,assign) BOOL                   isRemoveUnVisible;//是否将屏幕外的controller从父视图移除，default NO

@property (nonatomic,copy) NSMutableArray<UIViewController *>*(^childViews)(void);//一次性加载全部子控制器
@property (nonatomic,copy) UIViewController *(^gl_setCurrentVC)(NSInteger index);//根据索引加载控制器
@property (nonatomic,copy) NSMutableArray<NSString *>*(^childViewsTitle)(void);
@property (nonatomic,copy) void(^itemClickBlock)(NSInteger itemIndex);
@property (nonatomic,copy) void(^shouldRecognizeSimultaneouslyWhenContentOffsetX0Block)(BOOL flag);

- (instancetype)initWithFrame:(CGRect)frame withTarget:(UIViewController *)target;
- (void)reloadData;
@end


/**
 #import "ZCNavTabBarDemoViewController.h"
 #import "ZCNavTabBar.h"
 #import "ZCNavToolBar.h"
 
 @interface ZCNavTabBarDemoViewController ()
 @property (nonatomic,strong) ZCNavToolBar       *navToolBar;
 @property (nonatomic,strong) ZCNavTabBar        *navTabBar;
 @property (nonatomic,strong) UIViewController1  *vc1;
 @property (nonatomic,strong) UIViewController2  *vc2;
 @property (nonatomic,strong) UIViewController3  *vc3;
 @property (nonatomic,strong) UIViewController4  *vc4;
 @end
 
 @implementation ZCNavTabBarDemoViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 [self setupContentView];
 }
 
 - (void)setupContentView {
 //设置内容view
 [self.view addSubview:self.navTabBar];
 //设置title
 self.navigationItem.titleView = self.navToolBar;
 
 //赋值
 __weak typeof(self) weakSelf = self;
 _navTabBar.childViewsTitle = ^NSMutableArray<NSString *> *{
 NSMutableArray *array = [[NSMutableArray alloc]init];
 [array addObject:@"title1"];
 [array addObject:@"title2"];
 [array addObject:@"title3"];
 [array addObject:@"title4"];
 return array;
 };
 
 _navTabBar.gl_setCurrentVC = ^UIViewController *(NSInteger index) {
 UIViewController *vc;
 switch (index) {
 case 0:
 vc = weakSelf.vc1;
 break;
 case 1:
 vc = weakSelf.vc2;
 break;
 case 2:
 vc = weakSelf.vc3;
 break;
 case 3:
 vc = weakSelf.vc4;
 break;
 default:
 break;
 }
 return vc;
 };
 
 _navTabBar.currentPage = 2;
 [_navTabBar reloadData];
 }
 
 - (UIViewController1 *)vc1 {
 if (_vc1) return _vc1;
 _vc1 = [[UIViewController1 alloc]init];
 return _vc1;
 }
 
 - (UIViewController2 *)vc2 {
 if (_vc2) return _vc2;
 _vc2 = [[UIViewController2 alloc]init];
 return _vc2;
 }
 
 - (UIViewController3 *)vc3 {
 if (_vc3) return _vc3;
 _vc3 = [[UIViewController3 alloc]init];
 return _vc3;
 }
 
 - (UIViewController4 *)vc4 {
 if (_vc4) return _vc4;
 _vc4 = [[UIViewController4 alloc]init];
 return _vc4;
 }
 
 - (ZCNavToolBar *)navToolBar {
 if (_navToolBar) return _navToolBar;
 _navToolBar = self.navTabBar.navToolBar;
 _navToolBar.backgroundColor = [UIColor clearColor];
 _navToolBar.seletedTitleFont = [UIFont boldSystemFontOfSize:16];
 _navToolBar.tooBarTitleFont = [UIFont systemFontOfSize:15];
 _navToolBar.margin = 5.0;
 _navToolBar.unSeletedTitleColor = [UIColor whiteColor];
 _navToolBar.bottomSlideLineColor = [UIColor whiteColor];
 _navToolBar.seletedTitleColor = [UIColor whiteColor];
 _navToolBar.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width-100,44);
 return _navToolBar;
 }
 
 - (ZCNavTabBar *)navTabBar {
 if (_navTabBar) return _navTabBar;
 _navTabBar = [[ZCNavTabBar alloc]init];
 _navTabBar.target = self;
 _navTabBar.frame = self.view.bounds;
 _navTabBar.scrollEnabled = YES;
 return _navTabBar;
 }
 
 @end
 
 
 
 
 //----------------------------------------------------------------
 
 @implementation UIViewController1
 - (void)viewDidLoad {
 [super viewDidLoad];
 self.view.backgroundColor = [UIColor redColor];
 }
 @end
 
 @implementation UIViewController2
 - (void)viewDidLoad {
 [super viewDidLoad];
 self.view.backgroundColor = [UIColor blueColor];
 }
 @end
 
 @implementation UIViewController3
 - (void)viewDidLoad {
 [super viewDidLoad];
 self.view.backgroundColor = [UIColor blackColor];
 }
 @end
 
 @implementation UIViewController4
 - (void)viewDidLoad {
 [super viewDidLoad];
 self.view.backgroundColor = [UIColor yellowColor];
 }
 @end
 
 **/

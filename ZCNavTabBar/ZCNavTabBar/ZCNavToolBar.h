//
//  ZCNavToolBar.h
//  AiyoyouCocoapods
//
//  Created by aiyoyou on 2017/8/6.
//  Copyright © 2017年 zoenet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCNavToolBar : UIView
@property (nonatomic,assign) NSInteger          currentItemIndex;
@property (nonatomic,readonly) NSInteger        itemCount;
@property (nonatomic,readonly) UIView           *bottomSlideLine;
@property (nonatomic,readonly) UIView           *bottomLine;
@property (nonatomic,strong) UIFont             *tooBarTitleFont;
@property (nonatomic,strong) UIFont             *seletedTitleFont;
@property (nonatomic,assign) CGFloat            margin;
@property (nonatomic,strong) UIColor            *seletedTitleColor;
@property (nonatomic,strong) UIColor            *unSeletedTitleColor;
@property (nonatomic,strong) UIColor            *bottomSlideLineColor;
@property (nonatomic,strong) UIColor            *bottomLineColor;
@property (nonatomic,strong) UIImage            *maskLeftImg;//左边的蒙版图片宽度50高度等于控件高度
@property (nonatomic,strong) UIImage            *maskRightImg;//右边的蒙版图片宽度50高度等于控件高度
@property (nonatomic,readonly) UIScrollView     *scrollView;

@property (nonatomic,copy) NSMutableArray*(^toolBarTitlesBlock)();//导航数据源
@property (nonatomic,copy) BOOL(^itemShouldResponseClickBlock)(NSInteger itemIndex);//item是否响应点击操作
@property (nonatomic,copy) void(^itemClickBlock)(NSInteger itemIndex);//item点击

/**
 配置item的索引

 @param currentItemIndex 索引值
 @param isScrollPageView 是否滚动内容view（如果是滑动滚动需要设置成NO,否则是YES），外部调用设置为YES
 */
- (void)configItemIndex:(NSInteger)currentItemIndex isScrollPageView:(BOOL)isScrollPageView;


/**
 刷新工具条
 */
- (void)reloadData;


/**
 mask两边颜色渐变（褪色）处理

 @param fadeLength 褪色范围
 */
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength;

@end

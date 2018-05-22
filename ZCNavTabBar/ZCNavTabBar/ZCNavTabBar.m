//
//  ZCNavTabBar.m
//  AiyoyouCocoapods
//
//  Created by aiyoyou on 2017/8/6.
//  Copyright © 2017年 zoenet. All rights reserved.
//

#import "ZCNavTabBar.h"
#import "ZCNavToolBar.h"

#define ViewW self.currentFrame.size.width
#define ViewH self.currentFrame.size.height


@interface ZCScrollView : UIScrollView
@end
@implementation ZCScrollView
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentOffset.x <= 0) {
        if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")]) {
            return YES;
        }
    }
    return NO;
}
@end

@interface ZCNavTabBar ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray         *childViewsTitleArray;
@property (nonatomic,strong) ZCNavToolBar           *navToolBar;
@property (nonatomic,strong) ZCScrollView           *mainScrollView;
@property (nonatomic)        CGRect                 currentFrame;
@property (nonatomic,weak) UIViewController         *currentVC;

@end

@implementation ZCNavTabBar


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _currentFrame = frame;
}

- (instancetype)initWithFrame:(CGRect)frame withTarget:(UIViewController *)target {
    self = [super initWithFrame:frame];
    if (self) {
        _currentFrame = frame;
        _target = target;
    }
    return self;
}

- (void)reloadData {
    __weak typeof(self)weakSelf = self;
    self.navToolBar.toolBarTitlesBlock = ^NSMutableArray *{
        weakSelf.navToolBar.currentItemIndex = weakSelf.currentPage;
        return weakSelf.childViewsTitleArray;
    };
    _navToolBar.itemClickBlock = ^(NSInteger itemIndex) {
        if (weakSelf.itemClickBlock) {
            weakSelf.itemClickBlock(itemIndex);
        }
        weakSelf.currentPage = itemIndex;
        weakSelf.mainScrollView.contentOffset = CGPointMake(itemIndex*(weakSelf.currentFrame.size.width),0);
        [weakSelf loadViewController];
    };
    [self configControl];
    if (_childViews) {
        NSMutableArray *childViews = _childViews();
        for (int i = 0; i<childViews.count; i++) {
            UIViewController *vc = childViews[i];
            vc.view.frame = CGRectMake(i*ViewW,0,ViewW,ViewH);
            [_mainScrollView addSubview:vc.view];
            if (_target) {
                [_target addChildViewController:vc];
                [vc didMoveToParentViewController:_target];
            }
        }
    }
}

- (void)configControl {
    if (CGRectIsEmpty(_currentFrame)) return;
    [self addSubview:self.mainScrollView];
    for (UIView *view in self.mainScrollView.subviews) {
        [view removeFromSuperview];
    }
    self.mainScrollView.frame = self.bounds;
    if (_childViewsTitle) {
        _childViewsTitleArray = _childViewsTitle();
        if (_childViewsTitleArray && _childViewsTitleArray.count>0) {
            _mainScrollView.contentSize = CGSizeMake(_childViewsTitleArray.count*ViewW,ViewH);
        }
        [self.navToolBar reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static BOOL flag = YES;
    if (scrollView.contentOffset.x>=0) flag = YES;
    if (scrollView.contentOffset.x<0 && _shouldRecognizeSimultaneouslyWhenContentOffsetX0Block&&flag) {
        flag = NO;
        _shouldRecognizeSimultaneouslyWhenContentOffsetX0Block(YES);
        return;
    }
    NSInteger page = floor((scrollView.contentOffset.x - ViewW / 2) / ViewW)+1;
    if (_currentPage != page) {
        _currentPage = page;
        [self.navToolBar configItemIndex:page isScrollPageView:NO];
        [self loadViewController];
    }
}

#pragma mark - 加载视图控制器
- (void)loadViewController {
    if (_gl_setCurrentVC) {
        if (_currentPage>_childViewsTitleArray.count-1) {
            _currentPage = _childViewsTitleArray.count-1;
        }else if (_currentPage<0) {
            _currentPage = 0;
        }
        UIViewController *vc = _gl_setCurrentVC(_currentPage);
        vc.view.frame = CGRectMake(_currentPage*ViewW,0,ViewW,ViewH);
        if (_isRemoveUnVisible) {
            if (_target) {
                if (!_currentVC) {
                    //首次加载第一个默认控制器
                    [_target addChildViewController:vc];
                    [vc didMoveToParentViewController:_target];
                    _currentVC = vc;
                    [_mainScrollView addSubview:vc.view];
                }
                [self changeControllerFromOldController:self.currentVC toNewController:vc];
            }
        }else {
            [_mainScrollView addSubview:vc.view];
            if (_target) {
                [_target addChildViewController:vc];
                [vc didMoveToParentViewController:_target];
                if (_currentVC) {
                    [_currentVC willMoveToParentViewController:nil];
                    [_currentVC removeFromParentViewController];
                }
                _currentVC = vc;
            }
        }
    }
}


#pragma mark - 控制器切换
- (void)changeControllerFromOldController:(UIViewController *)oldController toNewController:(UIViewController *)newController {
    if (oldController == newController) return;
    [self.target addChildViewController:newController];
    /**
     *  切换ViewController
     */
    __weak typeof(self)weakSelf = self;
    [self.target transitionFromViewController:oldController toViewController:newController duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //做一些动画
        
    } completion:^(BOOL finished) {
        if (finished) {
            //移除oldController，但在removeFromParentViewController：方法前不会调用willMoveToParentViewController:nil 方法，所以需要显示调用
            [newController didMoveToParentViewController:self.target];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            weakSelf.currentVC = newController;
        }else {
            weakSelf.currentVC = oldController;
        }
    }];
}


#pragma mark - Properties

- (ZCScrollView *)mainScrollView {
    if (_mainScrollView) return _mainScrollView;
    _mainScrollView = [[ZCScrollView alloc] init];
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.bounces = NO;
    _mainScrollView.scrollEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    return _mainScrollView;
}

- (ZCNavToolBar *)navToolBar {
    if (_navToolBar) return _navToolBar;
    _navToolBar = [[ZCNavToolBar alloc]init];
    return _navToolBar;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.mainScrollView.scrollEnabled = _scrollEnabled;
}

- (void)setShouldRecognizeSimultaneouslyWhenContentOffsetX0Block:(void (^)(BOOL))shouldRecognizeSimultaneouslyWhenContentOffsetX0Block {
    _shouldRecognizeSimultaneouslyWhenContentOffsetX0Block = shouldRecognizeSimultaneouslyWhenContentOffsetX0Block;
    self.mainScrollView.bounces = YES;
}

@end

//
//  ZCNavToolBar.m
//  AiyoyouCocoapods
//
//  Created by aiyoyou on 2017/8/6.
//  Copyright © 2017年 zoenet. All rights reserved.
//

#import "ZCNavToolBar.h"

#define toolViewW _currentFrame.size.width
#define toolViewH _currentFrame.size.height

@interface ZCNavToolBar() {
    UIButton            *_seletedItem;
    CGRect              _currentFrame;
}
@property (nonatomic,strong) UIView                 *bottomSlideLine;
@property (nonatomic,strong) UIView                 *bottomLine;
@property (nonatomic,strong) UIScrollView           *scrollView;
@property (nonatomic,strong) NSMutableArray         *itemArray;
@property (nonatomic,assign) NSInteger              itemCount;
@property (nonatomic,strong) UIImageView            *maskLeftImgV;
@property (nonatomic,strong) UIImageView            *maskRightImgV;
@end

@implementation ZCNavToolBar
@synthesize bottomLineColor = _bottomLineColor;
@synthesize bottomSlideLineColor = _bottomSlideLineColor;
@synthesize seletedTitleColor = _seletedTitleColor;
@synthesize unSeletedTitleColor = _unSeletedTitleColor;

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _currentFrame = frame;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentFrame = frame;
    }
    return self;
}

- (void)reloadData {
    [self configControl];
}

#pragma mark - 控件渲染
- (void)configControl {
    if (CGRectIsEmpty(_currentFrame)) return;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self.itemArray removeAllObjects];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.bottomSlideLine];
    [self addSubview:self.bottomLine];
    
    _scrollView.frame = CGRectMake(0, 0, toolViewW, toolViewH);
    _bottomLine.frame = CGRectMake(0, toolViewH-0.5, toolViewW,0.5);
    _bottomLine.backgroundColor = self.bottomLineColor;
    _bottomSlideLine.backgroundColor = self.bottomSlideLineColor;
    
    if (_toolBarTitlesBlock) {
        NSMutableArray *titleArray = _toolBarTitlesBlock();
        if (!(titleArray && titleArray.count>0)) return;
        self.itemCount = titleArray.count;
        CGFloat itemAmountW = 0.0;
        CGFloat extraMargin = 0.0;
        for (NSString *title in titleArray) {
            CGFloat itemW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT,toolViewH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tooBarTitleFont} context:nil].size.width+8;
            itemAmountW += itemW;
        }
        if (itemAmountW<(toolViewW-(_itemCount+1)*self.margin)) {
            extraMargin = ((toolViewW-(_itemCount+1)*self.margin)-itemAmountW)/(CGFloat)_itemCount;
        }
        
        CGFloat x = 0.0;
        CGFloat preW = 0.0;//前一个按钮的宽度
        for (int i = 0; i<titleArray.count; i++) {
            NSString *title = titleArray[i];
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            item.backgroundColor = [UIColor clearColor];
            [item setTitle:title forState:UIControlStateNormal];
            [item setTitleColor:self.unSeletedTitleColor forState:UIControlStateNormal];
            [item setTitleColor:self.seletedTitleColor forState:UIControlStateSelected];
            [item setTitleColor:self.seletedTitleColor forState:UIControlStateSelected|UIControlStateHighlighted];
            [item.titleLabel setFont:self.tooBarTitleFont];
            item.tag = i;
            [item addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
            
            x = x+self.margin+preW;
            CGFloat itemW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT,toolViewH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tooBarTitleFont} context:nil].size.width+8;
            itemW += extraMargin;
            preW = itemW;
            
            item.frame = CGRectMake(x,0,itemW,toolViewH);
            if (self.currentItemIndex == i) {
                [self itemClickAction:item];
            }
            [self.itemArray addObject:item];
            [self.scrollView addSubview:item];
        }
        
        if (self.itemArray.count) {
            UIButton *lastItem = self.itemArray[_itemArray.count-1];
            CGFloat contentX = CGRectGetMaxX(lastItem.frame)+self.margin;
            if (_maskRightImg) contentX+=20;
            self.scrollView.contentSize = CGSizeMake(contentX,toolViewH);
        }
        
        if (_maskRightImg) {
            self.maskRightImgV.frame = CGRectMake(self.frame.size.width-50,0,50,self.frame.size.height);
            [self addSubview:_maskLeftImgV];
        }
        if (_maskLeftImgV) {
            self.maskLeftImgV.frame = CGRectMake(-15,0,40,self.frame.size.height);
            [self addSubview:_maskRightImgV];
        }
    }
}

#pragma mark - 按钮点击
- (void)itemClickAction:(UIButton *)item {
    if (_seletedItem == item) return;
    if (_itemShouldResponseClickBlock) {
        if(!_itemShouldResponseClickBlock(item.tag)) return;
    }
    
    CGFloat originalW = item.frame.size.width;
    NSString *title = [item currentTitle];
    CGFloat nowW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT,toolViewH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tooBarTitleFont} context:nil].size.width+8;
    if ((nowW+20)<=originalW) {
        nowW = nowW+20;
    }
    
    if (CGRectIsEmpty(self.bottomSlideLine.frame)) {
        self.bottomSlideLine.frame = CGRectMake(item.center.x-nowW/2.0,toolViewH-2,nowW,2);
        [item.titleLabel setFont:self.seletedTitleFont];
        [self scrollViewOffsetConfig];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomSlideLine.frame = CGRectMake(item.center.x-nowW/2.0,toolViewH-2,nowW,2);
            [item.titleLabel setFont:self.seletedTitleFont];
            [_seletedItem.titleLabel setFont:self.tooBarTitleFont];
        }completion:^(BOOL finished) {
            [self scrollViewOffsetConfig];
        }];
    }
    _seletedItem.selected = NO;
    item.selected = YES;
    _seletedItem = item;
    _currentItemIndex = item.tag;
    if (_itemClickBlock) {
        _itemClickBlock(item.tag);
    }
}

#pragma mark - 修改选中按钮的按钮
- (void)configItemIndex:(NSInteger)currentItemIndex isScrollPageView:(BOOL)isScrollPageView {
    if (currentItemIndex>self.itemArray.count-1) return;
    UIButton *item = self.itemArray[currentItemIndex];
    if (_seletedItem == item) return;
    
    CGFloat originalW = item.frame.size.width;
    NSString *title = [item currentTitle];
    CGFloat nowW = [title boundingRectWithSize:CGSizeMake(MAXFLOAT,toolViewH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tooBarTitleFont} context:nil].size.width+8;
    if ((nowW+20)<=originalW) {
        nowW = nowW+20;
    }
    
    if (CGRectIsEmpty(self.bottomSlideLine.frame)) {
        self.bottomSlideLine.frame = CGRectMake(item.center.x-nowW/2.0,toolViewH-2,nowW,2);
        [item.titleLabel setFont:self.seletedTitleFont];
        [self scrollViewOffsetConfig];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomSlideLine.frame = CGRectMake(item.center.x-nowW/2.0,toolViewH-2,nowW,2);
            [item.titleLabel setFont:self.seletedTitleFont];
            [_seletedItem.titleLabel setFont:self.tooBarTitleFont];
        }completion:^(BOOL finished) {
            [self scrollViewOffsetConfig];
        }];
    }
    _seletedItem.selected = NO;
    item.selected = YES;
    _seletedItem = item;
    _currentItemIndex = item.tag;
    if (_itemClickBlock && isScrollPageView) {
        _itemClickBlock(item.tag);
    }
}


- (void)scrollViewOffsetConfig {
    CGRect rc = [self.scrollView convertRect:self.bottomSlideLine.frame toView:self];
    CGFloat sub = 0;
    if (_maskRightImg) sub=30;
    if ((self.frame.size.width - (rc.origin.x+rc.size.width))<sub) {
        NSInteger maxOffsetX = self.scrollView.contentSize.width-self.frame.size.width;
        CGFloat x = ((self.scrollView.contentOffset.x +120)>maxOffsetX)?maxOffsetX:(self.scrollView.contentOffset.x +120);
        [self.scrollView setContentOffset:CGPointMake(x,0) animated:YES];
    }else if (rc.origin.x<0) {
        CGFloat x = (self.scrollView.contentOffset.x -120)<0?0:(self.scrollView.contentOffset.x -120);
        [self.scrollView setContentOffset:CGPointMake(x,0) animated:YES];
    }
}

- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength {
    
    // Remove any in-flight animations
    [self.layer.mask removeAllAnimations];
    
    // Configure gradient mask without implicit animations
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CAGradientLayer *gradientMask = (CAGradientLayer *)self.layer.mask;
    
    // Set up colors
    NSObject *transparent = (NSObject *)[[UIColor clearColor] CGColor];
    NSObject *opaque = (NSObject *)[[UIColor blackColor] CGColor];
    
    if (!gradientMask) {
        // Create CAGradientLayer if needed
        gradientMask = [CAGradientLayer layer];
        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
        gradientMask.startPoint = CGPointMake(0.0f, 0.5f);
        gradientMask.endPoint = CGPointMake(1.0f, 0.5f);
    }
    
    // Check if there is a mask-to-bounds size mismatch
    if (!CGRectEqualToRect(gradientMask.bounds, self.bounds)) {
        // Adjust stops based on fade length
        CGFloat leftFadeStop = fadeLength/self.bounds.size.width;
        CGFloat rightFadeStop = fadeLength/self.bounds.size.width;
        gradientMask.locations = @[@(0.0f), @(leftFadeStop), @(1.0f - rightFadeStop), @(1.0f)];
    }
    
    gradientMask.bounds = self.layer.bounds;
    gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // Set mask
    self.layer.mask = gradientMask;
    
    // Determine colors for non-scrolling label (i.e. at home)
    NSArray *adjustedColors;
    adjustedColors = @[(transparent),
                       opaque,
                       opaque,
                       opaque];
    gradientMask.colors = adjustedColors;
    [CATransaction commit];
}


#pragma mark - Properties

- (UIView *)bottomLine {
    if (_bottomLine) return _bottomLine;
    _bottomLine = [[UIView alloc]init];
    return _bottomLine;
}

- (UIView *)bottomSlideLine {
    if (_bottomSlideLine) return _bottomSlideLine;
    _bottomSlideLine = [[UIView alloc]init];
    _bottomSlideLine.layer.cornerRadius = 1;
    return _bottomSlideLine;
}

- (UIScrollView *)scrollView {
    if (_scrollView) return _scrollView;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.bounces = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    return _scrollView;
}

- (NSMutableArray *)itemArray {
    if (_itemArray) return _itemArray;
    _itemArray = [[NSMutableArray alloc]init];
    return _itemArray;
}

- (UIColor *)bottomLineColor {
    if (_bottomLineColor) return _bottomLineColor;
        _bottomLineColor = [UIColor clearColor];
    return _bottomLineColor;
}
- (void)setBottomLineColor:(UIColor *)bottomLineColor {
    _bottomLineColor = bottomLineColor;
    self.bottomLine.backgroundColor = bottomLineColor;
}

- (UIColor *)bottomSlideLineColor {
    if (_bottomSlideLineColor) return _bottomSlideLineColor;
    _bottomSlideLineColor = [UIColor colorWithRed:0 green:162/255.0 blue:1 alpha:1];
    return _bottomSlideLineColor;
}
- (void)setBottomSlideLineColor:(UIColor *)bottomSlideLineColor {
    _bottomSlideLineColor = bottomSlideLineColor;
    self.bottomSlideLine.backgroundColor = bottomSlideLineColor;
}

- (void)setSeletedTitleColor:(UIColor *)seletedTitleColor {
    _seletedTitleColor = seletedTitleColor;
    for (UIButton *item in self.itemArray) {
        [item setTitleColor:_seletedTitleColor forState:UIControlStateSelected];
    }
}

- (void)setUnSeletedTitleColor:(UIColor *)unSeletedTitleColor {
    _unSeletedTitleColor = unSeletedTitleColor;
    for (UIButton *item in self.itemArray) {
        [item setTitleColor:_unSeletedTitleColor forState:UIControlStateNormal];
    }
}

- (UIFont *)tooBarTitleFont {
    if (_tooBarTitleFont) return _tooBarTitleFont;
    _tooBarTitleFont = [UIFont systemFontOfSize:16];
    return _tooBarTitleFont;
}

- (UIFont *)seletedTitleFont {
    if (_seletedTitleFont) return _seletedTitleFont;
    _seletedTitleFont = self.tooBarTitleFont;
    return _seletedTitleFont;
}

- (CGFloat)margin {
    if (_margin) return _margin;
    _margin = 15.0;
    return _margin;
}

- (UIColor *)seletedTitleColor {
    if (_seletedTitleColor) return _seletedTitleColor;
    _seletedTitleColor = [UIColor colorWithRed:0 green:162/255.0 blue:1 alpha:1];
    return _seletedTitleColor;
}

- (UIColor *)unSeletedTitleColor {
    if (_unSeletedTitleColor) return _unSeletedTitleColor;
    _unSeletedTitleColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    return _unSeletedTitleColor;
}

- (UIImageView *)maskLeftImgV {
    if (_maskLeftImgV) return _maskLeftImgV;
    _maskLeftImgV = [[UIImageView alloc] init];
    _maskLeftImgV.backgroundColor = [UIColor clearColor];
    return _maskLeftImgV;
}

- (UIImageView *)maskRightImgV {
    if (_maskRightImgV) return _maskRightImgV;
    _maskRightImgV = [[UIImageView alloc] init];
    _maskRightImgV.backgroundColor = [UIColor clearColor];
    return _maskRightImgV;
}


- (void)setMaskLeftImg:(UIImage *)maskLeftImg {
    _maskLeftImg = maskLeftImg;
    self.maskLeftImgV.image = _maskLeftImg;
}

- (void)setMaskRightImg:(UIImage *)maskRightImg {
    _maskRightImg = maskRightImg;
    self.maskRightImgV.image = _maskRightImg;
}

@end

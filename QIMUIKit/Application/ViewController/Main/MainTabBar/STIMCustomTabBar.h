//
//  STIMCustomTabBar.h
//  FlyShow
//
//  Created by XXXX on 14-9-23.
//  Copyright (c) 2014年 Personal. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@class STIMCustomTabBar;

@protocol STIMCustomTabBarDelegate <NSObject>
@optional
- (void)customTabBar:(STIMCustomTabBar *)tabBar longPressAtIndex:(NSUInteger)index;
- (void)customTabBar:(STIMCustomTabBar *)tabBar didSelectIndex:(NSUInteger)index;
- (void)customTabBar:(STIMCustomTabBar *)tabBar doubleClickIndex:(NSUInteger)index;
@end

@interface STIMCustomTabBar : UIView

- (id)initWithItemCount:(NSUInteger)count WithFrame:(CGRect)frame;

@property (nonatomic,assign) id<STIMCustomTabBarDelegate> delegate;
@property (nonatomic,readonly,assign) NSUInteger itemCount;
@property (nonatomic,assign) NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setBadgeNumber:(NSUInteger)bagdeNumber ByItemIndex:(NSUInteger)index;
- (void)setBadgeNumber:(NSUInteger)bagdeNumber ByItemIndex:(NSUInteger)index showNumber:(BOOL)showNum;
- (void)setAccessibilityIdentifier:(NSString *)accessibilityIdentifier ByItemIndex:(NSUInteger)index;
- (void)setTitle:(NSString *)title ByItemIndex:(NSUInteger)index;
- (void)setNormalTitleColor:(UIColor *)titleColor ByItemIndex:(NSUInteger)index;
- (void)setSelectedTitleColor:(UIColor *)titleColor ByItemIndex:(NSUInteger)index;
- (void)setNormalImage:(UIImage *)image ByItemIndex:(NSUInteger)index;
- (void)setSelectedImage:(UIImage *)image ByItemIndex:(NSUInteger)index;
- (void)setNormalBgImage:(UIImage *)image ByItemIndex:(NSUInteger)index;
- (void)setSelectedBgImage:(UIImage *)image ByItemIndex:(NSUInteger)index;

@end

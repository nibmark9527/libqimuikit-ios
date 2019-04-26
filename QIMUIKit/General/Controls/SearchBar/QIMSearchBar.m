//
//  QIMSearchBar.m
//  QIMUIKit
//
//  Created by lilu on 2019/4/25.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMSearchBar.h"
#import "Masonry.h"
#import "QIMUIFontConfig.h"
#import "QIMUIColorConfig.h"
#import "QIMIconInfo.h"
#import "UIImage+QIMIconFont.h"

@interface QIMSearchBar ()

@property (nonatomic, strong) UIView *searchBgView;

@end

@implementation QIMSearchBar

- (UIView *)searchBgView {
    if (!_searchBgView) {
        _searchBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchBgView.backgroundColor = qim_listSearchBgViewColor;
    }
    return _searchBgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.searchBgView];
        self.searchBgView.layer.cornerRadius = 4.0f;
        [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
            make.top.mas_offset(13);
            make.bottom.mas_offset(-13);
        }];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e752" size:28 color:[UIColor qim_colorWithHex:0xBFBFBF]]];
//        iconView.backgroundColor = [UIColor redColor];
        [self.searchBgView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.width.mas_equalTo(13);
            make.top.mas_offset(13);
            make.bottom.mas_offset(-13);
        }];
        
        UILabel *promotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        promotLabel.text = @"搜索";
        promotLabel.textColor = [UIColor qim_colorWithHex:0xB5B5B5];
        promotLabel.font = [UIFont systemFontOfSize:16];
        [self.searchBgView addSubview:promotLabel];
        [promotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(iconView.mas_right).mas_offset(8);
            make.top.mas_offset(12);
            make.bottom.mas_offset(-12);
            make.width.mas_equalTo(100);
        }];
        
    }
    return self;
}

@end

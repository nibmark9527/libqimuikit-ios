//
//  STIMGroupNameCell.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/16.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMCommonUIFramework.h"

@interface STIMGroupNameCell : UITableViewCell

@property (nonatomic, strong) NSString *name;

+ (CGFloat)getCellHeight;

- (void)refreshUI;

@end

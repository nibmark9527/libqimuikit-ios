//
//  STIMExtensibleProductCell.h
//  qunarChatIphone
//
//  Created by chenjie on 16/7/13.
//
//

#import "STIMCommonUIFramework.h"

@class STIMMsgBaloonBaseCell;
@interface STIMExtensibleProductCell : STIMMsgBaloonBaseCell

@property (nonatomic, strong) UIViewController *owner;

+ (float)getCellHeightForProductInfo:(NSString *)infoStr;

- (void)setProDcutInfoDic:(NSDictionary *)infoDic;

- (void)refreshUI;

@end

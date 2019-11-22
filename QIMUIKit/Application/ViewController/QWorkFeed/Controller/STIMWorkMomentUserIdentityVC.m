//
//  STIMWorkMomentUserIdentityVC.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/4.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkMomentUserIdentityVC.h"
#import "STIMWorkMomentUserIdentityModel.h"
#import "STIMWorkMomentUserIdentityCell.h"

@interface STIMWorkMomentUserIdentityVC () <UITableViewDelegate, UITableViewDataSource, STIMWorkMomentUserIdentityReplaceDelegate>

@property (nonatomic, strong) UITableView *userIdentityListView;

@property (nonatomic, strong) NSMutableArray *userIdentityList;

@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) STIMWorkMomentUserIdentityModel *lastUserModel;

@end

@implementation STIMWorkMomentUserIdentityVC

- (UITableView *)userIdentityListView {
    if (!_userIdentityListView) {
        _userIdentityListView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _userIdentityListView.backgroundColor = [UIColor stimDB_colorWithHex:0xf8f8f8];
        _userIdentityListView.delegate = self;
        _userIdentityListView.dataSource = self;
        _userIdentityListView.estimatedRowHeight = 0;
        _userIdentityListView.estimatedSectionHeaderHeight = 0;
        _userIdentityListView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _userIdentityListView.tableFooterView = [UIView new];
        _userIdentityListView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _userIdentityListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _userIdentityListView;
}

- (NSMutableArray *)userIdentityList {
    if (!_userIdentityList) {
        _userIdentityList = [NSMutableArray arrayWithCapacity:2];
        STIMWorkMomentUserIdentityModel *model = [[STIMWorkMomentUserIdentityModel alloc] init];
        model.isAnonymous = NO;
        
        STIMWorkMomentUserIdentityModel *model1 = [[STIMWorkMomentUserIdentityModel alloc] init];
        model1.isAnonymous = YES;
        model1.mockAnonymous = YES;
        
        [_userIdentityList addObject:model];
        [_userIdentityList addObject:model1];
    }
    return _userIdentityList;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setFrame:CGRectMake(0, 0, 36, 18)];
        [_saveBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] forState:UIControlStateNormal];
        [_saveBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] forState:UIControlStateDisabled];
        [_saveBtn setTitleColor:[UIColor stimDB_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_saveBtn setTitleColor:[UIColor stimDB_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(didselectUserIdentity:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (STIMWorkMomentUserIdentityModel *)lastUserModel {
    if (!_lastUserModel) {
        _lastUserModel = [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] userIdentityModel];
    }
    return _lastUserModel;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发帖身份";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor stimDB_colorWithHex:0x333333]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor stimDB_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];
    UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
    [[self navigationItem] setRightBarButtonItem:newMomentBtn];

    self.view.backgroundColor = [UIColor stimDB_colorWithHex:0xF3F3F5];
    [self.view addSubview:self.userIdentityListView];
    __weak __typeof(self) weakSelf = self;
    
    BOOL isAnonymous = self.lastUserModel.isAnonymous;
    
//    if ([[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == YES) {
    if (isAnonymous == YES) {
        NSString *anonymousName = self.lastUserModel.anonymousName;
        NSString *anonymousPhoto = self.lastUserModel.anonymousPhoto;
        NSInteger anonymousId = self.lastUserModel.anonymousId;
        BOOL anonymousReplaceable = self.lastUserModel.replaceable;
        /* Mark by 匿名
        NSString *anonymousName = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
        NSString *anonymousPhoto = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        NSInteger anonymousId = [[STIMWorkMomentUserIdentityManager sharedInstance] anonymousId];
        BOOL anonymousReplaceable = [[STIMWorkMomentUserIdentityManager sharedInstance] replaceable];
        */
        STIMWorkMomentUserIdentityModel *model = [[STIMWorkMomentUserIdentityModel alloc] init];
        model.isAnonymous = YES;
        model.anonymousId = anonymousId;
        model.anonymousName = anonymousName;
        model.anonymousPhoto = anonymousPhoto;
        model.replaceable = anonymousReplaceable;
        [weakSelf.userIdentityList replaceObjectAtIndex:1 withObject:model];

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.userIdentityListView reloadData];
        });
    } else {
        [[STIMKit sharedInstance] getAnonyMouseDicWithMomentId:self.momentId WithCallBack:^(NSDictionary *anonymousDic) {
            if (anonymousDic.count > 0) {
                NSString *anonymousName = [anonymousDic objectForKey:@"anonymous"];
                NSString *anonymousPhoto = [anonymousDic objectForKey:@"anonymousPhoto"];
                NSInteger anonymousId = [[anonymousDic objectForKey:@"id"] integerValue];
                BOOL replaceable = [[anonymousDic objectForKey:@"replaceable"] boolValue];
                STIMWorkMomentUserIdentityModel *model = [[STIMWorkMomentUserIdentityModel alloc] init];
                model.isAnonymous = YES;
                model.anonymousId = anonymousId;
                model.anonymousName = anonymousName;
                model.anonymousPhoto = anonymousPhoto;
                model.replaceable = replaceable;
                [weakSelf.userIdentityList replaceObjectAtIndex:1 withObject:model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.userIdentityListView reloadData];
                });
            }
        }];
    }
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[STIMKit sharedInstance] getAnonyMouseDicWithMomentId:self.momentId WithCallBack:^(NSDictionary *anonymousDic) {
            if (anonymousDic.count > 0) {
                NSString *anonymousName = [anonymousDic objectForKey:@"anonymous"];
                NSString *anonymousPhoto = [anonymousDic objectForKey:@"anonymousPhoto"];
                NSInteger anonymousId = [[anonymousDic objectForKey:@"id"] integerValue];
                BOOL replaceable = [[anonymousDic objectForKey:@"replaceable"] boolValue];
                STIMWorkMomentUserIdentityModel *model = [[STIMWorkMomentUserIdentityModel alloc] init];
                model.isAnonymous = YES;
                model.anonymousId = anonymousId;
                model.anonymousName = anonymousName;
                model.anonymousPhoto = anonymousPhoto;
                model.replaceable = replaceable;
                [weakSelf.userIdentityList replaceObjectAtIndex:1 withObject:model];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.userIdentityListView reloadData];
                });
            }
        }];
    });
    */
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userIdentityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [NSString stringWithFormat:@"cellId-%d", indexPath.row];
    NSLog(@"cellId : %@", cellId);
    STIMWorkMomentUserIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[STIMWorkMomentUserIdentityCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.delegate = self;
    }
    STIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    
    BOOL isAnonymous = self.lastUserModel.isAnonymous;
    
    if (userIdentityModel.isAnonymous == NO) {
        cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"moment_real"];
        [cell setUserIdentitySelected:!isAnonymous];
        /* Mark by 匿名
        if ([[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]) {
            [cell setUserIdentitySelected:NO];
        } else {
            [cell setUserIdentitySelected:YES];
        }
        */
    } else {
        if (userIdentityModel.mockAnonymous == YES) {
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"moment_anonymous"];
            cell.detailTextLabel.text = [NSString stringWithFormat:[NSBundle stimDB_localizedStringForKey:@"moment_Loading_Nicknames"]];
            cell.detailTextLabel.textColor = [UIColor stimDB_colorWithHex:0x999999];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            [cell setUserIdentitySelected:NO];
        } else {
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"moment_anonymous"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@：%@", [NSBundle stimDB_localizedStringForKey:@"moment_nickname"], userIdentityModel.anonymousName];
            cell.detailTextLabel.textColor = [UIColor stimDB_colorWithHex:0x999999];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            [cell setUserIdentitySelected:isAnonymous];
            [cell setUserIdentityReplaceable:userIdentityModel.replaceable];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    if (userIdentityModel.isAnonymous == NO) {
        return 48.0f;
    } else {
        return 70.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    STIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    if (userIdentityModel.mockAnonymous == YES) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"common_prompt"] message:[NSBundle stimDB_localizedStringForKey:@"moment_Loading_Nicknames"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [self presentViewController:alertVc animated:YES completion:nil];
    } else {
        [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] setUserIdentityModel:userIdentityModel];
        /* Mark by 匿名
        if (userIdentityModel.isAnonymous == NO) {
            [[STIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousId:userIdentityModel.anonymousId];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setReplaceable:NO];
        } else {
            [[STIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:YES];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousId:userIdentityModel.anonymousId];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:userIdentityModel.anonymousName];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:userIdentityModel.anonymousPhoto];
            [[STIMWorkMomentUserIdentityManager sharedInstance] setReplaceable:userIdentityModel.replaceable];
        } */
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadUserIdentifier" object:nil];
        });
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)replaceWorkMomentUserIdentity {
    __weak __typeof(self) weakSelf = self;
    [[STIMKit sharedInstance] getAnonyMouseDicWithMomentId:self.momentId WithCallBack:^(NSDictionary *anonymousDic) {
        NSLog(@"anonymousDic : %@", anonymousDic);
        [weakSelf.userIdentityList removeLastObject];
        if (anonymousDic.count > 0) {
            NSString *anonymousName = [anonymousDic objectForKey:@"anonymous"];
            NSString *anonymousPhoto = [anonymousDic objectForKey:@"anonymousPhoto"];
            NSInteger anonymousId = [[anonymousDic objectForKey:@"id"] integerValue];
            BOOL replaceable = [[anonymousDic objectForKey:@"replaceable"] boolValue];
            STIMWorkMomentUserIdentityModel *model = [[STIMWorkMomentUserIdentityModel alloc] init];
            model.isAnonymous = YES;
            model.anonymousId = anonymousId;
            model.anonymousName = anonymousName;
            model.anonymousPhoto = anonymousPhoto;
            model.replaceable = replaceable;
            [weakSelf.userIdentityList addObject:model];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.userIdentityListView reloadData];
            });
        }
    }];
}

- (void)didselectUserIdentity:(id)sender {
    
    BOOL isAnonymous = self.lastUserModel.isAnonymous;
    if (isAnonymous == YES) {
        STIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList lastObject];
        [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] setUserIdentityModel:userIdentityModel];
    } else {
        [[STIMWorkMomentUserIdentityManager sharedInstanceWithPOSTUUID:self.momentId] setUserIdentityModel:nil];
    }
    /* Mark by 匿名
    if ([[STIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == YES) {
        STIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList lastObject];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:YES];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousId:userIdentityModel.anonymousId];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:userIdentityModel.anonymousName];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:userIdentityModel.anonymousPhoto];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setReplaceable:userIdentityModel.replaceable];
    } else {
        [[STIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
        [[STIMWorkMomentUserIdentityManager sharedInstance] setReplaceable:NO];
    }
    */
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadUserIdentifier" object:nil];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

@end

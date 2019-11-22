//
//  STIMAssetCell.h
//  STIMImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    STIMAssetCellTypePhoto = 0,
    STIMAssetCellTypeLivePhoto,
    STIMAssetCellTypePhotoGif,
    STIMAssetCellTypeVideo,
    STIMAssetCellTypeAudio,
} STIMAssetCellType;

@class STIMAssetModel;
@interface STIMAssetCell : UICollectionViewCell
@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (weak, nonatomic) UIButton *cannotSelectLayerButton;
@property (nonatomic, strong) STIMAssetModel *model;
@property (assign, nonatomic) NSInteger index;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) STIMAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, strong) UIImage *photoSelImage;
@property (nonatomic, strong) UIImage *photoDefImage;

@property (nonatomic, assign) BOOL showSelectBtn;
@property (assign, nonatomic) BOOL allowPreview;

@property (nonatomic, copy) void (^assetCellDidSetModelBlock)(STIMAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);
@property (nonatomic, copy) void (^assetCellDidLayoutSubviewsBlock)(STIMAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView);
@end


@class QIMAlbumModel;
@interface QIMAlbumCell : UITableViewCell
@property (nonatomic, strong) QIMAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;

@property (nonatomic, copy) void (^albumCellDidSetModelBlock)(QIMAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);
@property (nonatomic, copy) void (^albumCellDidLayoutSubviewsBlock)(QIMAlbumCell *cell, UIImageView *posterImageView, UILabel *titleLabel);
@end


@interface QIMAssetCameraCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end

//
//  LFStickerBar.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/21.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFStickerBar.h"
#import "LFMediaEditingHeader.h"
#import "UIView+LFMEFrame.h"
#import "JRStickerDisplayView.h"
#import <Photos/Photos.h>
#import "LFImageCoder.h"

extern LFStickerContentStringKey const LFStickerContentCustomAlbum;

CGFloat const lf_stickerSize = 80;
CGFloat const lf_stickerMargin = 10;

#define kImageExtensions @[@"png", @"jpg", @"jpeg", @"gif"]

#pragma mark - LFStickerCollectionViewCell
@interface LFStickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *lf_tagStr;
@property (nonatomic, weak) UIImageView *lf_imageView;

+ (NSString *)identifier;
@end

@implementation LFStickerCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    self.lf_imageView.frame = CGRectMake(0, 0, width, height);
}

- (void)customInit
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageView];
    self.lf_imageView = imageView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.lf_imageView.image = nil;
    self.lf_tagStr = nil;
}

+ (NSString *)identifier
{
    return NSStringFromClass([LFStickerCollectionViewCell class]);
}

@end

@interface LFStickerBar () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray<LFStickerContent *> *resources;
@property (nonatomic, strong) NSArray<NSString *> *allStickerTitles;
@property (nonatomic, strong) NSArray<NSArray<id /* NSURL * / PHAsset * */>*> *allStickers;

@property (nonatomic, weak) JRStickerDisplayView *stickerDisplayView;

@property (strong, nonatomic) dispatch_queue_t concurrentQueue;

/* 外置资源 */
@property (nonatomic, assign) BOOL external;

/* 记录自身高度 */
@property (nonatomic, assign) CGFloat myHeight;

@end

@implementation LFStickerBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _myHeight = frame.size.height;
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame resources:(NSArray <LFStickerContent *>*)resources
{
    self = [super initWithFrame:frame];
    if (self) {
        _myHeight = frame.size.height;
        _resources = resources;
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame cacheResources:(id)cacheResources
{
    self = [super initWithFrame:frame];
    if (self) {
        _myHeight = frame.size.height;
        _cacheResources = cacheResources;
        [self customInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.stickerDisplayView.height = self.height - self.safeAreaInsets.bottom;
    }
}

- (void)customInit
{
    _concurrentQueue = dispatch_queue_create("com.LFStickerBar.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    if (@available(iOS 8.0, *)) {
        // 定义毛玻璃效果
        self.backgroundColor = [UIColor clearColor];
        UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
        effe.frame = self.bounds;
        [self addSubview:effe];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    }
    self.userInteractionEnabled = YES;
    /** 添加按钮获取点击 */
    UIButton *bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton.frame = self.bounds;
    [self addSubview:bgButton];
    
    if (_cacheResources) {
        
        [self setupStickerDisplayView];
        
    } else if (self.allStickerTitles == nil && self.allStickers == nil) {
        
        if (@available(iOS 8.0, *)){
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined && [self hasAlbumData]) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [self setupStickerDataAuthorization];
                    }
                }];                
            } else {
                [self setupStickerDataAuthorization];
            }
        } else {
            [self setupStickerDataAuthorization];
        }
    }
}

- (void)setupStickerDataAuthorization
{
    __weak typeof(self) weakSelf = self;
    [self setupStickerData:^(NSArray<NSString *> *allStickerTitles, NSArray<NSArray<id> *> *allStickers) {
        weakSelf.allStickerTitles = allStickerTitles;
        weakSelf.allStickers = allStickers;
        
        [weakSelf setupStickerDisplayView];
    }];
}

- (void)setupStickerDisplayView
{
    JRStickerDisplayView *stickerDisplayView = [[JRStickerDisplayView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [stickerDisplayView setBackgroundColor:[UIColor clearColor]];
    
    stickerDisplayView.itemSize = CGSizeMake(lf_stickerSize, lf_stickerSize);
    stickerDisplayView.itemMargin = lf_stickerMargin;
    stickerDisplayView.normalTitleColor = [UIColor whiteColor];
    stickerDisplayView.selectTitleColor = [UIColor colorWithRed:52/255.0 green:230/255.0 blue:92/255.0 alpha:1.0];
    stickerDisplayView.normalImage = [NSBundle LFME_imageNamed:@"StickerDisplayPlaceholder.png"];
    stickerDisplayView.failureImage = [NSBundle LFME_imageNamed:@"StickerDisplayFail.png"];
    
    __weak typeof(self) weakSelf = self;
    stickerDisplayView.didSelectBlock = ^(NSData * _Nonnull data, UIImage * _Nonnull thumbnailImage) {
        if ([weakSelf.delegate respondsToSelector:@selector(lf_stickerBar:didSelectImage:)]) {
            [weakSelf.delegate lf_stickerBar:weakSelf didSelectImage:thumbnailImage];
        }
    };
    
    if (_cacheResources) {
        stickerDisplayView.cacheData = _cacheResources;
    } else {
        [stickerDisplayView setTitles:self.allStickerTitles contents:self.allStickers];
    }
    
    [self addSubview:stickerDisplayView];
    self.stickerDisplayView = stickerDisplayView;
}

#pragma mark - public

- (id)cacheResources
{
    return self.stickerDisplayView.cacheData;
}

#pragma mark - private

- (BOOL)hasAlbumData
{
    if (@available(iOS 8.0, *)){
        for (LFStickerContent *content in self.resources) {
            if (![content isKindOfClass:[LFStickerContent class]]) {
                continue;
            }
            if (content.title.length == 0) {
                continue;
            }
            for (id resource in content.contents) {
                if ([resource isKindOfClass:[NSString class]]) { // 相册
                    if ([resource hasPrefix:LFStickerContentCustomAlbum]) { // 自定义相册
                        return YES;
                    } else if ([resource isEqualToString:LFStickerContentAllAlbum]) { // 全部相册
                        return YES;
                    }
                } else if ([resource isKindOfClass:[PHAsset class]]) { // PHAsset
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)setupStickerData:(void (^)(NSArray <NSString *>*allStickerTitles, NSArray <NSArray<id /* NSURL * / PHAsset * */>*>*allStickers))completion
{
    NSMutableArray <NSString *>*allStickerTitles = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray <NSArray<id /* NSURL * / PHAsset * */>*>*allStickers = [NSMutableArray arrayWithCapacity:2];
    
    NSFileManager *fileManager = [NSFileManager new];
    
    dispatch_async(self.concurrentQueue, ^{
        for (LFStickerContent *content in self.resources) {
            if (![content isKindOfClass:[LFStickerContent class]]) {
                continue;
            }
            if (content.title.length == 0) {
                continue;
            }
            [allStickerTitles addObject:content.title];
            NSMutableArray *stickers = [@[] mutableCopy];
            for (id resource in content.contents) {
                if ([resource isKindOfClass:[NSString class]]) { // 相册
                    if ([resource hasPrefix:LFStickerContentCustomAlbum]) { // 自定义相册
                        if (@available(iOS 8.0, *)){
                            NSString *albumName = [resource substringToIndex:LFStickerContentCustomAlbum.length];
                            PHFetchOptions *option = [[PHFetchOptions alloc] init];
                            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                            
                            PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
                            PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                            PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
                            PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
                            PHFetchResult *regularAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                            PHFetchResult *customAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                            
                            NSArray *allAlbums = @[userAlbums, myPhotoStreamAlbum,syncedAlbums,sharedAlbums,regularAlbums,customAlbums];
                            
                            PHFetchResult *fetchResult = nil;
                            for (PHFetchResult *result in allAlbums) {
                                for (PHAssetCollection *collection in result) {
                                    // 有可能是PHCollectionList类的的对象，过滤掉
                                    if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                                    if ([collection.localizedTitle isEqualToString:albumName]) {
                                        fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                                        break;
                                    }
                                }
                                if (fetchResult) {
                                    break;
                                }
                            }
                            
                            if (fetchResult) {
                                for (PHAsset *asset in fetchResult) {
                                    [stickers addObject:asset];
                                }
                            }
                        }
                    } else if ([resource isEqualToString:LFStickerContentDefaultSticker]) { // 默认贴图
                        NSString *path = [NSBundle LFME_stickersPath];
                        NSArray <NSURL *>*files = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                        // sort
                        files = [files sortedArrayUsingComparator:^NSComparisonResult(NSURL * _Nonnull obj1, NSURL *  _Nonnull obj2) {
                            return [obj1.lastPathComponent compare:obj2.lastPathComponent options:NSNumericSearch] == NSOrderedDescending;
                        }];
                        [stickers addObjectsFromArray:files];
                    } else if ([resource isEqualToString:LFStickerContentAllAlbum]) { // 全部相册
                        if (@available(iOS 8.0, *)){
                            PHFetchOptions *option = [[PHFetchOptions alloc] init];
                            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
                            
                            PHFetchResult *fetchResult = nil;
                            for (PHAssetCollection *collection in smartAlbums) {
                                // 有可能是PHCollectionList类的的对象，过滤掉
                                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                                fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                                break;
                            }
                            
                            for (PHAsset *asset in fetchResult) {
                                [stickers addObject:asset];
                            }
                            
                        }
                    }
                    
                } else if ([resource isKindOfClass:[NSURL class]]) { // 目录路径或文件或URL
                    if ([[[resource scheme] lowercaseString] hasPrefix:@"file"]) { // 目录路径或文件
                        BOOL isDir = NO;
                        BOOL isExists = [fileManager fileExistsAtPath:[resource resourceSpecifier] isDirectory:&isDir];
                        if (isExists) {
                            if (isDir) {
                                NSMutableArray *filters = [NSMutableArray arrayWithCapacity:5];
                                NSArray <NSURL *>*files = [fileManager contentsOfDirectoryAtURL:resource includingPropertiesForKeys:@[NSURLNameKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                                for (NSURL *fileUrl in files) { // filters
                                    NSString *name;
                                    [fileUrl getResourceValue:&name forKey:NSURLNameKey error:nil];
                                    if (name.length && [kImageExtensions containsObject:[name.pathExtension lowercaseString]]) {
                                        [filters addObject:fileUrl];
                                    }
                                }
                                
                                // sort
                                [filters sortUsingComparator:^NSComparisonResult(NSURL * _Nonnull obj1, NSURL *  _Nonnull obj2) {
                                    return [obj1.lastPathComponent compare:obj2.lastPathComponent options:NSNumericSearch] == NSOrderedDescending;
                                }];
                                
                                [stickers addObjectsFromArray:filters];
                                [filters removeAllObjects];
                                
                            } else {
                                [stickers addObject:resource];
                            }
                        }
                        
                    } else { // URL
                        [stickers addObject:resource];
                    }
                    
                } else {
                    if (@available(iOS 8.0, *)){
                        if ([resource isKindOfClass:[PHAsset class]]) { // PHAsset
                            if (((PHAsset *)resource).mediaType == PHAssetMediaTypeImage) {
                                [stickers addObject:resource];
                            }
                        }
                    }
                }
            }
            [allStickers addObject:[stickers copy]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion([allStickerTitles copy], [allStickers copy]);
            }
        });
    });
}


@end

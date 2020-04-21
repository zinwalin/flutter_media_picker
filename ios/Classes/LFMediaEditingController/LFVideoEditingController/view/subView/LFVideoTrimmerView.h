//
//  LFVideoTrimmerView.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/18.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

OBJC_EXTERN NSTimeInterval lfme_videoDuration(NSTimeInterval duration);

@interface LFVideoTrimmerView : UIView

/** 视频对象 */
@property (nonatomic, strong) AVAsset *asset;
/** 最大图片数量 默认10张 */
@property (nonatomic, assign) NSInteger maxImageCount;
/** 最小尺寸 */
@property (nonatomic, assign) CGFloat controlMinWidth;
/** 最大尺寸 */
@property (nonatomic, assign) CGFloat controlMaxWidth;

/** 起始时间 */
@property (nonatomic, readonly) double startTime;
/** 结束时间 */
@property (nonatomic, readonly) double endTime;

@property (nonatomic, getter=isEnabledLeftCorner) BOOL enabledLeftCorner;
@property (nonatomic, getter=isEnabledRightCorner) BOOL enabledRightCorner;

/** 进度 */
@property (nonatomic, assign) double progress;
- (void)setHiddenProgress:(BOOL)hidden;

/** 重设控制区域 */
- (void)setGridRange:(NSRange)gridRange animated:(BOOL)animated;

/** 代理 */
@property (nonatomic, weak) id delegate;


@end

@protocol LFVideoTrimmerViewDelegate <NSObject>

- (void)lf_videoTrimmerViewDidBeginResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange;
- (void)lf_videoTrimmerViewDidResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange;
- (void)lf_videoTrimmerViewDidEndResizing:(LFVideoTrimmerView *)trimmerView gridRange:(NSRange)gridRange;

@end

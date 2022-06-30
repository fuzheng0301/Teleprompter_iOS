//
//  AdjustSliderView.h
//  Teleprompter_iOS
//
//  Created by fz on 2022/2/28.
//
//  调整slider控件

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustSliderView : UIView

/// 说明
@property (nonatomic, strong) NSString *title;

/// 指定进度
@property (nonatomic, assign) float sliderValue;

/// 进度最小值
@property(nonatomic, assign) float minimumValue;
/// 进度最大值
@property(nonatomic, assign) float maximumValue;

@property (nonatomic, strong) UISlider *stempSlider;

/// slider事件
/// @param target 控制器
/// @param action 事件
/// @param controlEvents 状态
- (void)sliderAddTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END

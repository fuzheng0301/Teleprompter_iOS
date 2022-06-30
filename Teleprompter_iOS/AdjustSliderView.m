//
//  AdjustSliderView.m
//  Teleprompter_iOS
//
//  Created by fz on 2022/2/28.
//

#import "AdjustSliderView.h"

@interface AdjustSliderView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *stempLab;

@end

@implementation AdjustSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUIWithFrame:frame];
    }
    return self;
}

- (void)createUIWithFrame:(CGRect)frame
{
    [self addSubview:self.titleLab];
    
    [self addSubview:self.stempSlider];
    
    [self addSubview:self.stempLab];
}

/// 说明
- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLab.text = title;
}

/// 进度最小值
- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    
    self.stempSlider.minimumValue = minimumValue;
}
/// 进度最大值
- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
    
    self.stempSlider.maximumValue = maximumValue;
}
/// 指定进度
- (void)setSliderValue:(float)sliderValue
{
    _sliderValue = sliderValue;
    
    self.stempSlider.value = sliderValue;
    self.stempLab.text = [NSString stringWithFormat:@"%.f",sliderValue];
}

/// slider事件
/// @param target 控制器
/// @param action 事件
/// @param controlEvents 状态
- (void)sliderAddTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.stempSlider addTarget:target action:action forControlEvents:controlEvents];
}

#pragma mark --- lazyload
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, self.bounds.size.height)];
        _titleLab.textColor = [UIColor lightGrayColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}
- (UISlider *)stempSlider
{
    if (!_stempSlider) {
        _stempSlider = [[UISlider alloc]initWithFrame:CGRectMake(60, 0, self.bounds.size.width-120, self.bounds.size.height)];
    }
    return _stempSlider;
}
- (UILabel *)stempLab
{
    if (!_stempLab) {
        _stempLab = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-50, 0, 40, self.bounds.size.height)];
        _stempLab.textColor = [UIColor lightGrayColor];
        _stempLab.textAlignment = NSTextAlignmentCenter;
    }
    return _stempLab;
}


@end

//
//  PlayscriptTextView.m
//  Teleprompter_iOS
//
//  Created by fz on 2022/2/28.
//

#import "PlayscriptTextView.h"

@interface PlayscriptTextView ()

@property (nonatomic, strong) UILabel *lineLab;
@property (nonatomic, strong) UIView *shutterView;//遮板

@end

@implementation PlayscriptTextView

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
    [self addSubview:self.textV];
    
    [self addSubview:self.lineLab];
    
    [self addSubview:self.shutterView];
}

/// 重新设置控件大小
- (void)resetFrame:(CGRect)frame
{
    self.textV.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.shutterView.frame = CGRectMake(0, 0, frame.size.width, 30);
    self.lineLab.frame = CGRectMake(0, 30, frame.size.width, 1);
}

/// 设置内容
- (void)setTextString:(NSString *)textString
{
    _textString = textString;
    
    self.textV.text = textString;
}
/// 设置内容字号
- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    
    self.textV.font = textFont;
}


#pragma mark --- lazyload
- (UITextView *)textV
{
    if (!_textV) {
        _textV = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _textV.scrollEnabled= YES;
        _textV.editable = NO;
        _textV.textColor = [UIColor darkGrayColor];
        _textV.layoutManager.allowsNonContiguousLayout= NO;
    }
    return _textV;
}
- (UIView *)shutterView
{
    if (!_shutterView) {
        _shutterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        _shutterView.alpha = 0.1;
        _shutterView.backgroundColor = [UIColor blackColor];
    }
    return _shutterView;
}
- (UILabel *)lineLab
{
    if (!_lineLab) {
        _lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, self.bounds.size.width, 1)];
        _lineLab.backgroundColor = [UIColor redColor];
    }
    return _lineLab;
}

@end

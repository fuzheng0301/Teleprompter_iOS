//
//  PlayscriptTextView.h
//  Teleprompter_iOS
//
//  Created by fz on 2022/2/28.
//
//  台词本控件

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface PlayscriptTextView : UIView

@property (nonatomic, strong) UITextView *textV;

/// TextView内容
@property (nonatomic, strong) NSString *textString;

/// 内容字号
@property (nonatomic, strong) UIFont *textFont;

- (void)resetFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LGThemeStyle) {
    LGThemeStyleLight = 0,
    LGThemeStyleDark = 1,
};

/// Posted after the active theme changes. Observers should re-style themselves.
extern NSNotificationName const LGThemeDidChangeNotification;

@interface LGThemeManager : NSObject

@property (class, nonatomic, readonly) LGThemeManager *sharedManager;

@property (nonatomic, readonly) LGThemeStyle style;

@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *cellColor;
@property (nonatomic, readonly) UIColor *accentColor;
@property (nonatomic, readonly) UIColor *primaryTextColor;
@property (nonatomic, readonly) UIColor *secondaryTextColor;
@property (nonatomic, readonly) UIColor *separatorColor;

- (UIFont *)fontOfSize:(CGFloat)size weight:(UIFontWeight)weight;

- (void)toggleTheme;
- (void)applyToNavigationController:(UINavigationController *)nav;

/// For tests: back the manager with a throwaway defaults suite.
- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults;

@end

NS_ASSUME_NONNULL_END

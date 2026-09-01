#import "LGThemeManager.h"

NSNotificationName const LGThemeDidChangeNotification = @"LGThemeDidChangeNotification";

static NSString *const LGThemeDefaultsKey = @"LGSelectedTheme";

static UIColor *LGColorFromHex(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@interface LGThemeManager ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, assign) LGThemeStyle style;
@end

@implementation LGThemeManager

+ (LGThemeManager *)sharedManager {
    static LGThemeManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGThemeManager alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
    });
    return shared;
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if (self) {
        _defaults = defaults;
        _style = (LGThemeStyle)[defaults integerForKey:LGThemeDefaultsKey];
    }
    return self;
}

- (void)toggleTheme {
    self.style = (self.style == LGThemeStyleLight) ? LGThemeStyleDark : LGThemeStyleLight;
    [self.defaults setInteger:self.style forKey:LGThemeDefaultsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGThemeDidChangeNotification object:self];
}

#pragma mark - Palette

// Light mode: Aegean flag blue on white.
// Dark mode: terminal green — neon accents on a deep green ground.

- (UIColor *)backgroundColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0xF5F7FA) : LGColorFromHex(0x04150C);
}

- (UIColor *)cellColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0x0D5EAF) : LGColorFromHex(0x0A2417);
}

- (UIColor *)accentColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0x0D5EAF) : LGColorFromHex(0x00FF41);
}

- (UIColor *)primaryTextColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0x1A1A2E) : LGColorFromHex(0x00FF41);
}

- (UIColor *)secondaryTextColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0x5A6B7B) : LGColorFromHex(0x00CC33);
}

- (UIColor *)separatorColor {
    return self.style == LGThemeStyleLight ? LGColorFromHex(0xD8DEE6) : LGColorFromHex(0x0F3B22);
}

- (UIFont *)fontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    if (self.style == LGThemeStyleDark) {
        // Terminal-style monospaced type for dark mode.
        return [UIFont monospacedSystemFontOfSize:size weight:weight];
    }
    return [UIFont systemFontOfSize:size weight:weight];
}

- (void)applyToNavigationController:(UINavigationController *)nav {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = self.backgroundColor;
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName : self.primaryTextColor,
        NSFontAttributeName : [self fontOfSize:17 weight:UIFontWeightSemibold],
    };
    appearance.largeTitleTextAttributes = @{
        NSForegroundColorAttributeName : self.primaryTextColor,
        NSFontAttributeName : [self fontOfSize:32 weight:UIFontWeightBold],
    };
    nav.navigationBar.standardAppearance = appearance;
    nav.navigationBar.scrollEdgeAppearance = appearance;
    nav.navigationBar.tintColor = self.accentColor;
    nav.overrideUserInterfaceStyle =
        self.style == LGThemeStyleDark ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
}

@end

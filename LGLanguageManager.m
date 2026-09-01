#import "LGLanguageManager.h"

NSNotificationName const LGLanguageDidChangeNotification = @"LGLanguageDidChangeNotification";

static NSString *const LGLanguageDefaultsKey = @"LGBaseLanguage";

NSString *const LGFeatureCantoneseKey = @"LGFeatureCantonese";

@interface LGLanguageManager ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, copy) NSString *languageCode;
@end

@implementation LGLanguageManager

+ (LGLanguageManager *)sharedManager {
    static LGLanguageManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGLanguageManager alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
    });
    return shared;
}

+ (NSArray<NSString *> *)allLanguageCodes {
    return @[ @"en", @"es", @"it", @"fr", @"yue" ];
}

+ (NSArray<NSString *> *)supportedLanguageCodes {
    NSMutableArray<NSString *> *codes = [@[ @"en", @"es", @"it", @"fr" ] mutableCopy];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:LGFeatureCantoneseKey]) {
        [codes addObject:@"yue"];
    }
    return codes;
}

+ (NSString *)displayNameForLanguageCode:(NSString *)code {
    NSDictionary<NSString *, NSString *> *names = @{
        @"en" : @"English",
        @"es" : @"Español",
        @"it" : @"Italiano",
        @"fr" : @"Français",
        @"yue" : @"廣東話",
    };
    return names[code] ?: code;
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if (self) {
        _defaults = defaults;
        NSString *saved = [defaults stringForKey:LGLanguageDefaultsKey];
        _languageCode = [saved copy] ?: [[self class] detectDeviceLanguage];
    }
    return self;
}

/// Best supported match for the device's preferred language; Chinese of any
/// flavor maps to Cantonese since that's the variant we ship.
+ (NSString *)detectDeviceLanguage {
    NSArray<NSString *> *supported = [self supportedLanguageCodes];
    for (NSString *preferred in [NSLocale preferredLanguages]) {
        if ([supported containsObject:@"yue"] &&
            ([preferred hasPrefix:@"yue"] || [preferred hasPrefix:@"zh"])) {
            return @"yue";
        }
        for (NSString *code in supported) {
            if ([preferred hasPrefix:code]) {
                return code;
            }
        }
    }
    return @"en";
}

- (void)setLanguageCode:(NSString *)languageCode {
    if ([_languageCode isEqualToString:languageCode]) {
        return;
    }
    _languageCode = [languageCode copy];
    [self.defaults setObject:languageCode forKey:LGLanguageDefaultsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGLanguageDidChangeNotification
                                                        object:self];
}

@end

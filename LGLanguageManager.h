#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Posted after the base language changes.
extern NSNotificationName const LGLanguageDidChangeNotification;

/// Feature flag (NSUserDefaults BOOL): set YES to offer Cantonese in the UI.
extern NSString *const LGFeatureCantoneseKey;

/// The user's base language — the language translations are shown in.
/// Defaults to the device language when supported, English otherwise.
@interface LGLanguageManager : NSObject

@property (class, nonatomic, readonly) LGLanguageManager *sharedManager;

/// Every language the data set is translated into, in display order.
/// Includes languages still behind feature flags.
@property (class, nonatomic, readonly) NSArray<NSString *> *allLanguageCodes;

/// The languages currently offered in the UI: en, es, it, fr — plus any
/// flagged languages that have been enabled (see LGFeatureCantoneseKey).
@property (class, nonatomic, readonly) NSArray<NSString *> *supportedLanguageCodes;

@property (nonatomic, copy, readonly) NSString *languageCode;

- (void)setLanguageCode:(NSString *)languageCode;

/// Native display name for a supported code (e.g. "Español", "廣東話").
+ (NSString *)displayNameForLanguageCode:(NSString *)code;

/// For tests: back the manager with a throwaway defaults suite.
- (instancetype)initWithUserDefaults:(NSUserDefaults *)defaults;

@end

NS_ASSUME_NONNULL_END

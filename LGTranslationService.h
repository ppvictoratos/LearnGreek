#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Translates English text to Greek via MyMemory (free, no key).
/// Results are cached in NSUserDefaults so the same phrase never hits
/// the network twice.
@interface LGTranslationService : NSObject

@property (class, nonatomic, readonly) LGTranslationService *sharedService;

/// Translates `phrase` from English to Greek. Calls `completion` on the
/// main queue. On cache hit, calls synchronously on the next run loop tick.
- (void)translatePhrase:(NSString *)phrase
             completion:(void (^)(NSString *_Nullable translation, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGWord : NSObject

@property (nonatomic, copy, readonly) NSString *greek;
@property (nonatomic, copy, readonly) NSString *transliteration;

/// Stable identity used for favorites persistence.
@property (nonatomic, copy, readonly) NSString *wordID;

/// Translation in the given base language (en/es/it/fr/yue); falls back to English.
- (NSString *)translationForLanguage:(NSString *)languageCode;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

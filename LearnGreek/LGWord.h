#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGWord : NSObject

/// The core word (or phrase) without its definite article — what a learner
/// should recognize as *the word*.
@property (nonatomic, copy, readonly) NSString *greek;

/// Definite article (Ο/Η/Το/Οι) when the entry is a noun; empty for phrases.
/// The article carries the noun's grammatical gender, so it is taught, not hidden.
@property (nonatomic, copy, readonly) NSString *article;

/// Article + word for nouns ("Ο Δίας"), or just the word for phrases.
@property (nonatomic, copy, readonly) NSString *fullPhrase;

@property (nonatomic, copy, readonly) NSString *transliteration;

/// Stable identity used for favorites persistence (the full phrase, which
/// keeps favorites saved by earlier versions valid).
@property (nonatomic, copy, readonly) NSString *wordID;

/// Translation in the given base language (en/es/it/fr/yue); falls back to English.
- (NSString *)translationForLanguage:(NSString *)languageCode;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

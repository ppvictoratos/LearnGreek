#import "LGWord.h"
#import "LGLanguageManager.h"

@interface LGWord ()
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *translations;
@end

@implementation LGWord

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _greek = [dictionary[@"el"] copy] ?: @"";
        _article = [dictionary[@"art"] copy] ?: @"";
        _fullPhrase = _article.length > 0
            ? [NSString stringWithFormat:@"%@ %@", _article, _greek]
            : _greek;
        _transliteration = [dictionary[@"translit"] copy] ?: @"";
        _wordID = [_fullPhrase copy];

        NSMutableDictionary<NSString *, NSString *> *translations = [NSMutableDictionary dictionary];
        for (NSString *code in LGLanguageManager.allLanguageCodes) {
            NSString *value = dictionary[code];
            if (value.length > 0) {
                translations[code] = value;
            }
        }
        _translations = [translations copy];
    }
    return self;
}

- (NSString *)translationForLanguage:(NSString *)languageCode {
    return self.translations[languageCode] ?: self.translations[@"en"] ?: @"";
}

@end

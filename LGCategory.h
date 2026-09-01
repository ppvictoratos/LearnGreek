#import <Foundation/Foundation.h>

@class LGWord;

NS_ASSUME_NONNULL_BEGIN

@interface LGCategory : NSObject

@property (nonatomic, copy, readonly) NSString *categoryID;
@property (nonatomic, copy, readonly) NSString *nameGreek;

/// SF Symbol name for the home-grid tile.
@property (nonatomic, copy, readonly) NSString *symbolName;

@property (nonatomic, copy, readonly) NSArray<LGWord *> *words;

/// Category name in the given base language; falls back to English.
- (NSString *)nameForLanguage:(NSString *)languageCode;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

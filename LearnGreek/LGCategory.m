#import "LGCategory.h"
#import "LGWord.h"

@interface LGCategory ()
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *names;
@end

@implementation LGCategory

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _categoryID = [dictionary[@"id"] copy] ?: @"";
        _nameGreek = [dictionary[@"nameGreek"] copy] ?: @"";
        _symbolName = [dictionary[@"symbol"] copy] ?: @"questionmark";
        _names = [dictionary[@"names"] copy] ?: @{};

        NSMutableArray<LGWord *> *words = [NSMutableArray array];
        for (NSDictionary *entry in dictionary[@"words"]) {
            [words addObject:[[LGWord alloc] initWithDictionary:entry]];
        }
        _words = [words copy];
    }
    return self;
}

- (NSString *)nameForLanguage:(NSString *)languageCode {
    return self.names[languageCode] ?: self.names[@"en"] ?: @"";
}

@end

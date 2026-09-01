#import "LGDataStore.h"
#import "LGCategory.h"
#import "LGWord.h"
#import "LGSentence.h"

NSNotificationName const LGFavoritesDidChangeNotification = @"LGFavoritesDidChangeNotification";
NSNotificationName const LGSentencesDidChangeNotification = @"LGSentencesDidChangeNotification";

static NSString *const LGFavoritesDefaultsKey = @"LGFavoriteWordIDs";
static NSString *const LGSentencesDefaultsKey = @"LGSavedSentences";

@interface LGDataStore ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *favoriteIDs;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *sentences;
@property (nonatomic, strong) NSMutableArray<LGSentence *> *sentencesWithIcons;
@property (nonatomic, copy) NSArray<LGCategory *> *categories;
@end

@implementation LGDataStore

+ (LGDataStore *)sharedStore {
    static LGDataStore *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGDataStore alloc] initWithBundle:[NSBundle mainBundle]
                                        userDefaults:[NSUserDefaults standardUserDefaults]];
    });
    return shared;
}

- (instancetype)initWithBundle:(NSBundle *)bundle userDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if (self) {
        _defaults = defaults;
        NSArray<NSString *> *saved = [defaults stringArrayForKey:LGFavoritesDefaultsKey] ?: @[];
        _favoriteIDs = [NSMutableOrderedSet orderedSetWithArray:saved];
        NSArray<NSString *> *sentences = [defaults stringArrayForKey:LGSentencesDefaultsKey] ?: @[];
        _sentences = [NSMutableOrderedSet orderedSetWithArray:sentences];
        _categories = [self loadCategoriesFromBundle:bundle];
        [self loadSavedSentencesWithIcons];
    }
    return self;
}

- (NSArray<LGCategory *> *)loadCategoriesFromBundle:(NSBundle *)bundle {
    NSURL *url = [bundle URLForResource:@"words" withExtension:@"json"];
    NSAssert(url != nil, @"words.json missing from bundle");
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSAssert(root != nil, @"words.json failed to parse: %@", error);

    NSMutableArray<LGCategory *> *categories = [NSMutableArray array];
    for (NSDictionary *entry in root[@"categories"]) {
        [categories addObject:[[LGCategory alloc] initWithDictionary:entry]];
    }
    return categories;
}

#pragma mark - Favorites

- (NSArray<LGWord *> *)favoriteWords {
    NSMutableArray<LGWord *> *favorites = [NSMutableArray array];
    for (LGCategory *category in self.categories) {
        for (LGWord *word in category.words) {
            if ([self.favoriteIDs containsObject:word.wordID]) {
                [favorites addObject:word];
            }
        }
    }
    return favorites;
}

- (BOOL)isFavorite:(LGWord *)word {
    return [self.favoriteIDs containsObject:word.wordID];
}

- (void)toggleFavorite:(LGWord *)word {
    if ([self.favoriteIDs containsObject:word.wordID]) {
        [self.favoriteIDs removeObject:word.wordID];
    } else {
        [self.favoriteIDs addObject:word.wordID];
    }
    [self.defaults setObject:self.favoriteIDs.array forKey:LGFavoritesDefaultsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGFavoritesDidChangeNotification
                                                        object:self];
}

#pragma mark - Saved sentences

- (NSArray<NSString *> *)savedSentences {
    return self.sentences.array;
}

- (void)saveSentence:(NSString *)sentence {
    NSString *trimmed = [sentence
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0 || [self.sentences containsObject:trimmed]) {
        return;
    }
    [self.sentences addObject:trimmed];
    [self persistSentences];
}

- (void)deleteSentence:(NSString *)sentence {
    if (![self.sentences containsObject:sentence]) {
        return;
    }
    [self.sentences removeObject:sentence];
    [self persistSentences];
}

- (void)persistSentences {
    [self.defaults setObject:self.sentences.array forKey:LGSentencesDefaultsKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGSentencesDidChangeNotification
                                                        object:self];
}

#pragma mark - Saved sentences with icons

- (NSArray<LGSentence *> *)savedSentencesWithIcons {
    return [self.sentencesWithIcons copy];
}

- (void)loadSavedSentencesWithIcons {
    NSData *data = [self.defaults dataForKey:@"LGSavedSentencesWithIcons"];
    if (data) {
        NSArray *decoded = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[LGSentence class]
                                                                      fromData:data error:nil];
        _sentencesWithIcons = [decoded mutableCopy] ?: [NSMutableArray array];
    } else {
        _sentencesWithIcons = [NSMutableArray array];
    }
}

- (void)addSentence:(LGSentence *)sentence {
    [self.sentencesWithIcons addObject:sentence];
    [self persistSentencesWithIcons];
}

- (void)updateSentence:(LGSentence *)sentence {
    NSUInteger idx = [self.sentencesWithIcons indexOfObjectPassingTest:^BOOL(LGSentence *s, NSUInteger i, BOOL *stop) {
        return [s.sentenceID isEqualToString:sentence.sentenceID];
    }];
    if (idx != NSNotFound) {
        [self.sentencesWithIcons replaceObjectAtIndex:idx withObject:sentence];
        [self persistSentencesWithIcons];
    }
}

- (void)deleteSentenceWithID:(LGSentence *)sentence {
    NSUInteger idx = [self.sentencesWithIcons indexOfObjectPassingTest:^BOOL(LGSentence *s, NSUInteger i, BOOL *stop) {
        return [s.sentenceID isEqualToString:sentence.sentenceID];
    }];
    if (idx != NSNotFound) {
        [self.sentencesWithIcons removeObjectAtIndex:idx];
        [self persistSentencesWithIcons];
    }
}

- (void)persistSentencesWithIcons {
    NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self.sentencesWithIcons
                                            requiringSecureCoding:NO error:nil];
    [self.defaults setObject:encoded forKey:@"LGSavedSentencesWithIcons"];
    [self.defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGSentencesDidChangeNotification
                                                        object:self];
}

@end

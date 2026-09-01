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
@property (nonatomic, strong) NSMutableArray<LGSentence *> *savedSentencesWithIconsMutable;
@property (nonatomic, copy) NSArray<LGCategory *> *categories;
@end

@implementation LGDataStore

+ (LGDataStore *)sharedStore {
    NSLog(@"[LGDataStore] sharedStore accessed");
    static LGDataStore *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[LGDataStore] Initializing sharedStore...");
        shared = [[LGDataStore alloc] initWithBundle:[NSBundle mainBundle]
                                        userDefaults:[NSUserDefaults standardUserDefaults]];
        NSLog(@"[LGDataStore] sharedStore initialized");
    });
    return shared;
}

- (instancetype)initWithBundle:(NSBundle *)bundle userDefaults:(NSUserDefaults *)defaults {
    NSLog(@"[LGDataStore] initWithBundle:userDefaults: called");
    self = [super init];
    if (self) {
        NSLog(@"[LGDataStore] Loading favorites and sentences from defaults...");
        _defaults = defaults;
        NSArray<NSString *> *saved = [defaults stringArrayForKey:LGFavoritesDefaultsKey] ?: @[];
        _favoriteIDs = [NSMutableOrderedSet orderedSetWithArray:saved];
        NSArray<NSString *> *sentences = [defaults stringArrayForKey:LGSentencesDefaultsKey] ?: @[];
        _sentences = [NSMutableOrderedSet orderedSetWithArray:sentences];
        NSLog(@"[LGDataStore] Loading categories from bundle...");
        _categories = [self loadCategoriesFromBundle:bundle];
        NSLog(@"[LGDataStore] Categories loaded, count: %lu", (unsigned long)_categories.count);
        NSLog(@"[LGDataStore] Loading saved sentences with icons...");
        [self loadSavedSentencesWithIcons];
        NSLog(@"[LGDataStore] Loaded %lu saved sentences", (unsigned long)_savedSentencesWithIconsMutable.count);
    }
    return self;
}

- (NSArray<LGCategory *> *)loadCategoriesFromBundle:(NSBundle *)bundle {
    NSLog(@"[LGDataStore] loadCategoriesFromBundle: looking for words.json...");
    NSURL *url = [bundle URLForResource:@"words" withExtension:@"json"];
    if (!url) {
        NSLog(@"[LGDataStore] ERROR: words.json not found in bundle!");
        NSAssert(url != nil, @"words.json missing from bundle");
    }
    NSLog(@"[LGDataStore] Found words.json at: %@", url);

    NSLog(@"[LGDataStore] Loading JSON data...");
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        NSLog(@"[LGDataStore] ERROR: Failed to load data from URL");
    }

    NSLog(@"[LGDataStore] Parsing JSON...");
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!root) {
        NSLog(@"[LGDataStore] ERROR: Failed to parse JSON: %@", error);
        NSAssert(root != nil, @"words.json failed to parse: %@", error);
    }

    NSLog(@"[LGDataStore] JSON parsed successfully. Root type: %@", NSStringFromClass([root class]));
    NSLog(@"[LGDataStore] Creating category objects...");
    NSMutableArray<LGCategory *> *categories = [NSMutableArray array];
    id categoriesObj = root[@"categories"];
    NSLog(@"[LGDataStore] categories object type: %@, value: %@", NSStringFromClass([categoriesObj class]), categoriesObj);

    for (NSDictionary *entry in categoriesObj) {
        [categories addObject:[[LGCategory alloc] initWithDictionary:entry]];
    }
    NSLog(@"[LGDataStore] Created %lu category objects", (unsigned long)categories.count);
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
    if (!self.savedSentencesWithIconsMutable || ![self.savedSentencesWithIconsMutable isKindOfClass:[NSMutableArray class]]) {
        _savedSentencesWithIconsMutable = [NSMutableArray array];
    }
    return [self.savedSentencesWithIconsMutable copy];
}

- (void)loadSavedSentencesWithIcons {
    NSLog(@"[LGDataStore] loadSavedSentencesWithIcons called");
    _savedSentencesWithIconsMutable = [NSMutableArray array];
    NSData *data = [self.defaults dataForKey:@"LGSavedSentencesWithIcons"];
    NSLog(@"[LGDataStore] Retrieved data from defaults: %@", data ? @"YES" : @"NO");

    if (data) {
        @try {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSArray *decoded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            #pragma clang diagnostic pop
            NSLog(@"[LGDataStore] Decoded array: %@", decoded);
            if ([decoded isKindOfClass:[NSArray class]]) {
                _savedSentencesWithIconsMutable = [decoded mutableCopy];
                NSLog(@"[LGDataStore] Loaded %lu sentences", (unsigned long)_savedSentencesWithIconsMutable.count);
            }
        } @catch (NSException *e) {
            NSLog(@"[LGDataStore] Exception during decode: %@", e);
            [self.defaults removeObjectForKey:@"LGSavedSentencesWithIcons"];
        }
    } else {
        NSLog(@"[LGDataStore] No data in defaults for LGSavedSentencesWithIcons");
    }
}

- (void)addSentence:(LGSentence *)sentence {
    NSLog(@"[LGDataStore] addSentence called with text: %@, icon: %@", sentence.text, sentence.iconSymbolName);
    NSLog(@"[LGDataStore] savedSentencesWithIconsMutable before: %@", self.savedSentencesWithIconsMutable);
    [self.savedSentencesWithIconsMutable addObject:sentence];
    NSLog(@"[LGDataStore] savedSentencesWithIconsMutable after: %@", self.savedSentencesWithIconsMutable);
    [self persistSentencesWithIcons];
}

- (void)updateSentence:(LGSentence *)sentence {
    NSUInteger idx = [self.savedSentencesWithIconsMutable indexOfObjectPassingTest:^BOOL(LGSentence *s, NSUInteger i, BOOL *stop) {
        return [s.sentenceID isEqualToString:sentence.sentenceID];
    }];
    if (idx != NSNotFound) {
        [self.savedSentencesWithIconsMutable replaceObjectAtIndex:idx withObject:sentence];
        [self persistSentencesWithIcons];
    }
}

- (void)deleteSentenceWithID:(LGSentence *)sentence {
    NSUInteger idx = [self.savedSentencesWithIconsMutable indexOfObjectPassingTest:^BOOL(LGSentence *s, NSUInteger i, BOOL *stop) {
        return [s.sentenceID isEqualToString:sentence.sentenceID];
    }];
    if (idx != NSNotFound) {
        [self.savedSentencesWithIconsMutable removeObjectAtIndex:idx];
        [self persistSentencesWithIcons];
    }
}

- (void)persistSentencesWithIcons {
    NSLog(@"[LGDataStore] persistSentencesWithIcons called, count: %lu", (unsigned long)self.savedSentencesWithIconsMutable.count);
    NSError *error = nil;
    NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self.savedSentencesWithIconsMutable
                                            requiringSecureCoding:NO error:&error];
    if (!encoded) {
        NSLog(@"[LGDataStore] ERROR: Failed to archive sentences: %@", error);
        return;
    }
    NSLog(@"[LGDataStore] Archived data size: %lu bytes", (unsigned long)encoded.length);
    [self.defaults setObject:encoded forKey:@"LGSavedSentencesWithIcons"];
    [self.defaults synchronize];
    NSLog(@"[LGDataStore] Saved to defaults and synced");
    [[NSNotificationCenter defaultCenter] postNotificationName:LGSentencesDidChangeNotification
                                                        object:self];
    NSLog(@"[LGDataStore] Posted LGSentencesDidChangeNotification");
}

@end

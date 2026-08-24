#import "LGDataStore.h"
#import "LGCategory.h"
#import "LGWord.h"

NSNotificationName const LGFavoritesDidChangeNotification = @"LGFavoritesDidChangeNotification";

static NSString *const LGFavoritesDefaultsKey = @"LGFavoriteWordIDs";

@interface LGDataStore ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *favoriteIDs;
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
        _categories = [self loadCategoriesFromBundle:bundle];
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

@end

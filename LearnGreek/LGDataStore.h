#import <Foundation/Foundation.h>

@class LGCategory, LGWord;

NS_ASSUME_NONNULL_BEGIN

/// Posted whenever a word is favorited or unfavorited.
extern NSNotificationName const LGFavoritesDidChangeNotification;

@interface LGDataStore : NSObject

@property (class, nonatomic, readonly) LGDataStore *sharedStore;

/// All word categories, in display order, loaded from the bundled words.json.
@property (nonatomic, copy, readonly) NSArray<LGCategory *> *categories;

/// Favorited words across all categories, in category order.
@property (nonatomic, copy, readonly) NSArray<LGWord *> *favoriteWords;

- (BOOL)isFavorite:(LGWord *)word;
- (void)toggleFavorite:(LGWord *)word;

/// For tests: load from an explicit bundle and defaults suite.
- (instancetype)initWithBundle:(NSBundle *)bundle userDefaults:(NSUserDefaults *)defaults;

@end

NS_ASSUME_NONNULL_END

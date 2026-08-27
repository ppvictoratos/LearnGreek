#import <Foundation/Foundation.h>

@class LGCategory, LGWord;

NS_ASSUME_NONNULL_BEGIN

/// Posted whenever a word is favorited or unfavorited.
extern NSNotificationName const LGFavoritesDidChangeNotification;

/// Posted whenever a practice sentence is saved or deleted.
extern NSNotificationName const LGSentencesDidChangeNotification;

@interface LGDataStore : NSObject

@property (class, nonatomic, readonly) LGDataStore *sharedStore;

/// All word categories, in display order, loaded from the bundled words.json.
@property (nonatomic, copy, readonly) NSArray<LGCategory *> *categories;

/// Favorited words across all categories, in category order.
@property (nonatomic, copy, readonly) NSArray<LGWord *> *favoriteWords;

- (BOOL)isFavorite:(LGWord *)word;
- (void)toggleFavorite:(LGWord *)word;

/// Practice sentences the learner built, newest last. Plain Greek strings.
@property (nonatomic, copy, readonly) NSArray<NSString *> *savedSentences;

/// Saves a sentence. Blank or duplicate sentences are ignored.
- (void)saveSentence:(NSString *)sentence;
- (void)deleteSentence:(NSString *)sentence;

/// For tests: load from an explicit bundle and defaults suite.
- (instancetype)initWithBundle:(NSBundle *)bundle userDefaults:(NSUserDefaults *)defaults;

@end

NS_ASSUME_NONNULL_END

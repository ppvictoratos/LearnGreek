#import <UIKit/UIKit.h>

@class LGCategory;

NS_ASSUME_NONNULL_BEGIN

/// Word list for one category (or the favorites list).
/// Tap a row to hear the word; tap the star to favorite it.
@interface LGWordListViewController : UIViewController

- (instancetype)initWithCategory:(LGCategory *)category;
- (instancetype)initWithFavorites;

@end

NS_ASSUME_NONNULL_END

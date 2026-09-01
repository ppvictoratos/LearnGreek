#import <UIKit/UIKit.h>

@class LGWord, LGWordCell;

NS_ASSUME_NONNULL_BEGIN

@protocol LGWordCellDelegate <NSObject>
- (void)wordCellDidTapFavorite:(LGWordCell *)cell;
@end

@interface LGWordCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, weak, nullable) id<LGWordCellDelegate> delegate;

- (void)configureWithWord:(LGWord *)word favorite:(BOOL)favorite;

@end

NS_ASSUME_NONNULL_END

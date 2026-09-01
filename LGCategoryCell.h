#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGCategoryCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;

- (void)configureWithSymbolName:(NSString *)symbolName
                     titleGreek:(NSString *)titleGreek
                       subtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END

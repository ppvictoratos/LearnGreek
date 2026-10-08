#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Collection pipeline helpers so tests read as transformations of data.
@interface NSArray (LGFunctionalTesting)
- (NSArray *)lg_map:(id (^)(id element))transform;
- (NSArray *)lg_filter:(BOOL (^)(id element))predicate;
- (NSArray *)lg_flatMap:(NSArray *(^)(id element))transform;
/// Pairs elements by position and combines them; stops at the shorter array.
- (NSArray *)lg_zipWith:(NSArray *)other combine:(id (^)(id left, id right))combine;
@end

NS_ASSUME_NONNULL_END

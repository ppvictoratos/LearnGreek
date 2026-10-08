#import "LGFunctionalHelpers.h"

@implementation NSArray (LGFunctionalTesting)

- (NSArray *)lg_map:(id (^)(id element))transform {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id element in self) {
        [result addObject:transform(element) ?: [NSNull null]];
    }
    return [result copy];
}

- (NSArray *)lg_filter:(BOOL (^)(id element))predicate {
    NSMutableArray *result = [NSMutableArray array];
    for (id element in self) {
        if (predicate(element)) {
            [result addObject:element];
        }
    }
    return [result copy];
}

- (NSArray *)lg_flatMap:(NSArray *(^)(id element))transform {
    NSMutableArray *result = [NSMutableArray array];
    for (id element in self) {
        [result addObjectsFromArray:transform(element)];
    }
    return [result copy];
}

- (NSArray *)lg_zipWith:(NSArray *)other combine:(id (^)(id left, id right))combine {
    NSUInteger count = MIN(self.count, other.count);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        [result addObject:combine(self[i], other[i]) ?: [NSNull null]];
    }
    return [result copy];
}

@end

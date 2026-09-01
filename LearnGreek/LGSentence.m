#import "LGSentence.h"

@implementation LGSentence

- (instancetype)initWithText:(NSString *)text
                 iconSymbolName:(NSString *)iconSymbolName {
    self = [super init];
    if (self) {
        _text = [text copy];
        _iconSymbolName = [iconSymbolName copy] ?: @"ellipsis.bubble";
        _sentenceID = [[NSUUID UUID] UUIDString];
        _createdAt = [NSDate date];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.iconSymbolName forKey:@"iconSymbolName"];
    [coder encodeObject:self.sentenceID forKey:@"sentenceID"];
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _text = [decoder decodeObjectForKey:@"text"];
        _iconSymbolName = [decoder decodeObjectForKey:@"iconSymbolName"];
        _sentenceID = [decoder decodeObjectForKey:@"sentenceID"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
    }
    return self;
}

@end

#import "LGPhrase.h"

@implementation LGPhrase

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithText:(NSString *)text language:(LGPhraseLanguage)language {
    self = [super init];
    if (self) {
        _text = [text copy];
        _language = language;
        _phraseID = [[NSUUID UUID] UUIDString];
        _createdAt = [NSDate now];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeInteger:self.language forKey:@"language"];
    [coder encodeObject:self.phraseID forKey:@"phraseID"];
    [coder encodeObject:self.createdAt forKey:@"createdAt"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _text = [decoder decodeObjectForKey:@"text"];
        _language = [decoder decodeIntegerForKey:@"language"];
        _phraseID = [decoder decodeObjectForKey:@"phraseID"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
    }
    return self;
}

@end

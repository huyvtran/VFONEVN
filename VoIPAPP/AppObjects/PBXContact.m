//
//  PBXContact.m
//  linphone
//
//  Created by Apple on 5/12/17.
//
//

#import "PBXContact.h"

@implementation PBXContact

@synthesize _name, _number, _nameForSearch, _convertName;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self._name forKey:@"_name"];
    [encoder encodeObject:self._number forKey:@"_number"];
    [encoder encodeObject:self._convertName forKey:@"_convertName"];
    [encoder encodeObject:self._nameForSearch forKey:@"_nameForSearch"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init])) {
        self._name = [decoder decodeObjectForKey:@"_name"];
        self._number = [decoder decodeObjectForKey:@"_number"];
        self._convertName = [decoder decodeObjectForKey:@"_convertName"];
        self._nameForSearch = [decoder decodeObjectForKey:@"_nameForSearch"];
    }
    return self;
}

@end

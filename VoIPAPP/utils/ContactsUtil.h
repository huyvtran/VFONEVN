//
//  ContactsUtil.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneObject.h"
#import "PBXContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsUtil : NSObject

+ (void)startContactsUtil;
+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson;

+ (NSString *)getAvatarFromContactPerson: (ABRecordRef)person;
+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson;
+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson;

+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson;
+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson;
+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson;
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson;
+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number;
+ (PBXContact *)getPBXContactWithExtension: (NSString *)ext;
+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson;
+ (NSString *)getContactNameWithNumber: (NSString *)number;

@end

NS_ASSUME_NONNULL_END

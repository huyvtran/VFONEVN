//
//  ContactsUtil.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "ContactsUtil.h"
#import "PhoneObject.h"
#import "ContactDetailObj.h"

AppDelegate *contactUtilAppDel;

@implementation ContactsUtil

+ (void)startContactsUtil {
    contactUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            return [imgData base64EncodedStringWithOptions: 0];
        }
    }
    return @"";
}



+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            return [UIImage imageWithData: imgData];
        }
    }
    return [UIImage imageNamed:@"no_avatar.png"];
}

+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson
{
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, 0);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
        return phoneNumber;
    }
    return @"";
}

+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson {
    NSString *email = @"";
    ABMultiValueRef map = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
    if (map) {
        for (int i = 0; i < ABMultiValueGetCount(map); ++i) {
            ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(map, i);
            NSInteger index = ABMultiValueGetIndexForIdentifier(map, identifier);
            if (index != -1) {
                NSString *valueRef = CFBridgingRelease(ABMultiValueCopyValueAtIndex(map, index));
                if (valueRef != NULL && ![valueRef isEqualToString:@""]) {
                    //  just get one email for contact
                    email = valueRef;
                    break;
                }
            }
        }
        CFRelease(map);
    }
    return email;
}

+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson {
    NSString *result = @"";
    CFStringRef companyRef  = ABRecordCopyValue(aPerson, kABPersonOrganizationProperty);
    if (companyRef != NULL && companyRef != nil){
        NSString *company = (__bridge NSString *)companyRef;
        if (company != nil && ![company isEqualToString:@""]){
            result = company;
        }
    }
    return result;
}

+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson
{
    NSMutableArray *result = nil;
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    NSString *strPhone = [[NSMutableString alloc] init];
    if (ABMultiValueGetCount(phones) > 0)
    {
        result = [[NSMutableArray alloc] init];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            
            strPhone = @"";
            if (locLabel == nil) {
                ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                anItem._iconStr = @"btn_contacts_home.png";
                anItem._titleStr = text_home;
                anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = text_home;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = text_work;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = text_mobile;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = text_fax;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = text_other;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = text_mobile;
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
}

+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        if (firstName == nil) {
            firstName = @"";
        }
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        if (middleName == nil) {
            middleName = @"";
        }
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        if (lastName == nil) {
            lastName = @"";
        }
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![lastName isEqualToString:@""]) {
            fullname = lastName;
        }
        
        if (![middleName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = SFM(@"%@ %@", fullname, middleName);
            }
        }
        return @[firstName, fullname];
    }
    return @[@"", @""];
}

+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
    NSMutableArray *list = contactUtilAppDel.listInfoPhoneNumber;
    NSArray *filter = [list filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        for (int i=0; i<filter.count; i++) {
            PhoneObject *item = [filter objectAtIndex: i];
            if (![AppUtil isNullOrEmpty: item.avatar]) {
                return item;
            }
        }
        return [filter firstObject];
    }
    return nil;
}

+ (PBXContact *)getPBXContactWithExtension: (NSString *)ext {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_number = %@", ext];
    NSArray *filter = [contactUtilAppDel.pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter objectAtIndex: 0];
    }
    return nil;
}

+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![AppUtil isNullOrEmpty: lastName]) {
            fullname = lastName;
        }
        
        if (![AppUtil isNullOrEmpty: middleName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = SFM(@"%@ %@", fullname, middleName);
            }
        }
        
        if (![AppUtil isNullOrEmpty: firstName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = firstName;
            }else{
                fullname = SFM(@"%@ %@", fullname, firstName);
            }
        }
        if ([fullname isEqualToString:@""]) {
            return text_unknown;
        }
        return fullname;
    }
    return text_unknown;
}

+ (NSString *)getContactNameWithNumber: (NSString *)number {
    PhoneObject *contact = [self getContactPhoneObjectWithNumber: number];
    if (![AppUtil isNullOrEmpty: contact.name]) {
        return contact.name;
    }
    return number;
}

@end

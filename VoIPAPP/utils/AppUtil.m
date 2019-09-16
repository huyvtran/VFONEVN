//
//  AppUtil.m
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "AppUtil.h"
#import <CommonCrypto/CommonDigest.h>

AppDelegate *appUtilAppDel;

@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return SFM(@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1], result[2], result[3],
               result[4], result[5], result[6], result[7],
               result[8], result[9], result[10], result[11],
               result[12], result[13], result[14], result[15]);
}
@end

@implementation AppUtil

+ (void)startAppUtil {
    appUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)getMD5StringOfString: (NSString *)string {
    return [[string MD5String] lowercaseString];
}

+(BOOL)isNullOrEmpty:(NSString*)string{
    return string == nil || string==(id)[NSNull null] || [string isEqualToString: @""];
}

+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font {
    CGSize tmpSize = [text sizeWithAttributes: @{NSFontAttributeName: font}];
    return CGSizeMake(ceilf(tmpSize.width), ceilf(tmpSize.height));
}


+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size;
}

+ (NSString *)getCurrentDateTimeToStringWithLanguage: (NSString *)lang {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([lang isEqualToString: key_vi]) {
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)randomStringWithLength: (int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int iCount=0; iCount<len; iCount++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length]) % [letters length]]];
    }
    return randomString;
}

+ (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = SFM(@"%c", characterChar);
        if ([appUtilAppDel.listNumber containsObject: characterStr]) {
            resultStr = SFM(@"%@%@", resultStr, characterStr);
        }
    }
    return resultStr;
}

+ (NSString *)getCurrentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (void)setupFirstValueForSortContact {
    NSNumber *sortPBX = [[NSUserDefaults standardUserDefaults] objectForKey: sort_pbx];
    if (sortPBX == nil) {
        sortPBX = [NSNumber numberWithInt: eSortAZ];
        [[NSUserDefaults standardUserDefaults] setObject:sortPBX forKey:sort_pbx];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *sortGroup = [[NSUserDefaults standardUserDefaults] objectForKey: sort_group];
    if (sortGroup == nil) {
        sortGroup = [NSNumber numberWithInt: eSortAZ];
        [[NSUserDefaults standardUserDefaults] setObject:sortGroup forKey:sort_group];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion {
    NSString *version = @"";
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
    if (!showBuildVersion) {
        version = [info objectForKey:@"CFBundleShortVersionString"];
    }else{
        version = SFM(@"%@ (%@)", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]);
    }
    return version;
}

+ (NSString *)getBuildDate
{
    NSString *dateStr = SFM(@"%@ %@", [NSString stringWithUTF8String:__DATE__], [NSString stringWithUTF8String:__TIME__]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLL d yyyy HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date1 = [dateFormatter dateFromString:dateStr];
    
    NSTimeInterval time = [date1 timeIntervalSince1970];
    return [AppUtil stringDateFromInterval: time];
}

+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate: date];
    return currentTime;
}

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if (language == nil) {
        language = key_en;
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    if ([language isEqualToString: key_en]) {
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    }
    
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr{
    parentStr = [parentStr stringByReplacingOccurrencesOfString:@"đ" withString:@"d"];
    parentStr = [parentStr stringByReplacingOccurrencesOfString:@"Đ" withString:@"D"];
    
    NSData *dataConvert = [parentStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *convertName = [[NSString alloc] initWithData:dataConvert encoding:NSASCIIStringEncoding];
    return convertName;
}

+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName{
    convertName = [AppUtil convertUTF8CharacterToCharacter: convertName];
    
    convertName = [convertName lowercaseString];
    NSString *result = @"";
    for (int strCount=0; strCount<convertName.length; strCount++) {
        char characterChar = [convertName characterAtIndex: strCount];
        NSString *c = SFM(@"%c", characterChar);
        if ([c isEqualToString:@"a"] || [c isEqualToString:@"b"] || [c isEqualToString:@"c"]) {
            result = SFM(@"%@%@", result, @"2");
            
        }else if([c isEqualToString:@"d"] || [c isEqualToString:@"e"] || [c isEqualToString:@"f"]){
            result = SFM(@"%@%@", result, @"3");
            
        }else if ([c isEqualToString:@"g"] || [c isEqualToString:@"h"] || [c isEqualToString:@"i"]){
            result = SFM(@"%@%@", result, @"4");
            
        }else if ([c isEqualToString:@"j"] || [c isEqualToString:@"k"] || [c isEqualToString:@"l"]){
            result = SFM(@"%@%@", result, @"5");
            
        }else if ([c isEqualToString:@"m"] || [c isEqualToString:@"n"] || [c isEqualToString:@"o"]){
            result = SFM(@"%@%@", result, @"6");
            
        }else if ([c isEqualToString:@"p"] || [c isEqualToString:@"q"] || [c isEqualToString:@"r"] || [c isEqualToString:@"s"]){
            result = SFM(@"%@%@", result, @"7");
            
        }else if ([c isEqualToString:@"t"] || [c isEqualToString:@"u"] || [c isEqualToString:@"v"]){
            result = SFM(@"%@%@", result, @"8");
            
        }else if ([c isEqualToString:@"w"] || [c isEqualToString:@"x"] || [c isEqualToString:@"y"] || [c isEqualToString:@"z"]){
            result = SFM(@"%@%@", result, @"9");
            
        }else if ([c isEqualToString:@"1"]){
            result = SFM(@"%@%@", result, @"1");
            
        }else if ([c isEqualToString:@"0"]){
            result = SFM(@"%@%@", result, @"0");
            
        }else if ([c isEqualToString:@" "]){
            result = SFM(@"%@%@", result, @" ");
            
        }else{
            result = SFM(@"%@%@", result, c);
        }
    }
    return result;
}

+ (NSString *)getNameOfContact: (ABRecordRef)aPerson
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
        return fullname;
    }
    return @"";
}

+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *fileData = [NSData dataWithContentsOfFile: pathFile];
        return fileData;
    }
}

+ (NSString *)getDateFromTimeInterval: (NSTimeInterval)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)getCurrentTimeStampFromTimeInterval:(double)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)getCurrentTimeStamp{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [dateFormatter stringFromDate:now];
    return currentTime;
}

+ (NSString *)durationToString:(int)duration {
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        [result appendString:SFM(@"%02i:", duration / 3600)];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:SFM(@"%02i:%02i", (duration / 60), (duration % 60))];
}

+ (void)addBoxShadowForView: (UIView *)view withColor: (UIColor *)color{
    view.layer.shadowRadius  = view.layer.cornerRadius;
    view.layer.shadowColor   = color.CGColor;
    view.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.9f;
    view.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, 5.0f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(view.bounds, shadowInsets)];
    view.layer.shadowPath    = shadowPath.CGPath;
}

+ (NSString *)convertUTF8StringToString: (NSString *)string {
    if ([string isEqualToString:@"À"] || [string isEqualToString:@"Ã"] || [string isEqualToString:@"Ạ"]  || [string isEqualToString:@"Á"] || [string isEqualToString:@"Ả"]  || [string isEqualToString:@"Ằ"] || [string isEqualToString:@"Ẵ"] || [string isEqualToString:@"Ặ"] || [string isEqualToString:@"Ắ"] || [string isEqualToString:@"Ẳ"] || [string isEqualToString:@"Ă"] || [string isEqualToString:@"Ầ"] || [string isEqualToString:@"Ẫ"] || [string isEqualToString:@"Ậ"] || [string isEqualToString:@"Ấ"] || [string isEqualToString:@"Ẩ"] || [string isEqualToString:@"Â"]) {
        string = @"A";
    }else if ([string isEqualToString:@"Đ"]) {
        string = @"D";
    }else if ([string isEqualToString:@"È"] || [string isEqualToString:@"Ẽ"] || [string isEqualToString:@"Ẹ"] || [string isEqualToString:@"É"] || [string isEqualToString:@"Ẻ"]  || [string isEqualToString:@"Ề"] || [string isEqualToString:@"Ễ"] || [string isEqualToString:@"Ệ"] || [string isEqualToString:@"Ế"] || [string isEqualToString:@"Ể"] || [string isEqualToString:@"Ê"]) {
        string = @"E";
    }else if([string isEqualToString:@"Ì"] || [string isEqualToString:@"Ĩ"] || [string isEqualToString:@"Ị"] || [string isEqualToString:@"Í"] || [string isEqualToString:@"Ỉ"]) {
        string = @"I";
    }else if([string isEqualToString:@"Ò"] || [string isEqualToString:@"Õ"] || [string isEqualToString:@"Ọ"] || [string isEqualToString:@"Ó"] || [string isEqualToString:@"Ỏ"] || [string isEqualToString:@"Ờ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ợ"] || [string isEqualToString:@"Ớ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ơ"] || [string isEqualToString:@"Ồ"] || [string isEqualToString:@"Ỗ"] || [string isEqualToString:@"Ộ"] || [string isEqualToString:@"Ố"] || [string isEqualToString:@"Ổ"] || [string isEqualToString:@"Ô"]) {
        string = @"O";
    }else if ([string isEqualToString:@"Ù"] || [string isEqualToString:@"Ũ"] || [string isEqualToString:@"Ụ"] || [string isEqualToString:@"Ú"] || [string isEqualToString:@"Ủ"]) {
        string = @"U";
    }else if([string isEqualToString:@"Ỳ"] || [string isEqualToString:@"Ỹ"] || [string isEqualToString:@"Ỵ"] || [string isEqualToString:@"Ý"] || [string isEqualToString:@"Ỷ"]) {
        string = @"Y";
    }
    return string;
}

+ (NSString *)getNameWasStoredFromUserInfo: (NSString *)number {
    NSString *key = SFM(@"name_for_%@", number);
    NSString *display = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (![AppUtil isNullOrEmpty: display]) {
        return display;
    }
    return text_unknown;
}

+ (NSString *)getGroupNameWithQueueNumber: (NSString *)queueNum {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.queue == %@", queueNum];
    NSArray *tmpArr = [appUtilAppDel.listGroup filteredArrayUsingPredicate: predicate];
    if (tmpArr.count > 0) {
        NSDictionary *info = [tmpArr objectAtIndex: 0];
        NSString *queueName = [info objectForKey:@"queuename"];
        if (![AppUtil isNullOrEmpty: queueName]) {
            return queueName;
        }
    }
    return text_unknown;
}

+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    if ([calendar isDateInToday:date]) {
        return text_today;
        
    } else if ([calendar isDateInYesterday:date]) {
        return text_yesterday;
        
    } else {
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        return formattedDateString;
    }
}

+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow: 0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy/MM/dd"];
    [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"dd-MM-yyyy"];
    [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
    [formatter4 setDateFormat:@"yyyy-MM-dd"];
    [formatter4 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSString *currentTime = [formatter stringFromDate: today];
    NSString *currentTime2 = [formatter2 stringFromDate: today];
    NSString *currentTime3 = [formatter3 stringFromDate: today];
    NSString *currentTime4 = [formatter4 stringFromDate: today];
    
    if ([currentTime isEqualToString: dateStr] || [currentTime2 isEqualToString: dateStr] || [currentTime3 isEqualToString: dateStr] || [currentTime4 isEqualToString: dateStr]) {
        return @"Today";
    }else{
        return currentTime;
    }
}

/* Trả về title cho header section trong phần history call */
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr{
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy/MM/dd"];
    [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"dd-MM-yyyy"];
    [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
    [formatter4 setDateFormat:@"yyyy-MM-dd"];
    [formatter4 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSString *currentTime = [formatter stringFromDate: yesterday];
    NSString *currentTime2 = [formatter2 stringFromDate: yesterday];
    NSString *currentTime3 = [formatter3 stringFromDate: yesterday];
    NSString *currentTime4 = [formatter4 stringFromDate: yesterday];
    
    if ([currentTime isEqualToString: dateStr] || [currentTime2 isEqualToString: dateStr] || [currentTime3 isEqualToString: dateStr] || [currentTime4 isEqualToString: dateStr]) {
        return @"Yesterday";
    }else{
        return currentTime;
    }
}

+ (NSString *)convertDurtationToString: (long)duration
{
    if (duration == 0) {
        return SFM(@"0 %@", text_sec);
    }
    int hour = (int)(duration/3600);
    int minutes = (int)((duration - hour*3600)/60);
    int seconds = (int)(duration - hour*3600 - minutes*60);
    
    NSString *result = @"";
    if (hour > 0) {
        result = SFM(@"%ld %@", (long)hour, text_hour);
    }
    
    if (minutes > 0) {
        if (![result isEqualToString:@""]) {
            result = SFM(@"%@ %d %@", result, minutes, text_minute);
        }else{
            result = SFM(@"%d %@", minutes, text_minute);
        }
    }
    if (seconds > 0) {
        if (![result isEqualToString:@""]) {
            result = SFM(@"%@ %d %@", result, seconds, text_sec);
        }else{
            result = SFM(@"%d %@", seconds, text_sec);
        }
    }
    return result;
}

+ (BOOL)checkRecordsFileExistsInLocal: (NSString *)recordFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    NSString *filePath = SFM(@"%@/%@/%@", url, recordsFolderName, recordFile);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath: filePath];
}

+ (NSArray *)getAllFilesInDirectory: (NSString *)subPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent: subPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    return directoryContent;
}

+ (BOOL)deleteFileWithPath:(NSString *)filePath
{
    if(![self isFileExist: filePath]){
        return YES;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:filePath error:NULL];
}

+ (BOOL) isFileExist: (NSString*) file
{
    return [[NSFileManager defaultManager] fileExistsAtPath: file];
}

+ (BOOL)soundForCallIsEnable {
    NSString *soundCallKey = [NSString stringWithFormat:@"%@_%@", key_sound_call, USERNAME];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:soundCallKey];
    if (value == nil || [value isEqualToString: @"YES"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkDoNotDisturbMode {
    NSString *dndMode = [[NSUserDefaults standardUserDefaults] objectForKey:switch_dnd];
    if (![AppUtil isNullOrEmpty: dndMode] && [dndMode isEqualToString:@"1"]) {
        return TRUE;
    }
    return FALSE;
}

+ (void)enableDoNotDisturbMode: (BOOL)enable {
    if (enable) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:switch_dnd];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:switch_dnd];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)checkFileExistsInPath: (NSString *)path {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    NSString *filePath = SFM(@"%@/%@", url, path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath: filePath];
}

+ (NSString *)getLocalFilePathWithSubPath: (NSString *)subpath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    return SFM(@"%@/%@", url, subpath);
}

@end

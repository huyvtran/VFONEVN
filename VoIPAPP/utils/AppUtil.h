//
//  AppUtil.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUtil : NSObject

+ (void)startAppUtil;
+ (NSString *)getMD5StringOfString: (NSString *)string;
+(BOOL)isNullOrEmpty:(NSString*)string;
+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font;
+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth;
+ (NSString *)getCurrentDateTimeToStringWithLanguage: (NSString *)lang;
+ (NSString *)randomStringWithLength: (int)len;
+ (NSString *)removeAllSpecialInString: (NSString *)phoneString;
+ (NSString *)getCurrentDate;
+ (void)setupFirstValueForSortContact;
+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion;
+ (NSString *)getBuildDate;
+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval;
+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval;
+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr;
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName;

+ (NSString *)getNameOfContact: (ABRecordRef)aPerson;
+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName;
+ (NSString *)getDateFromTimeInterval: (NSTimeInterval)interval;
+ (NSString *)getCurrentTimeStampFromTimeInterval:(double)timeInterval;
+ (NSString *)getCurrentTimeStamp;
+ (NSString *)durationToString:(int)duration;
+ (void)addBoxShadowForView: (UIView *)view withColor: (UIColor *)color;
+ (NSString *)convertUTF8StringToString: (NSString *)string;
+ (NSString *)getNameWasStoredFromUserInfo: (NSString *)number;
+ (NSString *)getGroupNameWithQueueNumber: (NSString *)queueNum;
+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval;
+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval;
+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr;
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr;
+ (NSString *)convertDurtationToString: (long)duration;
+ (BOOL)checkRecordsFileExistsInLocal: (NSString *)recordFile;
+ (NSArray *)getAllFilesInDirectory: (NSString *)subPath;
+ (BOOL)deleteFileWithPath:(NSString *)filePath;
+ (BOOL) isFileExist: (NSString*) file;
+ (BOOL)soundForCallIsEnable;
+ (BOOL)checkDoNotDisturbMode;
+ (void)enableDoNotDisturbMode: (BOOL)enable;
+ (BOOL)checkFileExistsInPath: (NSString *)path;
+ (NSString *)getLocalFilePathWithSubPath: (NSString *)subpath;

@end

NS_ASSUME_NONNULL_END

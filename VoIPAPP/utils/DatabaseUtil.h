//
//  DatabaseUtil.h
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseUtil : NSObject

+ (void)startDatabaseUtil;
+ (BOOL)connectToDatabase;
+ (void)InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int callType : (int)callType sipURI : (NSString*)sipUri MySip : (NSString *)mysip andFlag: (int)flag andUnread: (int)unread;
+ (NSString *)getLastCallOfUser;
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)account isMissed: (BOOL)missed;
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)account;
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)account;
+ (int)getMissedCallUnreadWithRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;
+ (NSDictionary *)getCallInfoWithHistoryCallId: (int)callId;
+ (BOOL)removeHistoryCallsOfUser: (NSString *)user onDate: (NSString *)date ofAccount: (NSString *)account onlyMissed: (BOOL)missed;
+ (int)getUnreadMissedCallHisotryWithAccount: (NSString *)account;
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber;
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr onlyMissedCall: (BOOL)onlyMissedCall;
+ (BOOL)resetMissedCallOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;
+ (BOOL)deleteCallHistoryOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;

@end

NS_ASSUME_NONNULL_END

//
//  WebServiceUtil.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WebServiceUtilDelegate <NSObject>
@optional
- (void)failedToSignInWithError: (id)error;
- (void)signInSuccessfullyWithData: (id)data;

- (void)failedToDecryptRSAAccountWithError: (id)error;
- (void)decryptRSAAccountSuccessfullyWithData: (id)data;

- (void)failedToGetDIDListWithError: (id)error;
- (void)getDIDListSuccessfullyWithData: (id)data;

- (void)failedToGetContactsWithError: (id)error;
- (void)getContactsSuccessfullyWithData: (id)data;

- (void)failedToGetServerGroupsWithError: (id)error;
- (void)getServerGroupsSuccessfullyWithData: (id)data;

- (void)failedToGetListRecordFilesWithError:(id)error;
- (void)getListRecordFilesSuccessfullyWithData: (id)data;

- (void)failedToGetFileRecordWithError:(id)error;
- (void)getFileRecordSuccessfullyWithData: (id)data;

- (void)failedToUpdateTokenWithError:(id)error;
- (void)updateTokenSuccessfully;

@end

@interface WebServiceUtil : NSObject

+(WebServiceUtil *)getInstance;
@property (nonatomic, weak) id<WebServiceUtilDelegate> delegate;

- (void)callWebServiceWithFunction: (NSString *)function withParams: (NSString *)params inBackgroundMode: (BOOL)isBackgroundMode;

@end

NS_ASSUME_NONNULL_END

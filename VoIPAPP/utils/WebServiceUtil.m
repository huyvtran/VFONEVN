//
//  WebServiceUtil.m
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "WebServiceUtil.h"
#import "JSONKit.h"

@implementation WebServiceUtil
@synthesize delegate;

+(WebServiceUtil *)getInstance{
    static WebServiceUtil *webServiceUtil = nil;
    if(webServiceUtil == nil){
        webServiceUtil = [[WebServiceUtil alloc] init];
//        webServiceUtil.webService = [[WebServices alloc] init];
//        webServiceUtil.webService.delegate = webServiceUtil;
    }
    return webServiceUtil;
}

- (void)callWebServiceWithFunction: (NSString *)function withParams: (NSString *)params inBackgroundMode: (BOOL)isBackgroundMode
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@?%@", link_api, function, params];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval: 60];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"hash"];
    [request setValue:[AppDelegate sharedInstance].randomKey forHTTPHeaderField:@"key"];
    [request setValue:[AppDelegate sharedInstance].hashStr forHTTPHeaderField:@"hash"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         // whatever you do on the connectionDidFinishLoading
         // delegate can be moved here
         if (error != nil) {
             // [self.delegate failedToCallWebService:linkService andError:@""];
         }else{
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             int responseCode = (int)[httpResponse statusCode];
             if (responseCode == 200) {
                 if ([function isEqualToString: get_file_record])
                 {
                     NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     if (data == nil || [[value lowercaseString] containsString:@"file not found"]) {
                         if ([delegate respondsToSelector:@selector(failedToGetFileRecordWithError:)]) {
                             [delegate failedToGetFileRecordWithError:@"File ghi âm không tồn tại!"];
                         }
                     }else{
                         if ([delegate respondsToSelector:@selector(getFileRecordSuccessfullyWithData:)]) {
                             [delegate getFileRecordSuccessfullyWithData: data];
                         }
                     }
                 }else{
                     NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     id object = [value objectFromJSONString];
                     if ([object isKindOfClass:[NSDictionary class]]) {
                         id result = [object objectForKey:@"success"];
                         if (![result isKindOfClass:[NSNull class]] && result != nil)
                         {
                             if ([result boolValue] == NO || [result intValue] == 0) {
                                 id data = [object objectForKey:@"data"];
                                 [self failedToCallWebService:function error:data];
                                 
                             }else {
                                 id data = [object objectForKey:@"data"];
                                 if ([data isKindOfClass:[NSDictionary class]]) {
                                     [self successfulToCallWebService:function data:data];
                                 }else{
                                     if (data == nil && [object isKindOfClass:[NSDictionary class]]) {
                                         [self successfulToCallWebService:function data: object];
                                     }else{
                                         [self successfulToCallWebService:function data:data];
                                     }
                                 }
                             }
                         }else{
                             // [self.delegate failedToCallWebService:linkService andError:result];
                         }
                     }
                 }
             }else{
                 NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 id object = [value objectFromJSONString];
                 if (object != nil && [object isKindOfClass:[NSDictionary class]]) {
                     id data = [object objectForKey:@"data"];
                     if (data != nil) {
                         [self failedToCallWebService:function error:data];
                     }else{
                         [self failedToCallWebService:function error:@"Lỗi không xác định"];
                     }
                 }else{
                     [self failedToCallWebService:function error:@"Lỗi không xác định"];
                 }
             }
         }
     }];
}

- (void)successfulToCallWebService: (NSString *)function data: (id)data {
    if ([function isEqualToString: login_func]) {
        if ([delegate respondsToSelector:@selector(signInSuccessfullyWithData:)]) {
            [delegate signInSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: decryptRSA_func]) {
        if ([delegate respondsToSelector:@selector(decryptRSAAccountSuccessfullyWithData:)]) {
            [delegate decryptRSAAccountSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: get_didlist_func]) {
        if ([delegate respondsToSelector:@selector(getDIDListSuccessfullyWithData:)]) {
            [delegate getDIDListSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: get_contacts_func]){
        if ([delegate respondsToSelector:@selector(getContactsSuccessfullyWithData:)]) {
            [delegate getContactsSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: GetServerGroup]) {
        if ([delegate respondsToSelector:@selector(getServerGroupsSuccessfullyWithData:)]) {
            [delegate getServerGroupsSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: get_list_record_file]){
        if ([delegate respondsToSelector:@selector(getListRecordFilesSuccessfullyWithData:)]) {
            [delegate getListRecordFilesSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: get_file_record]){
        if ([delegate respondsToSelector:@selector(getFileRecordSuccessfullyWithData:)]) {
            [delegate getFileRecordSuccessfullyWithData: data];
        }
    }else if ([function isEqualToString: update_token_func]) {
        if ([delegate respondsToSelector:@selector(updateTokenSuccessfully)]) {
            [delegate updateTokenSuccessfully];
        }
    }
}

- (void)failedToCallWebService: (NSString *)function error: (id)error {
    if ([function isEqualToString: login_func]) {
        if ([delegate respondsToSelector:@selector(failedToSignInWithError:)]) {
            [delegate failedToSignInWithError: error];
        }
    }else if ([function isEqualToString: decryptRSA_func]) {
        if ([delegate respondsToSelector:@selector(failedToDecryptRSAAccountWithError:)]) {
            [delegate failedToDecryptRSAAccountWithError: error];
        }
    }else if ([function isEqualToString: get_didlist_func]) {
        if ([delegate respondsToSelector:@selector(failedToGetDIDListWithError:)]) {
            [delegate failedToGetDIDListWithError: error];
        }
    }else if ([function isEqualToString: get_contacts_func]){
        if ([delegate respondsToSelector:@selector(failedToGetContactsWithError:)]) {
            [delegate failedToGetContactsWithError: error];
        }
    }else if ([function isEqualToString: GetServerGroup]) {
        if ([delegate respondsToSelector:@selector(failedToGetServerGroupsWithError:)]) {
            [delegate failedToGetServerGroupsWithError: error];
        }
    }else if ([function isEqualToString: get_list_record_file]){
        if ([delegate respondsToSelector:@selector(failedToGetListRecordFilesWithError:)]) {
            [delegate failedToGetListRecordFilesWithError: error];
        }
    }else if ([function isEqualToString: get_file_record]){
        if ([delegate respondsToSelector:@selector(failedToGetFileRecordWithError:)]) {
            [delegate failedToGetFileRecordWithError: error];
        }
    }else if ([function isEqualToString: update_token_func]) {
        if ([delegate respondsToSelector:@selector(failedToUpdateTokenWithError:)]) {
            [delegate failedToUpdateTokenWithError: error];
        }
    }
}

@end

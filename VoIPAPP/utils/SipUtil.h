//
//  SipUtil.h
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SipUtil : NSObject

+ (void)startSipUtil;
+ (BOOL)makeCallToPhoneNumber: (NSString *)phoneNumber prefix: (NSString *)prefix displayName: (NSString *)displayName;
+ (NSString *)makeValidPhoneNumber: (NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END

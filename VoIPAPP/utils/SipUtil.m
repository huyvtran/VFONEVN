//
//  SipUtil.m
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "SipUtil.h"
#import "AppDelegate.h"

AppDelegate *sipUtilAppDel;

@implementation SipUtil

+ (void)startSipUtil {
    sipUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (BOOL)makeCallToPhoneNumber: (NSString *)phoneNumber prefix: (NSString *)prefix displayName: (NSString *)displayName
{
    AccountState state = [sipUtilAppDel checkSipStateOfAccount];
    if (state == eAccountNone) {
        [sipUtilAppDel.window makeToast:pls_sign_in_to_make_call duration:3.0 position:CSToastPositionCenter style:sipUtilAppDel.errorStyle];
        return FALSE;
    }
    
    //  [Khai Le - 27/12/2018]
    phoneNumber = [self makeValidPhoneNumber: phoneNumber];
    
    if (phoneNumber != nil && phoneNumber.length > 0)
    {
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [sipUtilAppDel.window makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter style:sipUtilAppDel.warningStyle];
            return FALSE;
        }
        
        NSString *sipNumber = [sipUtilAppDel getSipNumberOfAccount];
        if (![AppUtil isNullOrEmpty: sipNumber] && [phoneNumber isEqualToString: sipNumber]) {
            [sipUtilAppDel.window makeToast:cant_make_call_yourself duration:2.0 position:CSToastPositionCenter style:sipUtilAppDel.warningStyle];
            return FALSE;
        }
        
        if ([AppUtil isNullOrEmpty: SIP_DOMAIN] || [AppUtil isNullOrEmpty: SIP_PORT]) {
            [sipUtilAppDel.window makeToast:can_not_make_call_at_this_time duration:2.0 position:CSToastPositionCenter style:sipUtilAppDel.warningStyle];
            return FALSE;
        }
        //        NSString *stringForCall = SFM(@"sip:%@@%@:%@", phoneNumber, domain, port);
        //        [sipUtilAppDel makeCallTo: stringForCall];
        //        if ([DeviceUtil isConnectedEarPhone]) {
        //            [DeviceUtil tryToConnectToEarphone];
        //        }else{
        //            [DeviceUtil enableSpeakerForCall: FALSE];
        //        }
        [sipUtilAppDel showCallViewWithDirection:OutgoingCall remote:phoneNumber prefix:prefix displayName:displayName];
        
        return TRUE;
    }else{
        [sipUtilAppDel.window makeToast:phone_number_can_not_empty duration:2.0 position:CSToastPositionCenter style:sipUtilAppDel.warningStyle];
        return FALSE;
    }
}

+ (NSString *)makeValidPhoneNumber: (NSString *)phoneNumber {
    if ([phoneNumber hasPrefix:@"+84"]) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    if ([phoneNumber hasPrefix:@"84"]) {
        phoneNumber = [phoneNumber substringFromIndex:2];
        phoneNumber = [NSString stringWithFormat:@"0%@", phoneNumber];
    }
    phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
    return phoneNumber;
}

@end

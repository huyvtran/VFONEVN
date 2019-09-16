//
//  DeviceUtil.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    eReceiver = 1,
    eSpeaker,
    eEarphone,
}TypeOutputRoute;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUtil : NSObject

+ (void)startDeviceUtil;
+ (NSString *)getModelsOfCurrentDevice;
+ (BOOL)isAvailableVideo;
+ (float)getSizeOfKeypadButtonForDevice;
+ (float)getSpaceYBetweenKeypadButtonsForDevice;
+ (float)getSpaceXBetweenKeypadButtonsForDevice;
+ (UIEdgeInsets)getEdgeOfVideoCallDialerForDevice;
+ (float)getHeightSearchViewContactForDevice;
+ (float)getHeightAvatarSearchViewForDevice;
+ (float)getWidthPoupSearchViewForDevice;
+ (BOOL)checkNetworkAvailable;
+ (BOOL)isConnectedEarPhone;
+ (BOOL)tryToEnableSpeakerWithEarphone;
+ (BOOL)tryToConnectToEarphone;
+ (TypeOutputRoute)getCurrentRouteForCall;
+ (BOOL)enableSpeakerForCall: (BOOL)speaker;
+ (NSArray *)bluetoothRoutes;
+ (void)cleanLogFolder;
+ (NSString *)convertLogFileName: (NSString *)fileName;
+ (NSString *)deviceModelIdentifier;


+ (void)setupAllFontForApp;

@end

NS_ASSUME_NONNULL_END

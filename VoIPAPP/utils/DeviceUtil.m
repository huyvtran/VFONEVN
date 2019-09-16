//
//  DeviceUtil.m
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "DeviceUtil.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

AppDelegate *deviceUtilAppDel;

@implementation DeviceUtil

+ (void)startDeviceUtil {
    deviceUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//  https://www.theiphonewiki.com/wiki/Models
+ (NSString *)getModelsOfCurrentDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelType =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return modelType;
}

+ (BOOL)isAvailableVideo
{
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        return YES;
    }
}

+ (void)setupAllFontForApp {
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        deviceUtilAppDel.fontLargeBold = [UIFont fontWithName:HelveticaNeueBold size:17.0];
        deviceUtilAppDel.fontLargeMedium = [UIFont fontWithName:HelveticaNeueConBold size:17.0];
        deviceUtilAppDel.fontLargeRegular = [UIFont fontWithName:HelveticaNeue size:17.0];
        deviceUtilAppDel.fontLargeDesc = [UIFont fontWithName:HelveticaNeue size:17.0];
        
        deviceUtilAppDel.fontNormalBold = [UIFont fontWithName:HelveticaNeueBold size:15.0];
        deviceUtilAppDel.fontNormalMedium = [UIFont fontWithName:HelveticaNeueConBold size:15.0];
        deviceUtilAppDel.fontNormalRegular = [UIFont fontWithName:HelveticaNeue size:15.0];
        deviceUtilAppDel.fontNormalDesc = [UIFont fontWithName:HelveticaNeue size:15.0];
        
        deviceUtilAppDel.fontSmallBold = [UIFont fontWithName:HelveticaNeueBold size:13.0];
        deviceUtilAppDel.fontSmallMedium = [UIFont fontWithName:HelveticaNeueConBold size:13.0];
        deviceUtilAppDel.fontSmallRegular = [UIFont fontWithName:HelveticaNeue size:13.0];
        deviceUtilAppDel.fontSmallDesc = [UIFont fontWithName:HelveticaNeue size:13.0];
        
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        //  Screen width: 375.000000 - Screen height: 667.000000
        deviceUtilAppDel.fontLargeBold = [UIFont fontWithName:HelveticaNeueBold size:20.0];
        deviceUtilAppDel.fontLargeMedium = [UIFont fontWithName:HelveticaNeueConBold size:20.0];
        deviceUtilAppDel.fontLargeRegular = [UIFont fontWithName:HelveticaNeue size:20.0];
        deviceUtilAppDel.fontLargeDesc = [UIFont fontWithName:HelveticaNeue size:20.0];
        
        deviceUtilAppDel.fontNormalBold = [UIFont fontWithName:HelveticaNeueBold size:18.0];
        deviceUtilAppDel.fontNormalMedium = [UIFont fontWithName:HelveticaNeueConBold size:18.0];
        deviceUtilAppDel.fontNormalRegular = [UIFont fontWithName:HelveticaNeue size:18.0];
        deviceUtilAppDel.fontNormalDesc = [UIFont fontWithName:HelveticaNeue size:18.0];
        
        deviceUtilAppDel.fontSmallBold = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        deviceUtilAppDel.fontSmallMedium = [UIFont fontWithName:HelveticaNeueConBold size:16.0];
        deviceUtilAppDel.fontSmallRegular = [UIFont fontWithName:HelveticaNeue size:16.0];
        deviceUtilAppDel.fontSmallDesc = [UIFont fontWithName:HelveticaNeue size:16.0];
        
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: simulator])
    {
        
        deviceUtilAppDel.fontLargeBold = [UIFont fontWithName:HelveticaNeueBold size:21.0];
        deviceUtilAppDel.fontLargeMedium = [UIFont fontWithName:HelveticaNeueConBold size:21.0];
        deviceUtilAppDel.fontLargeRegular = [UIFont fontWithName:HelveticaNeue size:21.0];
        deviceUtilAppDel.fontLargeDesc = [UIFont fontWithName:HelveticaNeue size:21.0];
        
        deviceUtilAppDel.fontNormalBold = [UIFont fontWithName:HelveticaNeueBold size:19.0];
        deviceUtilAppDel.fontNormalMedium = [UIFont fontWithName:HelveticaNeueConBold size:19.0];
        deviceUtilAppDel.fontNormalRegular = [UIFont fontWithName:HelveticaNeue size:19.0];
        deviceUtilAppDel.fontNormalDesc = [UIFont fontWithName:HelveticaNeue size:19.0];
        
        deviceUtilAppDel.fontSmallBold = [UIFont fontWithName:HelveticaNeueBold size:17.0];
        deviceUtilAppDel.fontSmallMedium = [UIFont fontWithName:HelveticaNeueConBold size:17.0];
        deviceUtilAppDel.fontSmallRegular = [UIFont fontWithName:HelveticaNeue size:17.0];
        deviceUtilAppDel.fontSmallDesc = [UIFont fontWithName:HelveticaNeue size:17.0];
        
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        deviceUtilAppDel.fontLargeBold = [UIFont fontWithName:HelveticaNeueBold size:21.0];
        deviceUtilAppDel.fontLargeMedium = [UIFont fontWithName:HelveticaNeueConBold size:21.0];
        deviceUtilAppDel.fontLargeRegular = [UIFont fontWithName:HelveticaNeue size:21.0];
        deviceUtilAppDel.fontLargeDesc = [UIFont fontWithName:HelveticaNeue size:21.0];
        
        deviceUtilAppDel.fontNormalBold = [UIFont fontWithName:HelveticaNeueBold size:19.0];
        deviceUtilAppDel.fontNormalMedium = [UIFont fontWithName:HelveticaNeueConBold size:19.0];
        deviceUtilAppDel.fontNormalRegular = [UIFont fontWithName:HelveticaNeue size:19.0];
        deviceUtilAppDel.fontNormalDesc = [UIFont fontWithName:HelveticaNeue size:19.0];
        
        deviceUtilAppDel.fontSmallBold = [UIFont fontWithName:HelveticaNeueBold size:17.0];
        deviceUtilAppDel.fontSmallMedium = [UIFont fontWithName:HelveticaNeueConBold size:17.0];
        deviceUtilAppDel.fontSmallRegular = [UIFont fontWithName:HelveticaNeue size:17.0];
        deviceUtilAppDel.fontSmallDesc = [UIFont fontWithName:HelveticaNeue size:17.0];
        
    }else{
        //  Screen width: 375.000000 - Screen height: 812.000000
        deviceUtilAppDel.fontLargeBold = [UIFont fontWithName:HelveticaNeueBold size:21.0];
        deviceUtilAppDel.fontLargeMedium = [UIFont fontWithName:HelveticaNeueConBold size:21.0];
        deviceUtilAppDel.fontLargeRegular = [UIFont fontWithName:HelveticaNeue size:21.0];
        deviceUtilAppDel.fontLargeDesc = [UIFont fontWithName:HelveticaNeue size:21.0];
        
        deviceUtilAppDel.fontNormalBold = [UIFont fontWithName:HelveticaNeueBold size:19.0];
        deviceUtilAppDel.fontNormalMedium = [UIFont fontWithName:HelveticaNeueConBold size:19.0];
        deviceUtilAppDel.fontNormalRegular = [UIFont fontWithName:HelveticaNeue size:19.0];
        deviceUtilAppDel.fontNormalDesc = [UIFont fontWithName:HelveticaNeue size:19.0];
        
        deviceUtilAppDel.fontSmallBold = [UIFont fontWithName:HelveticaNeueBold size:17.0];
        deviceUtilAppDel.fontSmallMedium = [UIFont fontWithName:HelveticaNeueConBold size:17.0];
        deviceUtilAppDel.fontSmallRegular = [UIFont fontWithName:HelveticaNeue size:17.0];
        deviceUtilAppDel.fontSmallDesc = [UIFont fontWithName:HelveticaNeue size:17.0];
    }
}

//  [Khai le - 28/10/2018]
+ (float)getSizeOfKeypadButtonForDevice {
    if (!IS_IPOD && !IS_IPHONE) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            return 75.0;
        }
        return 85.0;
    }
    
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        //  Screen width: 320.000000 - Screen height: 667.000000
        return 62.0;
        
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        //  Screen width: 375.000000 - Screen height: 667.000000
        return 70.0;
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: simulator])
    {
        //  Screen width: 414.000000 - Screen height: 736.000000
        return 77.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2]){
        //  Screen width: 375.000000 - Screen height: 812.000000
        return 80.0;
    }else{
        return 62.0;
    }
}

+ (float)getSpaceYBetweenKeypadButtonsForDevice {
    if (!IS_IPOD && !IS_IPHONE) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            return 15.0;
        }
        return 40.0;
    }
    
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 9.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        return 17.0;
    }else{
        return 15.0;
    }
}

+ (float)getSpaceXBetweenKeypadButtonsForDevice
{
    if (!IS_IPOD && !IS_IPHONE) {
        return 50.0;
    }
    
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 20.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        return 30.0;
    }else{
        return 28.0;
    }
}

+ (UIEdgeInsets)getEdgeOfVideoCallDialerForDevice
{
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return UIEdgeInsetsMake(7, 7, 7, 7);
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2]){
        return UIEdgeInsetsMake(7, 7, 7, 7);
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }else{
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
}

+ (float)getHeightSearchViewContactForDevice {
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 45.0;
        
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        return 50.0;
    }else{
        //  Screen width: 414.000000 - Screen height: 736.000000
        return 60.0;
    }
}

+ (float)getHeightAvatarSearchViewForDevice {
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 35.0;
        
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        return 40.0;
    }else{
        //  Screen width: 414.000000 - Screen height: 736.000000
        return 45.0;
    }
}

+ (float)getWidthPoupSearchViewForDevice {
    NSString *deviceMode = [self getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 260.0;
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2]){
        return 280.0;
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
    {
        return 300.0;
    }
    else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        return 300.0;
    }else{
        return 300.0;
    }
}

+ (BOOL)checkNetworkAvailable {
    NetworkStatus internetStatus = [deviceUtilAppDel.internetReachable currentReachabilityStatus];
    if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}

+ (BOOL)isConnectedEarPhone {
    NSArray *bluetoothPorts = @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
    
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([bluetoothPorts containsObject:route.portType]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)tryToEnableSpeakerWithEarphone {
    NSError *err;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    if (err) {
        return FALSE;
    }
    return TRUE;
}

+ (BOOL)tryToConnectToEarphone {
    NSError *err;
    AVAudioSessionPortDescription *_bluetoothPort = [self bluetoothAudioDevice];
    [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort error:&err];
    // if setting bluetooth failed, it must be because the device is not available
    // anymore (disconnected), so deactivate bluetooth.
    if (err) {
        return FALSE;
    } else {
        return TRUE;
    }
}

+ (AVAudioSessionPortDescription *)bluetoothAudioDevice {
    return [self audioDeviceFromTypes:[self bluetoothRoutes]];
}

+ (AVAudioSessionPortDescription *)audioDeviceFromTypes:(NSArray *)types {
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([types containsObject:route.portType]) {
            return route;
        }
    }
    return nil;
}

+ (NSArray *)bluetoothRoutes {
    return @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
}

//  check current route used bluetooth
+ (TypeOutputRoute)getCurrentRouteForCall {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *outputs = currentRoute.outputs;
    for (AVAudioSessionPortDescription *route in outputs) {
        if (route.portType == AVAudioSessionPortBuiltInReceiver) {
            return eReceiver;
            
        }else if (route.portType == AVAudioSessionPortBuiltInSpeaker || [[route.portType lowercaseString] containsString:@"speaker"]) {
            return eSpeaker;
            
        }else if (route.portType == AVAudioSessionPortBluetoothHFP || route.portType == AVAudioSessionPortBluetoothLE || route.portType == AVAudioSessionPortBluetoothA2DP || [[route.portType lowercaseString] containsString:@"bluetooth"]) {
            return eEarphone;
        }
    }
    return eReceiver;
}

+ (BOOL)enableSpeakerForCall: (BOOL)speaker {
    BOOL success;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    if (speaker) {
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                 error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session setActive:YES error:&error];
        if (!success){
            return FALSE;
        }
    }else{
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                 error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session setActive:YES error:&error];
        if (!success){
            return FALSE;
        }
    }
    return success;
}

+ (void)cleanLogFolder {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *arr = [WriteLogsUtil getAllFilesInDirectory: logsFolderName];
    for (int i=0; i<arr.count; i++) {
        NSString *fileName = [arr objectAtIndex: i];
        if ([fileName hasPrefix: bundleIdentifier]) {
            NSString *path = [WriteLogsUtil getPathOfFileWithSubDir:SFM(@"%@/%@", logsFolderName, fileName)];
            [WriteLogsUtil removeFileWithPath: path];
        }
    }
}

+ (NSString *)convertLogFileName: (NSString *)fileName {
    if ([fileName hasPrefix:@"."]) {
        fileName = [fileName substringFromIndex: 1];
    }
    if ([fileName hasSuffix:@".txt"]) {
        fileName = [fileName substringToIndex:(fileName.length - 4)];
    }
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    return SFM(@"Log_file_%@", fileName);
}

+ (NSString *)deviceModelIdentifier {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([machine isEqual:@"iPad1,1"])
        return @"iPad";
    else if ([machine isEqual:@"iPad2,1"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,2"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,3"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad2,4"])
        return @"iPad 2";
    else if ([machine isEqual:@"iPad3,1"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,2"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,3"])
        return @"iPad 3";
    else if ([machine isEqual:@"iPad3,4"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad3,5"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad3,6"])
        return @"iPad 4";
    else if ([machine isEqual:@"iPad4,1"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad4,2"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad4,3"])
        return @"iPad Air";
    else if ([machine isEqual:@"iPad5,3"])
        return @"iPad Air 2";
    else if ([machine isEqual:@"iPad5,4"])
        return @"iPad Air 2";
    else if ([machine isEqual:@"iPad6,7"])
        return @"iPad Pro 12.9";
    else if ([machine isEqual:@"iPad6,8"])
        return @"iPad Pro 12.9";
    else if ([machine isEqual:@"iPad6,3"])
        return @"iPad Pro 9.7";
    else if ([machine isEqual:@"iPad6,4"])
        return @"iPad Pro 9.7";
    else if ([machine isEqual:@"iPad2,5"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad2,6"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad2,7"])
        return @"iPad mini";
    else if ([machine isEqual:@"iPad4,4"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,5"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,6"])
        return @"iPad mini 2";
    else if ([machine isEqual:@"iPad4,7"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad4,8"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad4,9"])
        return @"iPad mini 3";
    else if ([machine isEqual:@"iPad5,1"])
        return @"iPad mini 4";
    else if ([machine isEqual:@"iPad5,2"])
        return @"iPad mini 4";
    
    else if ([machine isEqual:@"iPhone1,1"])
        return @"iPhone";
    else if ([machine isEqual:@"iPhone1,2"])
        return @"iPhone 3G";
    else if ([machine isEqual:@"iPhone2,1"])
        return @"iPhone 3GS";
    else if ([machine isEqual:@"iPhone3,1"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone3,2"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone3,3"])
        return @"iPhone 4";
    else if ([machine isEqual:@"iPhone4,1"])
        return @"iPhone 4S";
    else if ([machine isEqual:@"iPhone5,1"])
        return @"iPhone5,2    iPhone 5";
    else if ([machine isEqual:@"iPhone5,3"])
        return @"iPhone5,4    iPhone 5c";
    else if ([machine isEqual:@"iPhone6,1"])
        return @"iPhone6,2    iPhone 5s";
    else if ([machine isEqual:@"iPhone7,2"])
        return @"iPhone 6";
    else if ([machine isEqual:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    else if ([machine isEqual:@"iPhone8,1"])
        return @"iPhone 6s";
    else if ([machine isEqual:@"iPhone8,2"])
        return @"iPhone 6s Plus";
    else if ([machine isEqual:@"iPhone8,4"])
        return @"iPhone SE";
    
    else if ([machine isEqual:@"iPod1,1"])
        return @"iPod touch";
    else if ([machine isEqual:@"iPod2,1"])
        return @"iPod touch 2G";
    else if ([machine isEqual:@"iPod3,1"])
        return @"iPod touch 3G";
    else if ([machine isEqual:@"iPod4,1"])
        return @"iPod touch 4G";
    else if ([machine isEqual:@"iPod5,1"])
        return @"iPod touch 5G";
    else if ([machine isEqual:@"iPod7,1"])
        return @"iPod touch 6G";
    
    else if ([machine isEqual:@"x86_64"])
        return @"simulator 64bits";
    
    // none matched: cf https://www.theiphonewiki.com/wiki/Models for the whole list
    return machine;
}

@end

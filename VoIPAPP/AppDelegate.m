//
//  AppDelegate.m
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "AppDelegate.h"
#import "SignInViewController.h"
#import "AppTabbarViewController.h"
#import "WebServiceUtil.h"
#import "PBXContact.h"
#import "PhoneObject.h"
#import "ContactObject.h"
#import "ContactDetailObj.h"
#import <Intents/Intents.h>
#include <Intents/INInteraction.h>

//  FOR PJSIP
#include "pjsip_sources/pjlib/include/pjlib.h"
#include "pjsip_sources/pjsip/include/pjsua.h"
#include "pjsip_sources/pjsua/pjsua_app.h"
#include "pjsip_sources/pjsua/pjsua_app_config.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define MAX_MEDIA_CNT 2 /* Media count, set to 1 for audio, only or 2 for audio and video */
#define AF pj_AF_INET() /* Change to pj_AF_INET6() for IPv6.    * PJ_HAS_IPV6 must be enabled and   * your system must support IPv6. */
//  #define SIP_PORT 5060 /* Listening SIP port */
#define RTP_PORT 4000 /* RTP port */

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize databasePath, dbQueue, database;
@synthesize internetActive, internetReachable, hostReachable;
@synthesize logFilePath, hStatus, hNav, randomKey, hashStr;
@synthesize errorStyle, warningStyle, successStyle;
@synthesize fontLargeBold, fontLargeMedium, fontLargeRegular, fontNormalBold, fontNormalMedium, fontNormalRegular, fontDescBold, fontDescMedium, fontDescNormal, fontSmallBold, fontSmallMedium, fontSmallRegular, fontSmallDesc;
@synthesize contactLoaded, phoneForCall, callPrefix, listNumber, callViewController, listContacts, pbxContacts, listInfoPhoneNumber, listGroup, isSyncing, deviceToken, updateTokenSuccess;
@synthesize current_call_id, beepPlayer, ringbackPlayer, remoteNumber, del, voipRegistry, pjsipConfAudioId;

AppDelegate      *app;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //  setup for Fabric
    [Fabric with:@[[Crashlytics class]]];
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    //  start Utils
    [WriteLogsUtil startWriteLogsUtil];
    [DatabaseUtil startDatabaseUtil];
    [ContactsUtil startContactsUtil];
    [AppUtil startAppUtil];
    [SipUtil startSipUtil];
    [DeviceUtil startDeviceUtil];
    
    //  [Khai le - 25/10/2018]: Add write logs for app
    [self setupForWriteLogFileForApp];
    
    NSString *subDirectory = SFM(@"%@/%@.txt", logsFolderName, [AppUtil getCurrentDate]);
    logFilePath = [WriteLogsUtil makeFilePathWithFileName: subDirectory];
    
    if (IS_IPHONE || IS_IPOD) {
        [WriteLogsUtil writeLogContent:SFM(@"==================================================\nSTART APPLICATION ON IPHONE              \n==================================================")];
    }else{
        [WriteLogsUtil writeLogContent:SFM(@"==================================================\nSTART APPLICATION ON IPAD              \n==================================================")];
    }
    
    NSString *str = SFM(@"%@: %@\n%@: %@", text_version, [AppUtil getAppVersionWithBuildVersion: YES], text_release_date, [AppUtil getBuildDate]);
    [WriteLogsUtil writeLogContent:SFM(@"\nApp's version is %@", str)];
    
    hStatus = application.statusBarFrame.size.height;
    randomKey = [AppUtil randomStringWithLength: 10];
    if (![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD]) {
        NSString *total = SFM(@"%@%@%@", PASSWORD, randomKey, USERNAME);
        hashStr = [AppUtil getMD5StringOfString: total];
    }
    
    callPrefix = @"";
    listNumber = [[NSArray alloc] initWithObjects: @"+", @"#", @"*", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    listInfoPhoneNumber = [[NSMutableArray alloc] init];
    isSyncing = FALSE;
    contactLoaded = FALSE;
    
    [DeviceUtil setupAllFontForApp];
    
    // check if a pathway to a random host exists
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReachable startNotifier];
    
    [self setupMessageStyleForApp];
    
    //  setup DND mode
    NSString *dndMode = [[NSUserDefaults standardUserDefaults] objectForKey:switch_dnd];
    if ([AppUtil isNullOrEmpty: dndMode]) {
        [AppUtil enableDoNotDisturbMode: FALSE];
    }
    
    //  save value for pbx contacts sort
    [AppUtil setupFirstValueForSortContact];
    
    //  get pbx group contact list
    [self getPBXGroupContactList];
    
    // Copy database and connect
    [self copyFileDataToDocument:@"database.sqlite"];
    [DatabaseUtil connectToDatabase];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
        UNUserNotificationCenter *notifiCenter = [UNUserNotificationCenter currentNotificationCenter];
        notifiCenter.delegate = self;
        [notifiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                contactLoaded = NO;
                [self fetchAllContactsFromPhoneBook];
            } else {
                NSLog(@"User denied access");
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                contactLoaded = NO;
                [self fetchAllContactsFromPhoneBook];
            } else {
                NSLog(@"User denied access");
            }
        });
    }
    
    //  Enable all notification type. VoIP Notifications don't present a UI but we will use this to show local nofications later
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert| UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        self.del = [[ProviderDelegate alloc] init];
        [self.del config];
    }
    [self registerForNotifications:[UIApplication sharedApplication]];
    
    if (![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD] && ![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT])
    {
        AppTabbarViewController *tabbarVC = [[AppTabbarViewController alloc] init];
        [self.window setRootViewController:tabbarVC];
        [self.window makeKeyAndVisible];
        
    }else{
        SignInViewController *signInVC = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        UINavigationController *signInNav = [[UINavigationController alloc] initWithRootViewController:signInVC];
        
        [self.window setRootViewController:signInNav];
        [self.window makeKeyAndVisible];
    }
    
    app = self;
    current_call_id = -1;
    //  [self startPjsuaForApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    int num_call = pjsua_call_get_count();
    if (num_call == 0) {
        [self deleteSIPAccountDefault];
        pjsua_destroy();
    }
    
    if (![AppUtil isNullOrEmpty: USERNAME]) {
        int missedCall = [DatabaseUtil getUnreadMissedCallHisotryWithAccount: USERNAME];
        application.applicationIconBadgeNumber = missedCall;
    }else{
        application.applicationIconBadgeNumber = 0;
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    int num_call = pjsua_call_get_count();
    if (num_call == 0) {
        [self refreshSIPRegistration];
        
        AccountState accState = [self checkSipStateOfAccount];
        //  kiếm tra có phải từ phone call history mở lên không
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:UserActivity];
        if (![AppUtil isNullOrEmpty: phoneNumber])
        {
            if (accState == eAccountNone) {
                //  Nếu chưa đăng nhập, mà có thông tin đăng nhập thì đăng nhập rồi gọi
                NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:key_domain];
                NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:key_port];
                if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: port])
                {
                    
                }else{
                    //  reset value
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivity];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivityName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self.window makeToast:@"Không thể gọi lúc này. Có lẽ bạn chưa đăng nhập tài khoản!" duration:3.0 position:CSToastPositionCenter];
                }
            }
            else if (accState == eAccountOn) {
                NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey:UserActivityName];
                //  Nếu SIP registration đang sẵn sàng thì gọi
                phoneForCall = phoneNumber;
                [self getDIDListForCall];
            }
            else{
                //  Chờ đăng ký SIP xong sẽ gọi
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    //  when user click facetime video
    if ([userActivity.activityType isEqualToString:@"INStartVideoCallIntent"]) {
        return TRUE;
    }
    
    INInteraction *interaction = userActivity.interaction;
    if (interaction != nil) {
        INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
        if (startAudioCallIntent != nil && startAudioCallIntent.contacts.count > 0) {
            INPerson *contact = startAudioCallIntent.contacts[0];
            if (contact != nil) {
                INPersonHandle *personHandle = contact.personHandle;
                NSString *content = personHandle.value;
                if (![AppUtil isNullOrEmpty: content])
                {
                    NSArray *arr = [content componentsSeparatedByString:@"|||"];
                    NSString *callerName = @"";
                    NSString *phoneNumber = @"";
                    
                    if (arr.count == 2) {
                        callerName = [arr objectAtIndex: 0];
                        phoneNumber = [arr objectAtIndex: 1];
                        
                    }else if (arr.count == 1) {
                        phoneNumber = [arr objectAtIndex: 0];
                    }
                    
                    if (![AppUtil isNullOrEmpty: phoneNumber]) {
                        if (callerName == nil) {
                            callerName = @"";
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:UserActivity];
                        [[NSUserDefaults standardUserDefaults] setObject:callerName forKey:UserActivityName];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
        }
    }
    return YES;
}

+(AppDelegate *)sharedInstance{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable: {
            internetActive = FALSE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
        case ReachableViaWiFi: {
            internetActive = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
        case ReachableViaWWAN: {
            internetActive = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
    }
}

// copy database
- (void)copyFileDataToDocument : (NSString *)filename {
    NSArray *arrPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arrPath objectAtIndex:0];
    NSString *pathString = [documentPath stringByAppendingPathComponent:filename];
    databasePath = [[NSString alloc] initWithString: pathString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"] error:NULL];
    
    if (![fileManager fileExistsAtPath:pathString]) {
        NSError *error;
        @try {
            NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
            [fileManager copyItemAtPath:bundlePath toPath:pathString error:&error];
            if (error != nil ) {
                //                @throw [NSException exceptionWithName:@"Error copy file ! " reason:@"Can not copy file to Document" userInfo:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
    }
}

- (void)setupForWriteLogFileForApp
{
    [WriteLogsUtil createDirectory:ringtonesFolder];
    [WriteLogsUtil createDirectory:recordsFolderName];
    
    //  create folder to contain log files
    [WriteLogsUtil createDirectoryAndSubDirectory: logsFolderName];
    
    //  create folder to contain log files
    [WriteLogsUtil createDirectoryAndSubDirectory: recordsFolderName];
}

- (void)setupMessageStyleForApp {
    //  setup message style
    warningStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    warningStyle.backgroundColor = ORANGE_COLOR;
    warningStyle.messageColor = UIColor.whiteColor;
    warningStyle.messageFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    warningStyle.cornerRadius = 20.0;
    warningStyle.messageAlignment = NSTextAlignmentCenter;
    warningStyle.messageNumberOfLines = 5;
    warningStyle.shadowColor = UIColor.blackColor;
    warningStyle.shadowOpacity = 1.0;
    warningStyle.shadowOffset = CGSizeMake(-5, -5);
    
    errorStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    errorStyle.backgroundColor = [UIColor colorWithRed:(211/255.0) green:(55/255.0) blue:(55/255.0) alpha:1.0];
    errorStyle.messageColor = UIColor.whiteColor;
    errorStyle.messageFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    errorStyle.cornerRadius = 20.0;
    errorStyle.messageAlignment = NSTextAlignmentCenter;
    errorStyle.messageNumberOfLines = 5;
    errorStyle.shadowColor = UIColor.blackColor;
    errorStyle.shadowOpacity = 1.0;
    errorStyle.shadowOffset = CGSizeMake(-5, -5);
    
    successStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    successStyle.backgroundColor = BLUE_COLOR;
    successStyle.messageColor = UIColor.whiteColor;
    successStyle.messageFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    successStyle.cornerRadius = 20.0;
    successStyle.messageAlignment = NSTextAlignmentCenter;
    successStyle.messageNumberOfLines = 5;
    successStyle.shadowColor = UIColor.blackColor;
    successStyle.shadowOpacity = 1.0;
    successStyle.shadowOffset = CGSizeMake(-5, -5);
}

- (void)fetchAllContactsFromPhoneBook
{
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    
    if (listContacts == nil) {
        listContacts = [[NSMutableArray alloc] init];
    }
    [listContacts removeAllObjects];
    
    if (pbxContacts == nil) {
        pbxContacts = [[NSMutableArray alloc] init];
    }
    [pbxContacts removeAllObjects];
    
    if (listInfoPhoneNumber == nil) {
        listInfoPhoneNumber = [[NSMutableArray alloc] init];
    }
    [listInfoPhoneNumber removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        ABAddressBookRef addressListBook = ABAddressBookCreate();
        NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
        if (arrayOfAllPeople != nil) {
            [listContacts addObjectsFromArray: arrayOfAllPeople];
        }
        
        [self getAllIDContactInPhoneBook];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            contactLoaded = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:finishLoadContacts object:nil];
        });
    });
}

- (void)getAllIDContactInPhoneBook
{
    if (pbxContacts == nil) {
        pbxContacts = [[NSMutableArray alloc] init];
    }
    [pbxContacts removeAllObjects];
    
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    NSUInteger peopleCounter = 0;
    
    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count]; peopleCounter++)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        int contactId = ABRecordGetRecordID(aPerson);
        
        //  Kiem tra co phai la contact pbx hay ko?
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX])
        {
            NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
            ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phones) > 0)
            {
                NSMutableArray *listPBX = [[NSMutableArray alloc] init];
                
                for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                    
                    NSString *phoneStr = (__bridge NSString *)phoneNumberRef;
                    phoneStr = [[phoneStr componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    
                    NSString *nameStr = (__bridge NSString *)locLabel;
                    
                    if (phoneStr != nil && nameStr != nil) {
                        PBXContact *pbxContact = [[PBXContact alloc] init];
                        pbxContact._name = nameStr;
                        pbxContact._number = phoneStr;
                        
                        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: nameStr];
                        NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
                        pbxContact._nameForSearch = nameForSearch;
                        pbxContact._convertName = convertName;
                        [listPBX addObject: pbxContact];
                        
                        //  get avatar
                        NSString *avatarStr = @"";
                        if (![AppUtil isNullOrEmpty: pbxServer]) {
                            NSString *avatarName = SFM(@"%@_%@.png", pbxServer, phoneStr);
                            NSString *localFile = SFM(@"/avatars/%@", avatarName);
                            NSData *avatarData = [AppUtil getFileDataFromDirectoryWithFileName:localFile];
                            if (avatarData != nil) {
                                avatarStr = [avatarData base64EncodedStringWithOptions: 0];
                            }
                        }
                        //  [Khai le - 02/11/2018]
                        PhoneObject *phone = [[PhoneObject alloc] init];
                        phone.number = phoneStr;
                        phone.name = nameStr;
                        phone.nameForSearch = nameForSearch;
                        phone.avatar = avatarStr;
                        phone.contactId = contactId;
                        phone.phoneType = ePBXPhone;
                        
                        [listInfoPhoneNumber addObject: phone];
                    }
                }
                [pbxContacts removeAllObjects];
                [pbxContacts addObjectsFromArray: listPBX];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:contactId] forKey:PBX_ID_CONTACT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [[NSNotificationCenter defaultCenter] postNotificationName:finishGetPBXContacts object:nil];
            });
            
            continue;
        }
        NSString *fullname = [AppUtil getNameOfContact: aPerson];
        if (![AppUtil isNullOrEmpty: fullname])
        {
            NSMutableArray *listPhone = [self getListPhoneOfContactPerson: aPerson withName: fullname];
            if (listPhone != nil && listPhone.count > 0) {
                NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
                NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
                
                for (int i=0; i<listPhone.count; i++) {
                    ContactDetailObj *phoneItem = [listPhone objectAtIndex: i];
                    
                    PhoneObject *phone = [[PhoneObject alloc] init];
                    phone.number = phoneItem._valueStr;
                    phone.name = fullname;
                    phone.nameForSearch = nameForSearch;
                    phone.avatar = [ContactsUtil getBase64AvatarFromContact: aPerson];
                    phone.contactId = contactId;
                    phone.phoneType = eNormalPhone;
                    
                    [listInfoPhoneNumber addObject: phone];
                }
            }else{
                NSLog(@"This contact don't have any phone number!!!");
            }
        }
    }
}

- (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson withName: (NSString *)contactName
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
                anItem._valueStr = phoneNumber;
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = text_home;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = text_work;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = text_mobile;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = text_fax;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = text_other;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = text_mobile;
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
}

- (void)registerForNotifications:(UIApplication *)app {
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    
    // Initiate registration.
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        // Call category
        UNNotificationAction *act_ans =
        [UNNotificationAction actionWithIdentifier:@"Answer"
                                             title:NSLocalizedString(@"Answer", nil)
                                           options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:@"Decline"
                                                                             title:NSLocalizedString(@"Decline", nil)
                                                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_call =
        [UNNotificationCategory categoryWithIdentifier:@"call_cat"
                                               actions:[NSArray arrayWithObjects:act_ans, act_dec, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Msg category
        UNTextInputNotificationAction *act_reply =
        [UNTextInputNotificationAction actionWithIdentifier:@"Reply"
                                                      title:NSLocalizedString(@"Reply", nil)
                                                    options:UNNotificationActionOptionNone];
        UNNotificationAction *act_seen =
        [UNNotificationAction actionWithIdentifier:@"Seen"
                                             title:NSLocalizedString(@"Mark as seen", nil)
                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_msg =
        [UNNotificationCategory categoryWithIdentifier:@"msg_cat"
                                               actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Video Request Category
        UNNotificationAction *act_accept =
        [UNNotificationAction actionWithIdentifier:@"Accept"
                                             title:NSLocalizedString(@"Accept", nil)
                                           options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *act_refuse = [UNNotificationAction actionWithIdentifier:@"Cancel"
                                                                                title:NSLocalizedString(@"Cancel", nil)
                                                                              options:UNNotificationActionOptionNone];
        UNNotificationCategory *video_call =
        [UNNotificationCategory categoryWithIdentifier:@"video_request"
                                               actions:[NSArray arrayWithObjects:act_accept, act_refuse, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // ZRTP verification category
        UNNotificationAction *act_confirm = [UNNotificationAction actionWithIdentifier:@"Confirm"
                                                                                 title:NSLocalizedString(@"Accept", nil)
                                                                               options:UNNotificationActionOptionNone];
        
        UNNotificationAction *act_deny = [UNNotificationAction actionWithIdentifier:@"Deny"
                                                                              title:NSLocalizedString(@"Deny", nil)
                                                                            options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_zrtp =
        [UNNotificationCategory categoryWithIdentifier:@"zrtp_request"
                                               actions:[NSArray arrayWithObjects:act_confirm, act_deny, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
                                          UNAuthorizationOptionBadge)
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             // Enable or disable features based on authorization.
             if (error) {
                 NSLog(@"%@", error.description);
             }
         }];
        NSSet *categories = [NSSet setWithObjects:cat_call, cat_msg, video_call, cat_zrtp, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    }
}

- (NSMutableArray *)getPBXContactPhone: (int)pbxContactId
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    ABRecordRef aPerson = ABAddressBookGetPersonWithRecordID(addressListBook, pbxContactId);
    
    NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            
            NSString *phoneStr = (__bridge NSString *)phoneNumberRef;
            phoneStr = [[phoneStr componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            
            NSString *nameStr = (__bridge NSString *)locLabel;
            
            if (phoneStr != nil && nameStr != nil) {
                PBXContact *pbxContact = [[PBXContact alloc] init];
                pbxContact._name = nameStr;
                pbxContact._number = phoneStr;
                
                NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: nameStr];
                NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
                pbxContact._nameForSearch = nameForSearch;
        
                [result addObject: pbxContact];
            }
        }
    }
    return result;
}

#pragma mark - PJSIP
- (void)startPjsuaForApp {
    
    pjsua_create();

    pjsua_config ua_cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    
    pjsua_config_default(&ua_cfg);
    pjsua_logging_config_default(&log_cfg);
    pjsua_media_config_default(&media_cfg);
    
    ua_cfg.cb.on_incoming_call = &on_incoming_call;
    ua_cfg.cb.on_call_media_state = &on_call_media_state;
    ua_cfg.cb.on_call_state = &on_call_state;
    ua_cfg.cb.on_reg_state = &on_reg_state;
    ua_cfg.cb.on_reg_started = &on_reg_started;
    ua_cfg.cb.on_call_transfer_status = &on_call_transfer_status;

    pjsua_init(&ua_cfg, &log_cfg, &media_cfg);

    pjsua_transport_config transportConfig;
    pjsua_transport_config_default(&transportConfig);
    transportConfig.port = 65400;

    pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, NULL);
    //  pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transportConfig, NULL);
    //  ua_cfg.use_srtp = PJMEDIA_SRTP_OPTIONAL;
    
    pjsua_start();
}

- (void)refreshSIPAccountRegistrationState {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            pjsua_acc_set_registration(acc_id, 1);
        }
    }
}

- (void)registerSIPAccountWithInfo: (NSDictionary *)info {
    NSString *account = [info objectForKey:@"account"];
    NSString *domain = [info objectForKey:@"domain"];
    NSString *port = [info objectForKey:@"port"];
    NSString *password = [info objectForKey:@"password"];

    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: password])
    {
        pj_status_t status;

        // Register the account on local sip server
        pjsua_acc_id acc_id;
        pjsua_acc_config cfg;
        pjsua_acc_config_default(&cfg);

        NSString *strCall = SFM(@"sip:%@@%@:%@", account, domain, port);
        NSString *regUri = SFM(@"sip:%@:%@", domain, port);

        cfg.id = pj_str((char *)[strCall UTF8String]);
        cfg.reg_uri = pj_str((char *)[regUri UTF8String]);
        cfg.cred_count = 1;
        cfg.cred_info[0].realm = pj_str("*");
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].username = pj_str((char *)[account UTF8String]);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str((char *)[password UTF8String]);
        cfg.ice_cfg_use=PJSUA_ICE_CONFIG_USE_DEFAULT;
        //  cfg.srtp_secure_signaling = 0;
        //  cfg.use_srtp = PJMEDIA_SRTP_OPTIONAL;
        
        //  cfg.use_rfc5626 = 0;
        
        //  disable IPV6
        cfg.ipv6_media_use = PJSUA_IPV6_DISABLED;
        cfg.reg_timeout = 20;
        cfg.reg_retry_interval = 0; //  0 to disable re-retry register

        NSString *strAgent = @"VFONE";
        strAgent = SFM(@"%@_%@_iOS%@", strAgent, [DeviceUtil deviceModelIdentifier], UIDevice.currentDevice.systemVersion);
        pjsip_generic_string_hdr CustomHeader;
        pj_str_t name = pj_str("User-Agent");
        pj_str_t value = pj_str((char *)[strAgent UTF8String]);
        pjsip_generic_string_hdr_init2(&CustomHeader, &name, &value);
        pj_list_push_back(&cfg.reg_hdr_list, &CustomHeader);

        pjsip_endpoint* endpoint = pjsua_get_pjsip_endpt();
        pj_dns_resolver* resolver;

        struct pj_str_t servers[] = {pj_str((char *)[domain UTF8String]) };
        pjsip_endpt_create_resolver(endpoint, &resolver);
        pj_dns_resolver_set_ns(resolver, 1, servers, NULL);

        // Init transport config structure
        pjsua_transport_config trans_cfg;
        pjsua_transport_config_default(&trans_cfg);
        //  trans_cfg.port = 65400;

//        pj_str_t codec_id = pj_str("pcmu/8000/1");
//        pj_str_t codec_id2 = pj_str("pcma");
        pj_str_t codec_id = pj_str("pcma");
        pj_str_t codec_id2 = pj_str("pcmu/8000/1");
        
        status = pjsua_codec_set_priority(&codec_id, 254);
        status = pjsua_codec_set_priority(&codec_id2, 255);
        
        // Add UDP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &trans_cfg, NULL);
        if (status != PJ_SUCCESS){
            NSLog(@"Error creating UDP transport");
        }

        status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
        if (status != PJ_SUCCESS){
            NSLog(@"Error adding account");
        }
    }else{
        [self.window makeToast:pls_check_your_network_connection duration:3.0 position:CSToastPositionCenter style:self.errorStyle];
    }
}

- (void)refreshSIPRegistration
{
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        [self deleteSIPAccountDefault];
        pjsua_destroy();
        [self startPjsuaForApp];
        [self tryToReRegisterToSIP];
    }else{
        if (pjsua_get_state() == PJSUA_STATE_NULL) {
            [self startPjsuaForApp];
        }
        [self tryToReRegisterToSIP];
    }
}

- (void)tryToReRegisterToSIP {
    NSString *account = USERNAME;
    NSString *password = PASSWORD;
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:key_domain];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:key_port];
    
    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: password] && ![AppUtil isNullOrEmpty:domain] && ![AppUtil isNullOrEmpty: port])
    {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:account, @"account", password, @"password", domain, @"domain", port, @"port", nil];
        [self registerSIPAccountWithInfo: info];
    }
}


//  Callback called by the library upon receiving incoming call
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata)
{
    BOOL dndMode = [AppUtil checkDoNotDisturbMode];
    if (dndMode) {
        pjsua_call_hangup(call_id, PJSIP_SC_BUSY_HERE, NULL, NULL);

    }else{
        pjsua_call_info ci;
        PJ_UNUSED_ARG(acc_id);
        PJ_UNUSED_ARG(rdata);

        pjsua_call_get_info(call_id, &ci);

        NSUUID *uuid = [NSUUID UUID];
        NSString *callId = [NSString stringWithFormat:@"%d", call_id];

        [app.del.calls setObject:callId forKey:uuid];
        [app.del.uuids setObject:uuid forKey:callId];
        NSLog(@"uuid: %@", uuid);
        NSString *caller = text_unknown;
        NSArray *info = [app getContactNameForCallWithCallInfo: ci];
        if (info != nil && info.count == 2) {
            caller = [info firstObject];
            app.remoteNumber = [info lastObject];

            //  lưu tên cho số điện thoại để hiển thị khi cần thiết
            NSString *key = SFM(@"name_for_%@", [info lastObject]);
            [[NSUserDefaults standardUserDefaults] setObject:caller forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [app.del reportIncomingCallwithUUID:uuid handle:app.remoteNumber caller_name:caller video:FALSE];
    }
    //  PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!", (int)ci.remote_info.slen,ci.remote_info.ptr));
    //  Automatically answer incoming calls with 200/OK
    //  pjsua_call_answer(call_id, 200, NULL, NULL);
}

//  Callback called by the library when call's media state has changed
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;

    pjsua_call_get_info(call_id, &ci);

    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

// Callback called by the library when call's state has changed
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    //  store call_id to get duration
    app.current_call_id = call_id;

    pjsua_call_info ci;

    PJ_UNUSED_ARG(e);

    pjsua_call_get_info(call_id, &ci);
    //  PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id, (int)ci.state_text.slen, ci.state_text.ptr));

    //  get remote number
    NSString *remoteNumber = @"";
    NSArray *contactInfo = [app getContactNameForCallWithCallInfo: ci];
    if (contactInfo.count >= 2) {
        remoteNumber = [contactInfo objectAtIndex: 1];
    }

    NSString *state = [app getContentOfCallStateWithStateValue: ci.state];
    NSString *last_status = [NSString stringWithFormat:@"%d", ci.last_status];
    app.pjsipConfAudioId = ci.conf_slot;

    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:state, @"state", last_status, @"last_status", nil];
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        app.current_call_id = -1;
        [info setObject:[NSNumber numberWithLong:ci.connect_duration.sec] forKey:@"call_duration"];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:notifCallStateChanged object:info];

    if (ci.state == PJSIP_INV_STATE_DISCONNECTED)
    {
        //  reset remoteNumber
        app.remoteNumber = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                [app deleteSIPAccountDefault];
                pjsua_destroy();
            }

            /** Initial call role (UAC == caller) */
            //  TRƯỜNG HỢP CHỈ DÀNH CHO MÌNH LÀ CALEE VÀ CUỘC GỌI CHƯA ĐƯỢC KẾT NỐI THÀNH CÔNG
            if (ci.role != PJSIP_ROLE_UAC && ci.role != PJSIP_UAC_ROLE && ci.last_status != PJSIP_SC_OK) {
                //  Nếu là nhận cuộc gọi vào last_status khác 200: Nghĩa là màn hình call chưa đc show lên, nên sẽ add history ở đây
                NSString *callID = [AppUtil randomStringWithLength: 12];
                NSString *date = [AppUtil getCurrentDate];
                NSString *time = [AppUtil getCurrentTimeStamp];

                NSString *callStatus;
                if (ci.last_status == PJSIP_SC_REQUEST_TERMINATED) {
                    //  caller đã hủy cuộc gọi: do đó trạng thái sẽ là gọi nhỡ
                    callStatus = missed_call;
                }else if (ci.last_status == PJSIP_SC_DECLINE || ci.last_status == PJSIP_SC_BUSY_HERE) {
                    //  mình huỷ cuộc gọi
                    callStatus = missed_call;
                }else{
                    callStatus = success_call;
                }

                NSString *strAddress = remoteNumber;
                if (![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT]) {
                    strAddress = SFM(@"sip:%@@%@:%@", remoteNumber, SIP_DOMAIN, SIP_PORT);
                }

                int timeInt = [[NSDate date] timeIntervalSince1970];
                [DatabaseUtil InsertHistory:callID status:callStatus phoneNumber:remoteNumber callDirection:incomming_call recordFiles:@"" duration:0 date:date time:time time_int:timeInt callType:AUDIO_CALL_TYPE sipURI:strAddress MySip:USERNAME andFlag:1 andUnread:1];

                //  Update lại cuộc số gọi nhỡ ở
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMissedCallBadge object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:reloadHistoryCall object:nil];
            }

            NSString *callId = [NSString stringWithFormat:@"%d", call_id];
            NSUUID *uuid = (NSUUID *)[app.del.uuids objectForKey: callId];
            if (uuid) {
                [app.del.uuids removeObjectForKey: callId];
                [app.del.calls removeObjectForKey: uuid];

                NSLog(@"uuid: %@", uuid);

                CXEndCallAction *act = [[CXEndCallAction alloc] initWithCallUUID:uuid];
                CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];

                [app.del.controller requestTransaction:tr completion:^(NSError * _Nullable error) {
                    NSLog(@"error = %@", error);
                }];
            }
        });
    }
}


static void on_reg_started(pjsua_acc_id acc_id, pj_bool_t renew) {
//    if (renew == 0 && app.clearingSIP) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:clearSIPAccountSuccessfully object:nil];
//        });
//    }
}

static void on_reg_state(pjsua_acc_id acc_id)
{
    pjsua_acc_info info;
    pjsua_acc_get_info(acc_id, &info);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"registration state: %d", info.status);
        if (info.status == PJSIP_SC_OK) {
            //  Lưu acc_id khi register thành công (vì bây giờ chưa tìm được cách lấy ds account từ PJSIP)
            [app checkToCallPhoneNumberFromPhoneCallHistory];

            [app storeSIPAccountNumber];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notifRegistrationStateChange object:[NSNumber numberWithInt: info.status]];
    });
    PJ_UNUSED_ARG(acc_id);
}

static void on_call_transfer_status(pjsua_call_id call_id, int status_code, const pj_str_t *status_text, pj_bool_t final, pj_bool_t *p_cont)
{
    NSLog(@"Call %d: transfer status=%d (%.*s) %s", call_id, status_code, (int)status_text->slen, status_text->ptr, (final ? "[final]" : ""));
    if (status_code/100 == 2) {
        NSLog(@"Call %d: call transferred successfully, disconnecting call", call_id);
        pjsua_call_hangup(call_id, PJSIP_SC_GONE, NULL, NULL);
        *p_cont = PJ_FALSE;
    }
}

- (void)checkToCallPhoneNumberFromPhoneCallHistory {
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey: UserActivity];
    if (![AppUtil isNullOrEmpty: phoneNumber]) {
        NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey: UserActivityName];
        
        phoneForCall = phoneNumber;
        [self getDIDListForCall];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivity];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivityName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)storeSIPAccountNumber {
    NSString *SIPNumber = [self getSipNumberOfAccount];
    [[NSUserDefaults standardUserDefaults] setObject:SIPNumber forKey:SIP_NUMBER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getSipNumberOfAccount {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            pjsua_acc_info info;
            pjsua_acc_get_info(acc_id, &info);

            NSString *contactURI = [NSString stringWithUTF8String: info.acc_uri.ptr];
            NSRange range = [contactURI rangeOfString:@"sip:"];
            if (range.location != NSNotFound) {
                contactURI = [contactURI substringFromIndex:(range.location + range.length)];
                range = [contactURI rangeOfString:@"@"];
                if (range.location != NSNotFound) {
                    contactURI = [contactURI substringToIndex: range.location];

                    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                    if ([bundleIdentifier isEqualToString:cloudcall_bundle]) {
                        if (contactURI.length > 5) {
                            contactURI = [contactURI substringFromIndex:5];
                        }
                    }
                }
            }
            return contactURI;
        }
        return @"";
    }
    return @"";
}

- (AccountState)checkSipStateOfAccount {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            pjsua_acc_info info;
            pjsua_acc_get_info(acc_id, &info);


            pj_caching_pool cp;
            pj_pool_t *pool;

            pjsua_msg_data msg_data;
            pjsua_msg_data_init(&msg_data);

            pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
            pool= pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);

            pjsua_acc_config config;
            pjsua_acc_get_config(acc_id, pool, &config);
            pj_pool_release(pool);

            if (info.status == PJSIP_SC_OK) {
                return eAccountOn;
            }else{
                return eAccountOff;
            }
        }
        return eAccountOff;
    }else{
        return eAccountNone;
    }
}

- (void)hangupAllCall {
    pjsua_call_hangup_all();
}

- (NSString *)getCallStateOfCurrentCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);

        NSString *state = [app getContentOfCallStateWithStateValue: ci.state];
        return state;
    }
    return @"";
}

- (NSString *)getContentOfCallStateWithStateValue: (pjsip_inv_state)state {
    switch (state) {
        case PJSIP_INV_STATE_NULL:{
            return CALL_INV_STATE_NULL;
        }
        case PJSIP_INV_STATE_CALLING:{
            return CALL_INV_STATE_CALLING;
        }
        case PJSIP_INV_STATE_INCOMING:{
            return CALL_INV_STATE_INCOMING;
        }
        case PJSIP_INV_STATE_EARLY:{
            return CALL_INV_STATE_EARLY;
        }
        case PJSIP_INV_STATE_CONNECTING:{
            return CALL_INV_STATE_CONNECTING;
        }
        case PJSIP_INV_STATE_CONFIRMED:{
            return CALL_INV_STATE_CONFIRMED;
        }
        case PJSIP_INV_STATE_DISCONNECTED:{
            return CALL_INV_STATE_DISCONNECTED;
        }
    }
    return @"";
}

- (void)makeCallTo: (NSString *)strCall {
    char *destUri = (char *)[strCall UTF8String];

    pjsua_acc_id acc_id = 0;
    pj_status_t status;
    pj_str_t pj_uri = pj_str(destUri);

    //current register id _acc_id


    //    pjsua_msg_data msg_data;
    //    pjsua_msg_data_init(&msg_data);
    //    pj_caching_pool cp;
    //    pj_pool_t *pool;
    //    pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
    //    pool= pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);
    //
    //    NSString *callID = [AppUtil randomStringWithLength: 10];
    //    pj_str_t hname = pj_str((char *)[@"Call-ID" UTF8String]);
    //    pj_str_t hvalue = pj_str((char *)[callID UTF8String]);
    //    pjsip_generic_string_hdr* add_hdr = pjsip_generic_string_hdr_create(pool, &hname, &hvalue);
    //    pj_list_push_back(&msg_data.hdr_list, add_hdr);
    //    status = pjsua_call_make_call(acc_id, &pj_uri, 0, NULL, &msg_data, NULL);

    status = pjsua_call_make_call(acc_id, &pj_uri, 0, NULL, NULL, NULL);
    if (status != PJ_SUCCESS){
        NSLog(@"Error making call");
    }
    /*
     pj_pool_release(pool);
     */
}

- (void)answerCallWithCallID: (int)call_id {
    pj_status_t status = pjsua_call_answer(call_id, 200, NULL, NULL);
    if (status == PJ_SUCCESS) {
        //  show call screen
        [self showCallViewWithDirection:IncomingCall remote:self.remoteNumber prefix:@"" displayName:@""];
    }
}

- (void) my_send_request
{
    pjsip_endpoint *g_endpt; /* SIP endpoint. */
    
    pjmedia_sock_info g_sock_info[MAX_MEDIA_CNT];   /* Socket info array */
    pjmedia_transport *g_med_transport[MAX_MEDIA_CNT];  /* Media stream transport */
    pjmedia_transport_info g_med_tpinfo[MAX_MEDIA_CNT];  /* Socket info for media */
    pjmedia_sdp_session *local_sdp;
    pjsip_inv_session *g_inv; /* Current invite session. */
    pjsip_tx_data *tdata;
    pj_status_t status;
    
    pjsip_dialog *dlg;
    pj_str_t local_uri = pj_str((char *)[@"sip:150@signature.vfone.vn" UTF8String]);
    pj_str_t dst_uri = pj_str((char *)[@"sip:151@signature.vfone.vn" UTF8String]);
    
    /* Must create a pool factory before we can allocate any memory. */
    pj_caching_pool cp; /* Global pool factory. */
    pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
    
    /* Endpoint MUST be assigned a globally unique name.
     * The name will be used as the hostname in Warning header.
    */
//    const pj_str_t *hostname;
//    const char *endpt_name;
//    /* For this implementation, we'll use hostname for simplicity */
//    hostname = pj_gethostname();
//    endpt_name = hostname->ptr;
//
//    pj_sockaddr addr;
//    pj_sockaddr_init(AF, &addr, NULL, (pj_uint16_t)SIP_PORT);
//
//    status = pjsip_endpt_create(&cp.factory, endpt_name, &g_endpt);
//    if (status != PJ_SUCCESS) {
//        NSLog(@"----ERROR pjsip_endpt_create----");
//    }
//
//    status = pjsip_udp_transport_start( g_endpt, &addr.ipv4, NULL, 1, NULL);
//    if (status != PJ_SUCCESS) {
//        NSLog(@"----ERROR pjsip_udp_transport_start----");
//    }
//
//    /* Initialize 100rel support */
//    status = pjsip_100rel_init_module(g_endpt);
//    if (status != PJ_SUCCESS) {
//        NSLog(@"----ERROR pjsip_100rel_init_module----");
//    }
    
    /*
     * Initialize media endpoint.
     * This will implicitly initialize PJMEDIA too.
     */
    pjmedia_endpt *g_med_endpt; /* Media endpoint. */
    status = pjmedia_endpt_create(&cp.factory, NULL, 1, &g_med_endpt);
    //  status = pjmedia_endpt_create(&cp.factory, pjsip_endpt_get_ioqueue(g_endpt), 0, &g_med_endpt);
    
    status = pjmedia_codec_g711_init(g_med_endpt);
    if (status != PJ_SUCCESS) {
        NSLog(@"----ERROR pjmedia_codec_g711_init----");
    }
    
    /* Create UAC dialog */
    status = pjsip_dlg_create_uac(pjsip_ua_instance(),
                                              &local_uri,    /* local URI */
                                              &local_uri,    /* local Contact */
                                              &dst_uri,      /* remote URI */
                                              &dst_uri,      /* remote target */
                                              &dlg);         /* dialog */
    if (status != PJ_SUCCESS) {
        NSLog(@"----Unable to create UAC dialog----");
    }
    
    /*
    * Create media transport used to send/receive RTP/RTCP socket.
    * One media transport is needed for each call. Application may
    * opt to re-use the same media transport for subsequent calls.
    */
    for (int i = 0; i < PJ_ARRAY_SIZE(g_med_transport); ++i) {
        status = pjmedia_transport_udp_create3(g_med_endpt, AF, NULL, NULL, RTP_PORT + i*2, 0, &g_med_transport[i]);
        if (status != PJ_SUCCESS) {
            NSLog(@"Unable to create media transport");
        }
        /*
         * Get socket info (address, port) of the media transport. We will
         * need this info to create SDP (i.e. the address and port info in
         * the SDP).
         */
        pjmedia_transport_info_init(&g_med_tpinfo[i]);
        pjmedia_transport_get_info(g_med_transport[i], &g_med_tpinfo[i]);
        
        pj_memcpy(&g_sock_info[i], &g_med_tpinfo[i].sock_info, sizeof(pjmedia_sock_info));
    }
    
    /* Get the SDP body to be put in the outgoing INVITE, by asking media endpoint to create one for us.*/
    status = pjmedia_endpt_create_sdp(g_med_endpt,   /* the media endpt */
                                      dlg->pool,     /* pool. */
                                      MAX_MEDIA_CNT, /* # of streams */
                                      g_sock_info,   /* RTP sock info */
                                      &local_sdp);   /* the SDP result */
    
    if (status != PJ_SUCCESS) {
        NSLog(@"ERROR pjmedia_endpt_create_sdp");
    }
    
    status = pjsip_inv_create_uac(dlg, local_sdp, 0, &g_inv);
    if (status != PJ_SUCCESS) {
        NSLog(@"ERROR pjsip_inv_create_uac");
    }
    
    /* Create initial INVITE request.
    * This INVITE request will contain a perfectly good request and
    * an SDP body as well.
    */
    status = pjsip_inv_invite(g_inv, &tdata);
    if (status != PJ_SUCCESS) {
        NSLog(@"ERROR Create initial INVITE request");
    }
    
    /* Send initial INVITE request.
     * From now on, the invite session's state will be reported to us
     * via the invite session callbacks.
    */
    status = pjsip_inv_send_msg(g_inv, tdata);
    if (status != PJ_SUCCESS) {
        NSLog(@"ERROR pjsip_inv_send_msg");
    }
    NSLog(@"LU PA --- THANH CONG LUON");
//    pjsip_endpoint *endpt = pjsua_get_pjsip_endpt();
//
//    //  create method
//    pjsip_method method;
//    method.id = PJSIP_INVITE_METHOD;
//    method.name = pj_str((char *)[@"INVITE" UTF8String]);
//
//    pj_str_t target_str = pj_str((char *)[@"sip:151@signature.vfone.vn:65400" UTF8String]);
//    pj_str_t from_str = pj_str((char *)[@"sip:151@signature.vfone.vn:65400" UTF8String]);
//    pj_str_t to_str = pj_str((char *)[@"sip:150@signature.vfone.vn:65400" UTF8String]);
//    pj_str_t contact_str = pj_str((char *)[@"<sip:151signature.vfone.vn:65400;ob>" UTF8String]);
//    pj_str_t text_str = pj_str((char *)[@"<sip:151signature.vfone.vn:65400;ob>" UTF8String]);
//
//    pj_status_t status;
//    pjsip_tx_data *tdata;
//    pjsip_transaction *tsx;
//    // Create the request.
//    pjsip_endpt_create_request(endpt, &method, &target_str, &from_str, &to_str, &contact_str, NULL, 10, NULL, &tdata);
    
//
//    status = pjsip_endpt_create_request( endpt, ..., &tdata );
//    // You may modify the message before sending it.
//
//    // Create transaction.
//    status = pjsip_endpt_create_uac_tsx( endpt, &app_module, tdata, &tsx );
//    // Send the request.
//    status = pjsip_tsx_send_msg( tsx, tdata /*or NULL*/);
}

- (void)playRingbackTone {
    if (ringbackPlayer == nil) {
        /* Use this code to play an audio file */
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"ringbacktone"  ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        ringbackPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        ringbackPlayer.numberOfLoops = -1; //Infinite
        [ringbackPlayer prepareToPlay];
    }
    
    if (ringbackPlayer.isPlaying) {
        return;
    }
    [ringbackPlayer play];
}

- (void)stopRingbackTone {
    if (ringbackPlayer != nil) {
        [ringbackPlayer stop];
    }
    ringbackPlayer = nil;
}

- (void)playBeepSound {
    if (beepPlayer == nil) {
        /* Use this code to play an audio file */
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [beepPlayer prepareToPlay];
    }
    
    if (beepPlayer.isPlaying) {
        [beepPlayer stop];
        [beepPlayer prepareToPlay];
    }
    [beepPlayer play];
}

- (NSArray *)getContactNameForCallWithCallInfo: (pjsua_call_info)ci {
    NSString *contactName = [NSString stringWithUTF8String: ci.remote_info.ptr];
    if (![AppUtil isNullOrEmpty: contactName]) {
        NSString *name = @"";
        NSString *subname = @"";

        //  get name
        NSRange range = [contactName rangeOfString:@" <"];
        if (range.location != NSNotFound) {
            name = [contactName substringToIndex: range.location];
        }else {
            range = [contactName rangeOfString:@"<"];
            if (range.location != NSNotFound) {
                name = [contactName substringToIndex: range.location];
            }
        }
        if ([name hasPrefix:@"\""]) {
            name = [name substringFromIndex:1];
        }
        if ([name hasSuffix:@"\""]) {
            name = [name substringToIndex:name.length - 1];
        }

        //  get subname
        range = [contactName rangeOfString:@"<sip:"];
        if (range.location != NSNotFound) {
            NSRange subrange = [contactName rangeOfString:@"@"];
            if (subrange.location != NSNotFound && range.location < subrange.location) {
                subname = [contactName substringWithRange:NSMakeRange(range.location+range.length, subrange.location - (range.location+range.length))];
            }
        }
        return @[name, subname];
    }
    return nil;
}

- (NSArray *)getContactNameOfRemoteForCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        NSString *contactName = [NSString stringWithUTF8String: ci.remote_info.ptr];
        if (![AppUtil isNullOrEmpty: contactName]) {
            NSString *name;
            NSString *subname;

            //  get name
            NSRange range = [contactName rangeOfString:@" <"];
            if (range.location != NSNotFound) {
                name = [contactName substringToIndex: range.location];
            }else {
                range = [contactName rangeOfString:@"<"];
                if (range.location != NSNotFound) {
                    name = [contactName substringToIndex: range.location];
                }
            }
            if ([name hasPrefix:@"\""]) {
                name = [name substringFromIndex:1];
            }
            if ([name hasSuffix:@"\""]) {
                name = [name substringToIndex:name.length - 1];
            }

            //  get subname
            range = [contactName rangeOfString:@"<sip:"];
            if (range.location != NSNotFound) {
                NSRange subrange = [contactName rangeOfString:@"@"];
                if (subrange.location != NSNotFound && range.location < subrange.location) {
                    subname = [contactName substringWithRange:NSMakeRange(range.location+range.length, subrange.location - (range.location+range.length))];
                }
            }
            return @[name, subname];
        }
    }
    return nil;
}

- (int)getDurationForCurrentCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);

        //  NSLog(@"%ld - %ld", ci.total_duration.sec, ci.connect_duration.sec);
        return (int)ci.connect_duration.sec;
    }
    return 0;
}

- (BOOL)checkMicrophoneWasMuted {
    if (pjsipConfAudioId >= 0) {
        unsigned int tx_level;
        unsigned int rx_level;
        pjsua_conf_get_signal_level(pjsipConfAudioId, &tx_level, &rx_level);
        if (tx_level == 0) {
            return TRUE;
        }else{
            return FALSE;
        }
    }
    return FALSE;
}

- (BOOL)isCallWasConnected {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);

        if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)muteMicrophone: (BOOL)mute {
    if (mute) {
        @try {
            if( pjsipConfAudioId != 0 ) {
                NSLog(@"WC_SIPServer microphone disconnected from call");
                pjsua_conf_disconnect(0, pjsipConfAudioId);
                return TRUE;
            }
            return FALSE;
        }
        @catch (NSException *exception) {
            return FALSE;
        }
    }else{
        @try {
            if( pjsipConfAudioId != 0 ) {
                NSLog(@"WC_SIPServer microphone reconnected to call");
                pjsua_conf_connect(0,pjsipConfAudioId);
                return TRUE;
            }
            return FALSE;
        }
        @catch (NSException *exception) {
            return FALSE;
        }
    }
}

- (BOOL)checkCurrentCallWasHold {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        if (ci.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)holdCurrentCall: (BOOL)hold {
    if (hold) {
        pj_status_t status = pjsua_call_set_hold(current_call_id, nil);
        if (status != PJ_SUCCESS){
            return FALSE;
        }
        return TRUE;
    }else{
        pj_status_t status = pjsua_call_reinvite(current_call_id, PJSUA_CALL_UNHOLD, nil);
        //  pj_status_t status = pjsua_call_update(current_call_id, PJSUA_CALL_UNHOLD, nil);
        if (status != PJ_SUCCESS){
            return FALSE;
        }
        return TRUE;
    }
}

- (BOOL)sendDtmfWithValue: (NSString *)value {
    pjsua_call_send_dtmf_param param;
    param.method = PJSUA_DTMF_METHOD_RFC2833;
    param.duration = PJSUA_CALL_SEND_DTMF_DURATION_DEFAULT;
    param.digits = pj_str((char *)[value UTF8String]);

    pj_status_t status = pjsua_call_send_dtmf(current_call_id, &param);
    if (status != PJ_SUCCESS){
        return FALSE;
    }
    return TRUE;
}

- (BOOL)deleteSIPAccountDefault {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id accId = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(accId)) {
            pj_status_t status = pjsua_acc_del(accId);
            if (status == PJ_SUCCESS) {
                return TRUE;
            }else{
                return FALSE;
            }
        }
    }
    return TRUE;
}

#pragma mark - Web service
- (void)getPBXGroupContactList {
    listGroup = [[NSMutableArray alloc] init];
    
    if (![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD]) {
        NSString *params = [NSString stringWithFormat:@"username=%@", USERNAME];
        [WebServiceUtil getInstance].delegate = self;
        [[WebServiceUtil getInstance] callWebServiceWithFunction:GetServerGroup withParams:params inBackgroundMode:TRUE];
    }
}

- (void)failedToGetServerGroupsWithError:(id)error {
    
}

- (void)getServerGroupsSuccessfullyWithData:(id)data {
    if (data != nil && [data isKindOfClass:[NSArray class]]) {
        [listGroup removeAllObjects];
        [listGroup addObjectsFromArray:(NSArray *)data];
    }
}

- (void)updateCustomerTokenIOS {
    if (USERNAME != nil && ![AppUtil checkDoNotDisturbMode]) {
        NSString *destToken = SFM(@"ios%@", deviceToken);
        NSString *params = SFM(@"pushtoken=%@&username=%@", destToken, USERNAME);
        [WebServiceUtil getInstance].delegate = self;
        [[WebServiceUtil getInstance] callWebServiceWithFunction:update_token_func withParams:params inBackgroundMode:TRUE];
    }
}

- (void)failedToUpdateTokenWithError:(id)error {
    
}

- (void)updateTokenSuccessfully {
    updateTokenSuccess = TRUE;
}


- (void)getDIDListForCall {
    //  check microphone permission
    //show warning Microphone
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            [self showWarningMicrophonePermisson];
        }else{
            [ProgressHUD backgroundColor: ProgressHUD_BG];
            [ProgressHUD show:text_waiting Interaction:NO];
            
            NSString *params = SFM(@"username=%@", USERNAME);
            
            [WebServiceUtil getInstance].delegate = self;
            [[WebServiceUtil getInstance] callWebServiceWithFunction:get_didlist_func withParams:params inBackgroundMode:TRUE];
        }
    }];
}

- (void)showWarningMicrophonePermisson {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"Ứng dụng không thể truy cập vào microphone của bạn. Vui lòng kiểm tra lại!"];
    [attrTitle addAttribute:NSFontAttributeName value:fontNormalRegular range:NSMakeRange(0, attrTitle.string.length)];
    [alertVC setValue:attrTitle forKey:@"attributedTitle"];
    
    UIAlertAction *btnClose = [UIAlertAction actionWithTitle:text_close style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [btnClose setValue:BLUE_COLOR forKey:@"titleTextColor"];
    
    UIAlertAction *btnSettings = [UIAlertAction actionWithTitle:text_go_to_settings style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                  {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[[NSDictionary alloc] init] completionHandler:nil];
                                  }];
    [btnSettings setValue:UIColor.redColor forKey:@"titleTextColor"];
    [alertVC addAction:btnClose];
    [alertVC addAction:btnSettings];
    [self.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
}

-(void)failedToGetDIDListWithError:(id)error {
    [ProgressHUD dismiss];
    
    [WriteLogsUtil writeLogContent:SFM(@"[%s] error: %@", __FUNCTION__, @[error])];
    [self.window makeToast:get_did_list_fail duration:2.0 position:CSToastPositionCenter style: errorStyle];
    [self showPopupToChooseDID: @[]];
}

-(void)getDIDListSuccessfullyWithData:(id)data {
    [ProgressHUD dismiss];
    
    [WriteLogsUtil writeLogContent:SFM(@"[%s] data: %@", __FUNCTION__, @[data])];
    if ([data isKindOfClass:[NSArray class]]) {
        [self showPopupToChooseDID: (NSArray *)data];
    }
}

- (void)showPopupToChooseDID: (NSArray *)data {
    if (data == nil) {
        data = [[NSArray alloc] init];
    }
    
    float wPopup = 350.0;
    float hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH <= 320) {
            wPopup = 300.0;
            hCell = 50.0;
        }
    }else{
        wPopup = 420.0;
    }
    
    
    float popupHeight;
    if ([(NSArray *)data count] > 6) {
        popupHeight = hCell + 7*hCell;
    }else{
        popupHeight = hCell + ([(NSArray *)data count] + 1) * hCell;
    }
    
    ChooseDIDPopupView *popupDID = [[ChooseDIDPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-wPopup)/2, (SCREEN_HEIGHT-popupHeight)/2, wPopup, popupHeight)];
    popupDID.delegate = self;
    [popupDID.listDID addObjectsFromArray: data];
    [popupDID.tbDIDList reloadData];
    [popupDID showInView:self.window animated:TRUE];
}

-(void)selectDIDForCallWithPrefix:(NSString *)prefix
{
    [WriteLogsUtil writeLogContent:SFM(@"[%s] prefix: %@, phoneForCall: %@", __FUNCTION__, prefix, phoneForCall)];
    
    NSString *myExt = [self getSipNumberOfAccount];
    if (![AppUtil isNullOrEmpty: myExt] && [myExt isEqualToString: phoneForCall]) {
        [self.window makeToast:cant_make_call_yourself duration:2.0 position:CSToastPositionCenter style:warningStyle];
        return;
    }
    
    if (![AppUtil isNullOrEmpty: phoneForCall]) {
        callPrefix = prefix;
        
        [SipUtil makeCallToPhoneNumber:phoneForCall prefix:prefix displayName:@""];
    }
}

- (void)showCallViewWithDirection: (CallDirection)direction remote: (NSString *)remote prefix:(NSString *)prefix displayName: (NSString *)displayName {
    if (callViewController == nil) {
        callViewController = [[CallViewController alloc] initWithNibName:@"CallViewController" bundle:nil];
    }
    callViewController.callDirection = direction;
    callViewController.remoteNumber = remote;
    callViewController.displayName = displayName;
    callViewController.prefix = prefix;
    
    callViewController.view.clipsToBounds = TRUE;
    //  callViewController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    [self.window addSubview: callViewController.view];
    [callViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.window);
        make.height.mas_equalTo(0);
    }];
    [self performSelector:@selector(startToShowCallView) withObject:nil afterDelay:0.02];
}

- (void)startToShowCallView {
    [callViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }];
}

- (void)hideCallView {
    [callViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.window);
        make.height.mas_equalTo(0.0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }completion:^(BOOL finished) {
        [callViewController.view removeFromSuperview];
        callViewController = nil;
    }];
}

#pragma mark - PushKit Functions

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type {
    NSLog(@"PushKit Token invalidated");
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"PushKit : incoming voip notfication: %@", payload.dictionaryPayload);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) { // Call category
        UNNotificationAction *act_ans =
        [UNNotificationAction actionWithIdentifier:@"Answer"
                                             title:NSLocalizedString(@"Answer", nil)
                                           options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:@"Decline"
                                                                             title:NSLocalizedString(@"Decline", nil)
                                                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_call =
        [UNNotificationCategory categoryWithIdentifier:@"call_cat"
                                               actions:[NSArray arrayWithObjects:act_ans, act_dec, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        // Msg category
        UNTextInputNotificationAction *act_reply =
        [UNTextInputNotificationAction actionWithIdentifier:@"Reply"
                                                      title:NSLocalizedString(@"Reply", nil)
                                                    options:UNNotificationActionOptionNone];
        UNNotificationAction *act_seen =
        [UNNotificationAction actionWithIdentifier:@"Seen"
                                             title:NSLocalizedString(@"Mark as seen", nil)
                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_msg =
        [UNNotificationCategory categoryWithIdentifier:@"msg_cat"
                                               actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Video Request Category
        UNNotificationAction *act_accept =
        [UNNotificationAction actionWithIdentifier:@"Accept"
                                             title:NSLocalizedString(@"Accept", nil)
                                           options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *act_refuse = [UNNotificationAction actionWithIdentifier:@"Cancel"
                                                                                title:NSLocalizedString(@"Cancel", nil)
                                                                              options:UNNotificationActionOptionNone];
        UNNotificationCategory *video_call =
        [UNNotificationCategory categoryWithIdentifier:@"video_request"
                                               actions:[NSArray arrayWithObjects:act_accept, act_refuse, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // ZRTP verification category
        UNNotificationAction *act_confirm = [UNNotificationAction actionWithIdentifier:@"Confirm"
                                                                                 title:NSLocalizedString(@"Accept", nil)
                                                                               options:UNNotificationActionOptionNone];
        
        UNNotificationAction *act_deny = [UNNotificationAction actionWithIdentifier:@"Deny"
                                                                              title:NSLocalizedString(@"Deny", nil)
                                                                            options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_zrtp =
        [UNNotificationCategory categoryWithIdentifier:@"zrtp_request"
                                               actions:[NSArray arrayWithObjects:act_confirm, act_deny, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
                                          UNAuthorizationOptionBadge)
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             // Enable or disable features based on authorization.
             if (error) {
                 NSLog(@"%@", error.description);
             }
         }];
        NSSet *categories = [NSSet setWithObjects:cat_call, cat_msg, video_call, cat_zrtp, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self processRemoteNotification:payload.dictionaryPayload];
    });
}

- (void)processRemoteNotification:(NSDictionary *)userInfo {
    /*  Push content
     alert =     {
     "call-id" = 14953;
     "loc-key" = "Incoming call from 14953";
     };
     badge = 1;
     "call-id" = 14953;
     "content-available" = 1;
     "loc-key" = "Incoming call from 14953";
     sound = default;
     title = CloudCall;
     */
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if (aps != nil)
    {
        NSDictionary *alert = [aps objectForKey:@"alert"];
        
        NSString *loc_key = [aps objectForKey:@"loc-key"];
        NSString *callId = [aps objectForKey:@"callerid"];
        
        NSString *caller = callId;
        NSString *content = SFM(@"Bạn có cuộc gọi từ %@", caller);
        
        UILocalNotification *messageNotif = [[UILocalNotification alloc] init];
        messageNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 0.1];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.alertBody = content;
        messageNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification: messageNotif];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self refreshSIPAccountRegistrationState];
        }else{
            [self refreshSIPRegistration];
        }
        
        if (alert != nil) {
            loc_key = [alert objectForKey:@"loc-key"];
            /*if we receive a remote notification, it is probably because our TCP background socket was no more working.
             As a result, break it and refresh registers in order to make sure to receive incoming INVITE or MESSAGE*/
            if (![DeviceUtil checkNetworkAvailable]) {
                [self.window makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter style:errorStyle];
                return;
            }
            
            if (loc_key != nil) {
                //  callId = [userInfo objectForKey:@"call-id"];
                if (callId != nil) {
                    if ([callId isEqualToString:@""]){
                        //Present apn pusher notifications for info
                        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
                            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                            content.title = @"APN Pusher";
                            content.body = @"Push notification received !";
                            
                            UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
                            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
                                // Enable or disable features based on authorization.
                                if (error) {
                                    NSLog(@"Error while adding notification request :%@", error.description);
                                }
                            }];
                        } else {
                            UILocalNotification *notification = [[UILocalNotification alloc] init];
                            notification.repeatInterval = 0;
                            notification.alertBody = @"Push notification received !";
                            notification.alertTitle = @"APN Pusher";
                            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        }
                    } else {
                        NSLog(@"addPushCallId");
                        //  [LinphoneManager.instance addPushCallId:callId];
                    }
                } else  if ([callId  isEqual: @""]) {
                    NSLog(@"PushNotification: does not have call-id yet, fix it !");
                }
            }else{
                [self.window makeToast:@"Not loc_key" duration:1.0 position:CSToastPositionCenter style:self.errorStyle];
            }
        }
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
    NSLog(@"PushKit credentials updated");
    NSLog(@"voip token: %@", (credentials.token));
    dispatch_async(dispatch_get_main_queue(), ^{
        deviceToken = credentials.token.description;
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        if (USERNAME != nil && ![USERNAME isEqualToString: @""] && !updateTokenSuccess) {
            [self updateCustomerTokenIOS];
        }else{
            updateTokenSuccess = FALSE;
        }
    });
}

@end

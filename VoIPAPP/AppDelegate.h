//
//  AppDelegate.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Toast.h"
#import "WebServiceUtil.h"
#import "ChooseDIDPopupView.h"
#import "Reachability.h"
#import "CallViewController.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import "AddressBook/ABPerson.h"
#import <AVFoundation/AVFoundation.h>
#import "ProviderDelegate.h"
#import <PushKit/PushKit.h>

typedef enum AccountState{
    eAccountNone,
    eAccountOff,
    eAccountOn,
}AccountState;

typedef enum {
    eSortAZ,
    eSortZA,
    eSort19,
    eSort91,
}eSortType;

typedef enum typePhoneNumber{
    ePBXPhone,
    eNormalPhone,
}typePhoneNumber;

typedef enum eContact{
    eContactAll,
    eContactPBX,
    eContactGroup,
}eContact;

typedef enum eTypeHistory{
    eAllCalls,
    eMissedCalls,
    eRecordCalls,
}eTypeHistory;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WebServiceUtilDelegate, ChooseDIDPopupViewDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;
+(AppDelegate *) sharedInstance;

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;

@property (nonatomic, assign) BOOL contactLoaded;
@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic, assign) float hStatus;
@property (nonatomic, assign) float hNav;
@property (nonatomic, strong) NSString *randomKey;
@property (nonatomic, strong) NSString *hashStr;
@property (nonatomic, strong) NSString *phoneForCall;
@property (nonatomic, strong) NSString *callPrefix;

@property (nonatomic, assign) BOOL internetActive;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) Reachability* hostReachable;

@property (strong, nonatomic) CSToastStyle *errorStyle;
@property (strong, nonatomic) CSToastStyle *warningStyle;
@property (strong, nonatomic) CSToastStyle *successStyle;

@property (nonatomic, strong) UIFont *fontLargeBold;
@property (nonatomic, strong) UIFont *fontLargeMedium;
@property (nonatomic, strong) UIFont *fontLargeRegular;
@property (nonatomic, strong) UIFont *fontLargeDesc;

@property (nonatomic, strong) UIFont *fontNormalBold;
@property (nonatomic, strong) UIFont *fontNormalMedium;
@property (nonatomic, strong) UIFont *fontNormalRegular;
@property (nonatomic, strong) UIFont *fontNormalDesc;

@property (nonatomic, strong) UIFont *fontSmallBold;
@property (nonatomic, strong) UIFont *fontSmallMedium;
@property (nonatomic, strong) UIFont *fontSmallRegular;
@property (nonatomic, strong) UIFont *fontSmallDesc;

@property (nonatomic, strong) UIFont *fontDescBold;
@property (nonatomic, strong) UIFont *fontDescMedium;
@property (nonatomic, strong) UIFont *fontDescNormal;


@property (nonatomic, strong) NSArray *listNumber;
@property (nonatomic, strong) NSMutableArray *listContacts;
@property (nonatomic, strong) NSMutableArray *pbxContacts;
@property (nonatomic, strong) NSMutableArray *listInfoPhoneNumber;
@property (nonatomic, strong) NSMutableArray *listGroup;

@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, assign) BOOL updateTokenSuccess;

- (void)getDIDListForCall;
- (NSMutableArray *)getPBXContactPhone: (int)pbxContactId;
- (void)updateCustomerTokenIOS;

//  PJSIP
@property (nonatomic, strong) AVAudioPlayer *beepPlayer;
@property (nonatomic, strong) AVAudioPlayer *ringbackPlayer;
@property (nonatomic, assign) int current_call_id;
@property (nonatomic, strong) NSString *remoteNumber;
@property (nonatomic, strong) ProviderDelegate *del;
@property (nonatomic, strong) PKPushRegistry* voipRegistry;
@property (nonatomic, assign) int pjsipConfAudioId;

@property (nonatomic, strong) CallViewController *callViewController;
- (void)refreshSIPAccountRegistrationState;
- (void)registerSIPAccountWithInfo: (NSDictionary *)info;
- (void)storeSIPAccountNumber;
- (NSString *)getSipNumberOfAccount;
- (AccountState)checkSipStateOfAccount;
- (void)showCallViewWithDirection: (CallDirection)direction remote: (NSString *)remote prefix:(NSString *)prefix displayName: (NSString *)displayName;
- (void)hideCallView;
- (void)hangupAllCall;
- (NSString *)getCallStateOfCurrentCall;
- (void)makeCallTo: (NSString *)strCall;
- (void)answerCallWithCallID: (int)call_id;
- (NSArray *)getContactNameOfRemoteForCall;
- (int)getDurationForCurrentCall;
- (BOOL)checkMicrophoneWasMuted;
- (BOOL)isCallWasConnected;
- (BOOL)muteMicrophone: (BOOL)mute;
- (BOOL)checkCurrentCallWasHold;
- (BOOL)holdCurrentCall: (BOOL)hold;
- (BOOL)sendDtmfWithValue: (NSString *)value;
- (BOOL)deleteSIPAccountDefault;

- (void)playRingbackTone;
- (void)stopRingbackTone;
- (void)playBeepSound;
- (void) my_send_request;

@end


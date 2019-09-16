//
//  CallViewController.m
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "CallViewController.h"
#import "NSData+Base64.h"
#import "UIMiniKeypad.h"

#define kMaxRadius 200
#define kMaxDuration 10

@interface CallViewController (){
    AppDelegate *appDelegate;
    NSTimer *durationTimer;
    NSTimer *timerHangupCall;
    
    float wIconEndCall;
    float wSmallIcon;
    float wAvatar;
    float marginQuality;
    float hStateLabel;
}

@end

@implementation CallViewController
@synthesize viewOutgoing, bgOutgoing, lbOutgoingName, lbOutgoingPhone, imgCallState, lbOutgoingState, imgOutgoingAvatar, icOutgoingSpeaker, icOutgoingHangup, icOutgoingMute;
@synthesize viewCall, bgCall, lbName, lbPhone, lbDuration, lbConnect, imgAvatar, iconMute, iconSpeaker, iconHangup, iconHold, iconMiniKeypad;
@synthesize remoteNumber, displayName, callDirection, prefix;
@synthesize halo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self registerObserveres];
    
    //  set remote name
    [self showCallContactInformation];
    [self showSpeakerButtonWithCurrentRouteState];
    
    if ([AppUtil isNullOrEmpty: displayName]) {
        if (callDirection == IncomingCall) {
            NSArray *nameInfo = [appDelegate getContactNameOfRemoteForCall];
            if (nameInfo != nil) {
                displayName = [nameInfo objectAtIndex: 0];
            }
        }
    }
    if ([AppUtil isNullOrEmpty: displayName]) {
        displayName = text_unknown;
    }
    
    lbName.text = lbOutgoingName.text = displayName;
    lbPhone.text = lbOutgoingPhone.text = remoteNumber;
    
    //  show calling animation for avatar
    if (callDirection == OutgoingCall) {
        if (self.halo == nil) {
            [self addAnimationForOutgoingCall];
        }
        self.halo.hidden = TRUE;
        [self.halo start];
        
        lbOutgoingState.text = text_calling;
        [self updateButtonsWithCallState: CALL_INV_STATE_CALLING];
        
        viewOutgoing.hidden = FALSE;
        viewCall.hidden = TRUE;
    }else{
        //  Hiển thị duration nếu khi vào màn hình call và cuộc gọi đã được kết nối thành công
        if ([appDelegate isCallWasConnected]) {
            viewOutgoing.hidden = TRUE;
            viewCall.hidden = FALSE;

            [self startToUpdateDurationForCall];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self requestAccessToMicroIfNot];
    
    if (callDirection == OutgoingCall) {
        NSString *callState = [appDelegate getCallStateOfCurrentCall];
        if ([AppUtil isNullOrEmpty: callState] && ![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT])
        {
            NSString *number = SFM(@"%@%@", prefix, remoteNumber);
            NSString *stringForCall = SFM(@"sip:%@@%@:%@", number, SIP_DOMAIN, SIP_PORT);
            [appDelegate makeCallTo: stringForCall];
            
            [appDelegate playRingbackTone];
            
            [WriteLogsUtil writeLogContent:SFM(@"-------------> Make call to: %@", stringForCall)];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.halo.position = imgOutgoingAvatar.center;
    if (imgOutgoingAvatar.frame.origin.y == (SCREEN_HEIGHT - wAvatar)/2) {
        self.halo.hidden = FALSE;
    }
}

- (IBAction)icOutgoingSpeakerClick:(UIButton *)sender {
}

- (IBAction)icOutgoingHangupCallClick:(UIButton *)sender {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    [appDelegate hangupAllCall];
}

- (IBAction)icOutgoingMuteClick:(UIButton *)sender {
}

- (void)registerObserveres {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChanged:)
                                                 name:notifCallStateChanged object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                               name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)showSpeakerButtonWithCurrentRouteState {
    TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
    if (curRoute == eEarphone) {
        if (iconSpeaker.enabled) {
            [iconSpeaker setImage:[UIImage imageNamed:@"speaker_bluetooth_normal"]
                         forState:UIControlStateNormal];
        }else{
            [iconSpeaker setImage:[UIImage imageNamed:@"speaker_bluetooth_dis"]
                         forState:UIControlStateNormal];
        }
    }else if (curRoute == eSpeaker){
        if ([DeviceUtil isConnectedEarPhone]) {
            [iconSpeaker setImage:[UIImage imageNamed:@"speaker_bluetooth_enable"]
                         forState:UIControlStateNormal];
        }else{
            [iconSpeaker setImage:[UIImage imageNamed:@"speaker_enable"]
                         forState:UIControlStateNormal];
        }
    }else{
        [iconSpeaker setImage:[UIImage imageNamed:@"speaker_normal"]
                     forState:UIControlStateNormal];
    }
}

- (void)onCallStateChanged: (NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [notif object];
        if ([info isKindOfClass:[NSDictionary class]]) {
            NSString *state = [info objectForKey:@"state"];
            NSString *last_status = [info objectForKey:@"last_status"];
            
            //  show state of buttons
            [self updateButtonsWithCallState: state];
            
            if ([state isEqualToString: CALL_INV_STATE_CALLING]) {
                lbOutgoingState.text = text_calling;
                
            }else if ([state isEqualToString: CALL_INV_STATE_EARLY]) {
                lbOutgoingState.text = text_ringing;
                
            }else if ([state isEqualToString: CALL_INV_STATE_CONNECTING]) {
                lbOutgoingState.text = SFM(@"%@...", text_connecting);
                
            }else if ([state isEqualToString: CALL_INV_STATE_CONFIRMED]) {
                viewOutgoing.hidden = TRUE;
                viewCall.hidden = FALSE;
                
                lbConnect.text = lbOutgoingState.text = text_connected;
                //  Update duration for call
                [self startToUpdateDurationForCall];

                [self stopCallingAnimation];
                
            }else if ([state isEqualToString: CALL_INV_STATE_DISCONNECTED])
            {
                [self stopCallingAnimation];
                
                NSString *content = text_call_terminated;
                
                if ([last_status isEqualToString:@"503"] || [last_status isEqualToString:@"603"] || [last_status isEqualToString:@"486"]) {
                    content = text_user_busy;
                }
                lbConnect.text = lbOutgoingState.text = content;
                
                int duration = 0;
                NSNumber *call_duration = [info objectForKey:@"call_duration"];
                if (call_duration != nil) {
                    duration = [call_duration intValue];
                }
                NSTimeInterval timeInt = [[NSDate date] timeIntervalSince1970];
                timeInt = timeInt - duration;
                
                [self performSelector:@selector(dismissCallView) withObject:nil afterDelay:2.0];
                
                NSString *callID = [AppUtil randomStringWithLength: 12];
                NSString *date = [AppUtil getDateFromTimeInterval: timeInt];
                NSString *time = [AppUtil getCurrentTimeStampFromTimeInterval: timeInt];
                
                NSString *callStatus;
                if ([last_status isEqualToString:@"200"]) {
                    callStatus = success_call;
                    
                }else if ([last_status isEqualToString:@"487"]) {
                    callStatus = aborted_call;
                    
                }else if ([last_status isEqualToString:@"503"]) {
                    callStatus = declined_call;
                    
                }else if ([last_status isEqualToString:@"603"]) {
                    callStatus = not_answer_call;
                }
                
                NSString *strAddress = SFM(@"%@%@", prefix, remoteNumber);
                if (![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT]) {
                    strAddress = SFM(@"sip:%@@%@:%@", remoteNumber, SIP_DOMAIN, SIP_PORT);
                }
                
                NSString *direction = (callDirection == IncomingCall) ? incomming_call : outgoing_call;
                [DatabaseUtil InsertHistory:callID status:callStatus phoneNumber:remoteNumber callDirection:direction recordFiles:@"" duration:duration date:date time:time time_int:timeInt callType:AUDIO_CALL_TYPE sipURI:strAddress MySip:USERNAME andFlag:1 andUnread:0];
                
                //  clear timer
                [durationTimer invalidate];
                durationTimer = nil;
                [self hideMiniKeypad];
            }
            
            if ([state isEqualToString: CALL_INV_STATE_CONNECTING] || [state isEqualToString: CALL_INV_STATE_CONFIRMED] || [state isEqualToString: CALL_INV_STATE_DISCONNECTED]) {
                [appDelegate stopRingbackTone];
            }
        }
    });
}

- (void)startToUpdateDurationForCall {
    if (durationTimer) {
        [durationTimer invalidate];
        durationTimer = nil;
    }
    
    [self resetDurationValueForCall];
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetDurationValueForCall) userInfo:nil repeats:TRUE];
}

- (void)resetDurationValueForCall
{
    long duration = [appDelegate getDurationForCurrentCall];
    NSString *strDuration = [AppUtil durationToString: (int)duration];
    lbDuration.text = strDuration;
}

- (void)dismissCallView {
    if (timerHangupCall) {
        [timerHangupCall invalidate];
        timerHangupCall = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadHistoryCall object:nil];
    
    [self.navigationController popViewControllerAnimated: TRUE];
    [appDelegate hideCallView];
}

- (void)updateButtonsWithCallState: (NSString *)call_state {
    if ([call_state isEqualToString: CALL_INV_STATE_CALLING] || [call_state isEqualToString: CALL_INV_STATE_DISCONNECTED])
    {
        icOutgoingMute.enabled = icOutgoingSpeaker.enabled = FALSE;
        
    }else if ([call_state isEqualToString: CALL_INV_STATE_EARLY]) {
        icOutgoingMute.enabled = icOutgoingSpeaker.enabled = TRUE;
        
        [self showSpeakerButtonWithCurrentRouteState];
    }else if ([call_state isEqualToString: CALL_INV_STATE_CONFIRMED]){
        icOutgoingMute.enabled = icOutgoingSpeaker.enabled = TRUE;
        
        [self showSpeakerButtonWithCurrentRouteState];
    }
}

//  Hide keypad mini
- (void)hideMiniKeypad{
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == 10) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
}

- (void)setupUIForView {
    float marginIcon = 5.0;
    float marginPhone = 30.0;
    float marginHangup = 35.0;
    float hLabelName = 35.0;
    
    float margin = 25.0;
    wIconEndCall = 80.0;
    marginQuality = 50.0;
    wAvatar = 120.0;
    
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            //  Screen width: 320.000000 - Screen height: 667.000000
            wAvatar = 110.0;
            wIconEndCall = 60.0;
            wSmallIcon = 48.0;
            marginQuality = 30.0;
            marginIcon = 9.0;
            marginPhone = 20.0;
            marginHangup = 20.0;
            
            lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:25.0];
            lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:18.0];
            lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:22.0];
            
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            //  Screen width: 375.000000 - Screen height: 667.000000
            wAvatar = 120.0;
            wIconEndCall = 70.0;
            wSmallIcon = 55.0;
            marginIcon = 10.0;
            lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:28.0];
            lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:21.0];
            lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:25.0];
            
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: simulator])
        {
            //  Screen width: 414.000000 - Screen height: 736.000000
            wAvatar = 130.0;
            wIconEndCall = 70.0;
            wSmallIcon = 60.0;
            margin = 45.0;
            hLabelName = 60.0;
            marginIcon = 15;
            
            lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:30.0];
            lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:23.0];
            lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:27.0];
            
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
        {
            //  Screen width: 375.000000 - Screen height: 812.000000
            wAvatar = 150.0;
            wIconEndCall = 68.0;
            wSmallIcon = 55.0;
            margin = 45.0;
            hLabelName = 60.0;
            marginIcon = 12;
            
            lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:30.0];
            lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:23.0];
            lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:27.0];
        }else{
            wAvatar = 150.0;
            wIconEndCall = 68.0;
            wSmallIcon = 55.0;
            margin = 45.0;
            hLabelName = 60.0;
            marginIcon = 12;
            
            lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:30.0];
            lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:23.0];
            lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:27.0];
        }
        
    }else{
        wAvatar = 150.0;
        wIconEndCall = 68.0;
        wSmallIcon = 55.0;
        margin = 45.0;
        hLabelName = 60.0;
        marginIcon = 12;
        
        lbOutgoingName.font = lbName.font = [UIFont fontWithName:HelveticaNeueConBold size:30.0];
        lbOutgoingPhone.font = [UIFont fontWithName:HelveticaNeue size:23.0];
        lbOutgoingState.font = [UIFont fontWithName:HelveticaNeueLight size:27.0];
    }
    hStateLabel = 25.0;
    
    //  outgoing view
    [viewOutgoing mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [bgOutgoing mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewOutgoing);
    }];
    
    imgOutgoingAvatar.clipsToBounds = TRUE;
    imgOutgoingAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    imgOutgoingAvatar.layer.borderWidth = 2.0;
    imgOutgoingAvatar.layer.cornerRadius = wAvatar/2;
    [imgOutgoingAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewOutgoing).offset((SCREEN_HEIGHT - wAvatar)/2);
        make.centerX.equalTo(viewOutgoing.mas_centerX);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    [lbOutgoingState mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewOutgoing.mas_centerX);
        make.bottom.equalTo(imgOutgoingAvatar.mas_top).offset(-marginQuality);
        make.width.mas_equalTo(300.0);
        make.height.mas_equalTo(30.0);
    }];
    
    [imgCallState mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewOutgoing.mas_centerX);
        make.bottom.equalTo(lbOutgoingState.mas_top).offset(-5.0);
        make.width.height.mas_equalTo(28.0);
    }];
    
    [lbOutgoingPhone mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewOutgoing.mas_centerX);
        make.bottom.equalTo(imgCallState.mas_top).offset(-30.0);
        make.height.mas_equalTo(25.0);
        make.width.mas_equalTo(300.0);
    }];
    
    [lbOutgoingName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(lbOutgoingPhone.mas_top);
        make.height.mas_equalTo(hLabelName);
        make.width.mas_equalTo(300.0);
    }];
    
    [icOutgoingHangup mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewOutgoing.mas_centerX);
        make.bottom.equalTo(viewOutgoing).offset(-40.0);
        make.width.height.mas_equalTo(wIconEndCall);
    }];
    icOutgoingHangup.layer.cornerRadius = wIconEndCall/2;
    
    [icOutgoingSpeaker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(icOutgoingHangup.mas_centerY);
        make.left.equalTo(icOutgoingHangup.mas_right).offset(margin);
        make.width.height.mas_equalTo(wSmallIcon);
    }];
    icOutgoingSpeaker.layer.cornerRadius = wSmallIcon/2;
    icOutgoingSpeaker.backgroundColor = UIColor.clearColor;
    
    //  mute button
    [icOutgoingMute mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(icOutgoingHangup.mas_centerY);
        make.right.equalTo(icOutgoingHangup.mas_left).offset(-margin);
        make.width.height.mas_equalTo(wSmallIcon);
    }];
    icOutgoingMute.layer.cornerRadius = wSmallIcon/2;
    icOutgoingMute.backgroundColor = UIColor.clearColor;
    
    //  view call detail
    [viewCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [bgCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewCall);
    }];
    
    imgAvatar.clipsToBounds = TRUE;
    imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    imgAvatar.layer.borderWidth = 2.0;
    imgAvatar.layer.cornerRadius = wAvatar/2;
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewCall.mas_centerX);
        make.centerY.equalTo(viewCall.mas_centerY);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    lbConnect.font = [UIFont fontWithName:HelveticaNeueLight size:24.0];
    lbConnect.textColor = UIColor.whiteColor;
    [lbConnect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewCall).offset(5.0);
        make.right.equalTo(viewCall).offset(-5.0);
        make.bottom.equalTo(imgAvatar.mas_top).offset(-marginQuality);
        make.height.mas_equalTo(30);
    }];
    
    lbDuration.font = [UIFont fontWithName:HelveticaNeue size:40.0];
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewCall.mas_centerX);
        make.bottom.equalTo(lbConnect.mas_top).offset(-10.0);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(50);
    }];
    
    lbPhone.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewCall.mas_centerX);
        make.bottom.equalTo(lbDuration.mas_top).offset(-marginPhone);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(30);
    }];
    
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewCall).offset(5.0);
        make.right.equalTo(viewCall).offset(-5.0);
        make.bottom.equalTo(lbPhone.mas_top);
        make.height.mas_equalTo(40);
    }];
    
    [iconHangup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewCall.mas_centerX);
        make.bottom.equalTo(viewCall).offset(-marginHangup);
        make.width.height.mas_equalTo(wIconEndCall);
    }];
    
//    [iconSpeaker setImage:[UIImage imageNamed:@"speaker_normal"] forState:UIControlStateNormal];
//    [iconSpeaker setImage:[UIImage imageNamed:@"speaker_dis"] forState:UIControlStateDisabled];
    [iconSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconHangup.mas_centerY);
        make.right.equalTo(iconHangup.mas_left).offset(-marginIcon);
        make.width.height.mas_equalTo(wSmallIcon);
    }];
    
    [iconMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(iconSpeaker);
        make.right.equalTo(iconSpeaker.mas_left).offset(-marginIcon);
        make.width.mas_equalTo(wSmallIcon);
    }];
    
    [iconHold mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(iconSpeaker);
        make.left.equalTo(iconHangup.mas_right).offset(marginIcon);
        make.width.mas_equalTo(wSmallIcon);
    }];
    
    [iconMiniKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(iconSpeaker);
        make.left.equalTo(iconHold.mas_right).offset(marginIcon);
        make.width.mas_equalTo(wSmallIcon);
    }];
}

- (void)requestAccessToMicroIfNot
{
    //show warning Microphone
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
        if (granted) {
            NSLog(@"granted");
        } else {
            [appDelegate hangupAllCall];
        }
    }];
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
//        if (granted) {
//            NSLog(@"granted");
//        } else {
//            [appDelegate hangupAllCall];
//        }
//    }];
}

- (void)addAnimationForOutgoingCall {
    NSString *callState = [appDelegate getCallStateOfCurrentCall];
    if (callDirection == OutgoingCall && ![callState isEqualToString: CALL_INV_STATE_CONFIRMED]) {
        // basic setup
        PulsingHaloLayer *layer = [PulsingHaloLayer layer];
        self.halo = layer;
        [imgOutgoingAvatar.superview.layer insertSublayer:self.halo below:imgOutgoingAvatar.layer];
        [self setupInitialValuesWithNumLayer:5 radius:0.8 duration:0.45
                                       color:[UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:0.7]];
    }
}

- (void)setupInitialValuesWithNumLayer: (int)numLayer radius: (float)radius duration: (float)duration color: (UIColor *)color
{
    self.halo.haloLayerNumber = numLayer;
    self.halo.radius = radius * kMaxRadius;
    self.halo.animationDuration = duration * kMaxDuration;
    [self.halo setBackgroundColor:color.CGColor];
}

- (void)stopCallingAnimation {
    if (self.halo) {
        //  Stop halo waiting
        self.halo.hidden = TRUE;
        [self.halo start];
        self.halo = nil;
        [self.halo removeFromSuperlayer];
    }
}

- (void)showCallContactInformation {
    PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: remoteNumber];
    if (contact != nil) {
        if ([AppUtil isNullOrEmpty: contact.avatar]) {
            imgOutgoingAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }else{
            imgOutgoingAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: contact.avatar]];
        }
        displayName = contact.name;
    }else{
        imgOutgoingAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    if ([remoteNumber isEqualToString:hotline]) {
        imgOutgoingAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }
}

- (IBAction)iconMuteClick:(UIButton *)sender {
    BOOL isMuted = [appDelegate checkMicrophoneWasMuted];
    if (isMuted) {
        BOOL result = [appDelegate muteMicrophone: FALSE];
        if (result) {
            [sender setImage:[UIImage imageNamed:@"mute_normal"] forState:UIControlStateNormal];
            [self.view makeToast:text_microphone_is_on duration:1.0 position:CSToastPositionCenter];
        }else{
            [sender setImage:[UIImage imageNamed:@"mute_enable"] forState:UIControlStateNormal];
            [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        }
    }else {
        BOOL result = [[AppDelegate sharedInstance] muteMicrophone: TRUE];
        if (result) {
            [sender setImage:[UIImage imageNamed:@"mute_enable"] forState:UIControlStateNormal];
            [self.view makeToast:text_microphone_is_off duration:1.0 position:CSToastPositionCenter];
        }else{
            [sender setImage:[UIImage imageNamed:@"mute_normal"] forState:UIControlStateNormal];
            [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        }
    }
}

- (IBAction)iconSpeakerClick:(UIButton *)sender {
    if ([DeviceUtil isConnectedEarPhone]) {
        TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
        if (curRoute == eEarphone) {
            BOOL result = [DeviceUtil tryToEnableSpeakerWithEarphone];
            if (!result) {
                [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_act"] forState:UIControlStateNormal];
            [self.view makeToast:text_speaker_is_on duration:1.0 position:CSToastPositionCenter];
        }else{
            BOOL result = [DeviceUtil tryToConnectToEarphone];
            if (!result) {
                [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_ble_act"] forState:UIControlStateNormal];
            [self.view makeToast:text_speaker_is_off duration:1.0 position:CSToastPositionCenter];
        }
    }else{
        TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
        if (curRoute == eReceiver) {
            BOOL result = [DeviceUtil enableSpeakerForCall: TRUE];
            if (!result) {
                [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"speaker_enable"] forState:UIControlStateNormal];
            [self.view makeToast:text_speaker_is_on duration:1.0 position:CSToastPositionCenter];
            
        }else{
            BOOL result = [DeviceUtil enableSpeakerForCall: FALSE];
            if (!result) {
                [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"speaker_normal"] forState:UIControlStateNormal];
            [self.view makeToast:text_speaker_is_off duration:1.0 position:CSToastPositionCenter];
        }
    }
}

- (IBAction)iconHangupClick:(UIButton *)sender {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    [appDelegate hangupAllCall];
    
    if (timerHangupCall) {
        [timerHangupCall invalidate];
        timerHangupCall = nil;
    }
    timerHangupCall = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dismissCallView) userInfo:nil repeats:FALSE];
}

- (IBAction)iconHoldCallClick:(UIButton *)sender {
    BOOL holing = [appDelegate checkCurrentCallWasHold];
    if (holing) {
        BOOL result = [appDelegate holdCurrentCall: FALSE];
        if (!result) {
            [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
            return;
        }
        [iconHold setImage:[UIImage imageNamed:@"hold_normal"] forState:UIControlStateNormal];
    }else{
        BOOL result = [appDelegate holdCurrentCall: TRUE];
        if (!result) {
            [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
            return;
        }
        [iconHold setImage:[UIImage imageNamed:@"hold_enable"] forState:UIControlStateNormal];
    }
}

- (IBAction)iconMiniKeypadClick:(UIButton *)sender {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    [self showMiniKeypadOnView: self.view];
}

- (void)showMiniKeypadOnView: (UIView *)aview
{
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"UIMiniKeypad" owner:nil options:nil];
    UIMiniKeypad *viewKeypad;
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[UIMiniKeypad class]]) {
            viewKeypad = (UIMiniKeypad *) currentObject;
            break;
        }
    }
    [viewKeypad.iconBack addTarget:self
                            action:@selector(hideMiniKeypad)
                  forControlEvents:UIControlEventTouchUpInside];
    [aview addSubview:viewKeypad];
    [viewKeypad.iconMiniKeypadEndCall addTarget:self
                                         action:@selector(endCallFromMiniKeypad)
                               forControlEvents:UIControlEventTouchUpInside];
    
    [viewKeypad mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(aview);
    }];
    [viewKeypad setupUIForView];
    
    viewKeypad.tag = 10;
    [self fadeIn:viewKeypad];
}

- (void)fadeIn :(UIView*)view{
    view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    view.alpha = 0.0;
    [UIView animateWithDuration:.35 animations:^{
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        view.alpha = 1.0;
    }];
}

- (void)endCallFromMiniKeypad {
    [self hideMiniKeypad];
    [appDelegate hangupAllCall];
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
    if (!IS_IPHONE && !IS_IPOD) {
        return;
    }
    
    // there is at least one bug when you disconnect an audio bluetooth headset
    // since we only get notification of route having changed, we cannot tell if that is due to:
    // -bluetooth headset disconnected or
    // -user wanted to use earpiece
    // the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
    if ([[notif.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue] ==
        AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        NSLog(@"_bluetoothAvailable = NO;");
    }
    
    AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;
    if (newRoute && (unsigned long)newRoute.outputs.count > 0) {
        NSString *route = newRoute.outputs[0].portType;
        
        NSLog(@"Detect BLE: newRoute = %@", route);
        
        BOOL _speakerEnabled = [route isEqualToString:AVAudioSessionPortBuiltInSpeaker];
        if (notif.userInfo != nil) {
            NSDictionary *info = notif.userInfo;
            id headphonesObj = [info objectForKey:@"AVAudioSessionRouteChangeReasonKey"];
            if (headphonesObj != nil && [headphonesObj isKindOfClass:[NSNumber class]]) {
                [self headsetPluginChangedWithReason: headphonesObj];
            }
        }
        
        //  [Khai Le - 23/03/2019]
        if (([[DeviceUtil bluetoothRoutes] containsObject:route]) && !_speakerEnabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"bluetoothEnabled" object:nil];
            
        }else if ([[route lowercaseString] containsString:@"speaker"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"speakerEnabled" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"iPhoneReceiverEnabled" object:nil];
        }
    }
}

- (void)headsetPluginChangedWithReason: (NSNumber *)reason {
    if (reason != nil && [reason isKindOfClass:[NSNumber class]]) {
        int routeChangeReason = [reason intValue];
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //  Tai nghe bị rút ra
                NSLog(@"OldDeviceUnavailable");
                TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
                if (curRoute == eSpeaker) {
                    [iconSpeaker setImage:[UIImage imageNamed:@"speaker_enable"] forState:UIControlStateNormal];
                    
                }else if (curRoute == eReceiver) {
                    [iconSpeaker setImage:[UIImage imageNamed:@"speaker_normal"] forState:UIControlStateNormal];
                }
            });
        }
        if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //  Khi cắm tai nghe vào, chuyển audio vào tai nghe, set lại giá trị cho button
                NSLog(@"NewDeviceAvailable");
                [iconSpeaker setImage:[UIImage imageNamed:@"speaker_normal"] forState:UIControlStateNormal];
            });
        }
    }
}

@end

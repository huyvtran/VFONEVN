//
//  DialerViewController.m
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "DialerViewController.h"
#import "SearchContactPopupView.h"

@interface DialerViewController ()<SearchContactPopupViewDelegate> {
    AppDelegate *appDelegate;
    float hAddressField;
    NSTimer *pressTimer;
    
    UIView *resultView;
    UIImageView *imgAvatar;
    UILabel *lbName;
    UILabel *lbPhone;
    UIButton *btnSearchNum;
    UIButton *btnChooseContact;
    
    NSMutableArray *listPhoneSearched;
    SearchContactPopupView *popupSearchContacts;
}

@end

@implementation DialerViewController
@synthesize viewStatus, imgLogoSmall, lbAccount, lbStatus, bgHeader, viewNumber, addressField, icClear;
@synthesize padView, oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, zeroButton, starButton, hashButton, lbSepa123, lbSepa456, lbSepa789, btnVideoCall, callButton, backspaceButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.hNav == 0) {
        appDelegate.hNav = self.navigationController.navigationBar.frame.size.height;
    }
    [self autoLayoutForView];
    [self createSearchViewIfNeed];
    
    //  Tap tren ban phim
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    [self.view addGestureRecognizer: tapOnScreen];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    [WriteLogsUtil writeForGoToScreen: @"DialerView"];
    
    //  set content for Fabric
    if (![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT]) {
        NSString *fabricInfo = SFM(@"%@ - %@:%@", USERNAME, SIP_DOMAIN, SIP_PORT);
        [[Crashlytics sharedInstance] setUserName:fabricInfo];
    }else{
        [[Crashlytics sharedInstance] setUserName:USERNAME];
    }
    
    NSString *total = SFM(@"%@%@%@", PASSWORD, appDelegate.randomKey, USERNAME);
    appDelegate.hashStr = [AppUtil getMD5StringOfString: total];
    
    [self registerObservers];
    [self checkCurrentSIPRegistrationState];
    
    //  update token of device if not yet
    if (!appDelegate.updateTokenSuccess && ![AppUtil isNullOrEmpty: appDelegate.deviceToken])
    {
        [appDelegate updateCustomerTokenIOS];
    }
    
    UIButton *test = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
    test.backgroundColor = UIColor.blackColor;
    [test addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: test];
}

- (void)testAction {
    [appDelegate my_send_request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)icClearClick:(UIButton *)sender {
    if (addressField.text.length > 0) {
        addressField.text = [addressField.text substringToIndex:[addressField.text length] - 1];
    }
    
    if (addressField.text.length > 0) {
        [addressField sendActionsForControlEvents: UIControlEventEditingChanged];
    }else{
        [self setupFrameForSearchResultWithExistsData: FALSE];
    }
}

- (IBAction)btnNumberPressed:(UIButton *)sender {
    [self.view endEditing: true];
    if (sender.tag == TAG_STAR_BUTTON) {
        addressField.text = SFM(@"%@*", addressField.text);
    }else if (sender.tag == TAG_HASH_BUTTON) {
        addressField.text = SFM(@"%@#", addressField.text);
    }else{
        addressField.text = SFM(@"%@%d", addressField.text, (int)sender.tag);
    }
    [addressField sendActionsForControlEvents: UIControlEventEditingChanged];
}

- (IBAction)btnCallPressed:(UIButton *)sender {
    if (addressField.text.length > 0) {
        [WriteLogsUtil writeLogContent:SFM(@"[%s] number: %@", __FUNCTION__, addressField.text)];
        
        [self setupFrameForSearchResultWithExistsData: FALSE];
        
        appDelegate.phoneForCall = addressField.text;
        [appDelegate getDIDListForCall];
        return;
    }
    
    [self fillPhoneNumberLastCall];
    
    [pressTimer invalidate];
    pressTimer = nil;
    pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                selector:@selector(searchPhoneBookWithThread)
                                                userInfo:nil repeats:false];
}

- (IBAction)btnVideoCallPress:(UIButton *)sender {
}

- (IBAction)onBackspaceClick:(id)sender {
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateChanged:)
                                                 name:notifRegistrationStateChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNetworkChanged)
                                                 name:networkChanged object:nil];
}

- (void)whenNetworkChanged {
    NetworkStatus internetStatus = [appDelegate.internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        lbStatus.text = text_no_network;
        lbStatus.textColor = UIColor.orangeColor;
    }else{
        if (![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD] && ![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT])
        {
            [appDelegate refreshSIPAccountRegistrationState];
        }
        //  [self checkAccountStateForApp];
    }
}

- (void)registrationStateChanged: (NSNotification *)notif {
    NSNumber *object = notif.object;
    if (object != nil && [object isKindOfClass:[NSNumber class]]) {
        int registrationCode = [object intValue];
        if (registrationCode == 200) {
            if ([AppUtil checkDoNotDisturbMode]) {
                lbStatus.text = text_do_not_disturb;
                lbStatus.textColor = UIColor.orangeColor;
            }else{
                lbStatus.text = text_online;
                lbStatus.textColor = UIColor.greenColor;
            }
        }else{
            lbStatus.textColor = UIColor.orangeColor;
            lbStatus.text = ([DeviceUtil checkNetworkAvailable]) ? text_offline : text_no_network;
        }
    }
}

- (void)checkCurrentSIPRegistrationState {
    if (![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD] && ![AppUtil isNullOrEmpty: SIP_DOMAIN] && ![AppUtil isNullOrEmpty: SIP_PORT])
    {
        NSString *sipNumber = [[NSUserDefaults standardUserDefaults] objectForKey:SIP_NUMBER];
        lbAccount.text = (![AppUtil isNullOrEmpty: sipNumber])? sipNumber : USERNAME;
        
        AccountState curState = [appDelegate checkSipStateOfAccount];
        if (curState == eAccountOn) {
            if ([AppUtil checkDoNotDisturbMode]) {
                lbStatus.text = text_do_not_disturb;
                lbStatus.textColor = UIColor.orangeColor;
            }else{
                lbStatus.text = text_online;
                lbStatus.textColor = UIColor.greenColor;
            }
        }else if (curState == eAccountOff) {
            lbStatus.text = text_offline;
            lbStatus.textColor = UIColor.redColor;
        }else{
            lbStatus.text = text_connecting;
            lbStatus.textColor = UIColor.whiteColor;
        }
    }else{
        lbAccount.text = @"";
        lbStatus.text = text_no_account;
    }
}

- (void)fillPhoneNumberLastCall {
    NSString *phoneNumber = [DatabaseUtil getLastCallOfUser];
    if (![AppUtil isNullOrEmpty: phoneNumber]) {
        if ([phoneNumber hasPrefix:@"+84"]) {
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
        }

        if ([phoneNumber hasPrefix:@"84"]) {
            phoneNumber = [phoneNumber substringFromIndex:2];
            phoneNumber = SFM(@"0%@", phoneNumber);
        }
        phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];

        addressField.text = phoneNumber;
        icClear.hidden = FALSE;
    }
}

- (void)dismissKeyboards {
    [self.view endEditing: TRUE];
}

- (void)createSearchViewIfNeed {
    if (resultView == nil) {
        resultView = [[UIView alloc] init];
        resultView.hidden = TRUE;
        resultView.layer.cornerRadius = 5.0;
        resultView.backgroundColor = GRAY_240;
        [viewNumber addSubview: resultView];
        
        float hSearch = [DeviceUtil getHeightSearchViewContactForDevice];
        float hAvatar = [DeviceUtil getHeightAvatarSearchViewForDevice];
        float wPopup = [DeviceUtil getWidthPoupSearchViewForDevice];
        
        [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(viewNumber.mas_centerX);
            make.bottom.equalTo(viewNumber);
            make.width.mas_equalTo(wPopup);
            make.height.mas_equalTo(hSearch);
        }];
        
        imgAvatar = [[UIImageView alloc] init];
        imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
        imgAvatar.layer.cornerRadius = hAvatar/2;
        imgAvatar.clipsToBounds = TRUE;
        [resultView addSubview: imgAvatar];
        [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(resultView.mas_centerY);
            make.left.equalTo(resultView).offset((hSearch-hAvatar)/2);
            make.width.height.mas_equalTo(hAvatar);
        }];
        
        btnSearchNum = [[UIButton alloc] init];
        [btnSearchNum setTitleColor:[UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                     blue:(70/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
        [btnSearchNum addTarget:self
                         action:@selector(showSearchPopupContact)
               forControlEvents:UIControlEventTouchUpInside];
        [resultView addSubview: btnSearchNum];
        [btnSearchNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(resultView);
            make.width.height.mas_equalTo(60.0);
        }];
        
        lbName = [[UILabel alloc] init];
        lbName.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
        lbName.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightBold];
        lbName.text = @"Khải Lê";
        [resultView addSubview: lbName];
        [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(resultView).offset(4.0);
            make.left.equalTo(imgAvatar.mas_right).offset(8.0);
            make.bottom.equalTo(imgAvatar.mas_centerY);
            make.right.equalTo(btnSearchNum.mas_left).offset(-8.0);
        }];
        
        lbPhone = [[UILabel alloc] init];
        lbPhone.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
        lbPhone.textColor = UIColor.darkGrayColor;
        lbPhone.text = @"036 343 0737";
        [resultView addSubview: lbPhone];
        [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imgAvatar.mas_centerY);
            make.left.right.equalTo(lbName);
            make.bottom.equalTo(resultView).offset(-4.0);
        }];
        
        btnChooseContact = [[UIButton alloc] init];
        btnChooseContact.backgroundColor = UIColor.clearColor;
        [btnChooseContact addTarget:self
                             action:@selector(selecteFirstContactForSearch)
                   forControlEvents:UIControlEventTouchUpInside];
        [resultView addSubview: btnChooseContact];
        [btnChooseContact mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(resultView);
            make.right.equalTo(btnSearchNum.mas_left);
        }];
    }
}

- (void)showSearchPopupContact {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    
    float totalHeight = listPhoneSearched.count * 60.0;
    if (totalHeight > SCREEN_HEIGHT - 70.0*2) {
        totalHeight = SCREEN_HEIGHT - 70.0*2;
    }
    popupSearchContacts = [[SearchContactPopupView alloc] initWithFrame:CGRectMake(30.0, (SCREEN_HEIGHT-totalHeight)/2, SCREEN_WIDTH-60.0, totalHeight)];
    popupSearchContacts.contacts = listPhoneSearched;
    [popupSearchContacts.tbContacts reloadData];
    popupSearchContacts.delegate = self;
    [popupSearchContacts showInView:appDelegate.window animated:YES];
}

- (void)autoLayoutForView {
    float marginStatus = 5.0;
    
    hAddressField = 60.0;
    if (!IS_IPHONE && !IS_IPOD) {
        hAddressField = 80.0;
    }else{
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator]) {   
            hAddressField = 80.0;
        }
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    //  view status
    viewStatus.backgroundColor = UIColor.clearColor;
    [viewStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate.hStatus + appDelegate.hNav);
    }];
    
    //  account label
    lbAccount.font = appDelegate.fontLargeMedium;
    lbAccount.textAlignment = NSTextAlignmentCenter;
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewStatus).offset(appDelegate.hStatus);
        make.bottom.equalTo(viewStatus);
        make.centerX.equalTo(viewStatus.mas_centerX);
        make.width.mas_equalTo(120);
    }];
    
    lbStatus.font = appDelegate.fontNormalRegular;
    lbStatus.numberOfLines = 0;
    [lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbAccount);
        make.left.equalTo(lbAccount.mas_right).offset(5.0);
        make.right.equalTo(viewStatus).offset(-marginStatus);
    }];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTappedOnStatusAccount)];
    lbStatus.userInteractionEnabled = TRUE;
    [lbStatus addGestureRecognizer: tapOnStatus];
    
    float hLogo = 27.0;
    UIImage *logoImg = [UIImage imageNamed:@"logo_transparent.png"];
    float wLogo = hLogo * logoImg.size.width / logoImg.size.height;
    imgLogoSmall.image = logoImg;
    [imgLogoSmall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewStatus).offset(marginStatus);
        make.centerY.equalTo(lbAccount.mas_centerY);
        make.height.mas_equalTo(hLogo);
        make.width.mas_equalTo(wLogo);
    }];
    
    //  pad view
    float wIcon = [DeviceUtil getSizeOfKeypadButtonForDevice];
    float spaceMarginY = [DeviceUtil getSpaceYBetweenKeypadButtonsForDevice];
    float spaceMarginX = [DeviceUtil getSpaceXBetweenKeypadButtonsForDevice];
    
    float hPadView = 5*wIcon + 6*spaceMarginY;
    padView.backgroundColor = UIColor.clearColor;
    [padView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(hPadView);
    }];
    
    //  1, 2, 3
    twoButton.layer.cornerRadius = oneButton.layer.cornerRadius = threeButton.layer.cornerRadius = fiveButton.layer.cornerRadius = fourButton.layer.cornerRadius = sixButton.layer.cornerRadius = eightButton.layer.cornerRadius = sevenButton.layer.cornerRadius = nineButton.layer.cornerRadius = zeroButton.layer.cornerRadius = starButton.layer.cornerRadius = callButton.layer.cornerRadius = backspaceButton.layer.cornerRadius = wIcon/2;
    
    twoButton.clipsToBounds = oneButton.clipsToBounds = threeButton.clipsToBounds = fiveButton.clipsToBounds = fourButton.clipsToBounds = sixButton.clipsToBounds = eightButton.clipsToBounds = sevenButton.clipsToBounds = nineButton.clipsToBounds = zeroButton.clipsToBounds = starButton.clipsToBounds = callButton.clipsToBounds = backspaceButton.clipsToBounds = TRUE;
    
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(padView).offset(0);
        make.centerX.equalTo(padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton.mas_top);
        make.right.equalTo(twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton.mas_top);
        make.left.equalTo(twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    //  4, 5, 6
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.right.equalTo(fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.left.equalTo(fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    //  7, 8, 9
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.right.equalTo(eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.left.equalTo(eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    //  *, 0, #
    UILongPressGestureRecognizer *zeroLongGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onZeroLongClick)];
    [zeroButton addGestureRecognizer:zeroLongGesture];
    
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.right.equalTo(zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    hashButton.layer.cornerRadius = wIcon/2;
    hashButton.clipsToBounds = TRUE;
    [hashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.left.equalTo(zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  fifth layer
    callButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    btnVideoCall.imageEdgeInsets = [DeviceUtil getEdgeOfVideoCallDialerForDevice];
    btnVideoCall.layer.cornerRadius = wIcon/2;
    btnVideoCall.clipsToBounds = TRUE;
    [btnVideoCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(callButton.mas_top);
        make.right.equalTo(callButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    backspaceButton.imageEdgeInsets = [DeviceUtil getEdgeOfVideoCallDialerForDevice];
    [backspaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(callButton.mas_top);
        make.left.equalTo(callButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    
    //  Number view
    [viewNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(viewStatus.mas_bottom);
        make.bottom.equalTo(padView.mas_top);
    }];
    
    [addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewNumber.mas_centerY);
        make.left.equalTo(self.view).offset(80);
        make.right.equalTo(self.view).offset(-80);
        make.height.mas_equalTo(hAddressField);
    }];
    addressField.keyboardType = UIKeyboardTypePhonePad;
    addressField.enabled = TRUE;
    addressField.textAlignment = NSTextAlignmentCenter;
    addressField.font = [UIFont fontWithName:HelveticaNeue size:45.0];
    addressField.adjustsFontSizeToFitWidth = TRUE;
    [addressField addTarget:self
                      action:@selector(addressfieldDidChanged:)
            forControlEvents:UIControlEventEditingChanged];
    
    icClear.hidden = TRUE;
    icClear.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [icClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addressField.mas_centerY);
        make.left.equalTo(addressField.mas_right);
        make.width.height.mas_equalTo(50.0);
    }];
    UILongPressGestureRecognizer *clearLongGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onClearButtonLongClick)];
    [icClear addGestureRecognizer:clearLongGesture];
    
    
    lbSepa123.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0];
    lbSepa456.backgroundColor = lbSepa789.backgroundColor = lbSepa123.backgroundColor;
    
    [lbSepa123 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(oneButton);
        make.right.equalTo(threeButton.mas_right);
        make.top.equalTo(oneButton.mas_bottom).offset(spaceMarginY/2);
        make.height.mas_equalTo(1.0);
    }];
    
    [lbSepa456 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbSepa123);
        make.top.equalTo(fiveButton.mas_bottom).offset(spaceMarginY/2);
        make.height.equalTo(lbSepa123.mas_height);
    }];
    
    [lbSepa789 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbSepa123);
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY/2);
        make.height.equalTo(lbSepa123.mas_height);
    }];
    
    btnVideoCall.hidden = backspaceButton.hidden = TRUE;
}

- (void)onZeroLongClick {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    
    // replace last character with a '+'
    NSString *newAddress = [[addressField.text substringToIndex:[addressField.text length] - 1] stringByAppendingString:@"+"];
    addressField.text = newAddress;
    [addressField sendActionsForControlEvents: UIControlEventEditingChanged];
}

- (void)onClearButtonLongClick {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    
    addressField.text = @"";
    resultView.hidden = TRUE;
    [self setupFrameForSearchResultWithExistsData: FALSE];
}

- (void)searchPhoneBookWithThread {
    if (!appDelegate.contactLoaded) {
        [WriteLogsUtil writeLogContent:SFM(@"[%s] >>>>>>>>>>>>>> CONTACTS HAVE NOT READY YET <<<<<<<<<<<<<<<<<", __FUNCTION__)];
        return;
    }
    
    NSString *searchStr = addressField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //  remove data before search
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];

        NSArray *searchArr = [self searchAllContactsWithString:searchStr inList:appDelegate.listInfoPhoneNumber];
        if (searchArr.count > 0) {
            [listPhoneSearched addObjectsFromArray: searchArr];
        }

        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self searchContactDone];
        });
    });
}

// Search duoc danh sach
- (void)searchContactDone
{
    if (addressField.text.length > 0) {
        //  [khai le - 02/11/2018]
        if (listPhoneSearched.count > 0) {
            [self setupFrameForSearchResultWithExistsData: TRUE];
            [self showSearchResultOnSearchView: listPhoneSearched];
        }else{
            [self setupFrameForSearchResultWithExistsData: FALSE];
        }
    }else{
        [self setupFrameForSearchResultWithExistsData: FALSE];
    }
}

- (void)showSearchResultOnSearchView: (NSArray *)searchArr {
    if (searchArr.count > 0) {
        PhoneObject *contact = [searchArr firstObject];
        if (![AppUtil isNullOrEmpty: contact.avatar]) {
            imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: contact.avatar]];
        }else{
            imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
        }
        
        if (![AppUtil isNullOrEmpty: contact.name]) {
            lbName.text = contact.name;
        }else{
            lbName.text = text_unknown;
        }
        lbPhone.text = contact.number;
        
        if (searchArr.count > 1) {
            [btnSearchNum setTitle:SFM(@"(%d)", (int)listPhoneSearched.count) forState:UIControlStateNormal];
            btnSearchNum.enabled = TRUE;
        }else{
            [btnSearchNum setTitle:@"" forState:UIControlStateNormal];
            btnSearchNum.enabled = FALSE;
        }
    }
}

- (NSArray *)searchAllContactsWithString: (NSString *)search inList: (NSArray *)list {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR number CONTAINS[cd] %@ OR nameForSearch CONTAINS[cd] %@", search, search, search];
    NSArray *filter = [list filteredArrayUsingPredicate: predicate];
    return filter;
}

- (void)addressfieldDidChanged: (UITextField *)textfield {
    if ([textfield.text isEqualToString:@""]) {
        resultView.hidden = TRUE;
    }else{
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }
}

- (void)setupFrameForSearchResultWithExistsData: (BOOL)hasData {
    if (hasData) {
        resultView.hidden = FALSE;
        [addressField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewNumber);
            make.bottom.equalTo(resultView.mas_top);
            make.left.equalTo(self.view).offset(80);
            make.right.equalTo(self.view).offset(-80);
        }];
    }else{
        resultView.hidden = TRUE;
        [addressField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(viewNumber.mas_centerY);
            make.left.equalTo(self.view).offset(80);
            make.right.equalTo(self.view).offset(-80);
            make.height.mas_equalTo(hAddressField);
        }];
    }
    icClear.hidden = (addressField.text.length > 0) ? FALSE : TRUE;
}

- (void)selecteFirstContactForSearch {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    [self.view endEditing: TRUE];
    
    if (listPhoneSearched.count > 0) {
        PhoneObject *contact = [listPhoneSearched firstObject];
        addressField.text = contact.number;
        
        [self setupFrameForSearchResultWithExistsData: FALSE];
    }
}

- (void)selectContactFromSearchPopup:(NSString *)phoneNumber {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] phoneNumber: %@", __FUNCTION__, phoneNumber)];
    
    addressField.text = phoneNumber;
    [self setupFrameForSearchResultWithExistsData: FALSE];
}

- (void)whenTappedOnStatusAccount {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    
    if (![DeviceUtil checkNetworkAvailable]){
        [self.view makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter];
        return;
    }
    [appDelegate refreshSIPAccountRegistrationState];
    if ([AppUtil checkDoNotDisturbMode]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"Chế độ Không làm phiền đang được bật, bạn sẽ không nhận được cuộc gọi vào lúc này!\nBạn có muốn tắt chế độ này không?"];
        [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontNormalRegular range:NSMakeRange(0, attrTitle.string.length)];
        [alertVC setValue:attrTitle forKey:@"attributedTitle"];
        
        UIAlertAction *btnClose = [UIAlertAction actionWithTitle:text_close style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [btnClose setValue:BLUE_COLOR forKey:@"titleTextColor"];
        
        UIAlertAction *btnDelete = [UIAlertAction actionWithTitle:text_off style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        [AppUtil enableDoNotDisturbMode: FALSE];
                                        [appDelegate refreshSIPAccountRegistrationState];
                                    }];
        [btnDelete setValue:UIColor.redColor forKey:@"titleTextColor"];
        [alertVC addAction:btnClose];
        [alertVC addAction:btnDelete];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

@end

//
//  SignInViewController.m
//  linphone
//
//  Created by lam quang quan on 2/25/19.
//

#import "SignInViewController.h"
#import "AppTabbarViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import "WebServiceUtil.h"
#import "CustomTextAttachment.h"

@interface SignInViewController ()<WebServiceUtilDelegate, UITextFieldDelegate>{
    AppDelegate *appDelegate;
    QRCodeReaderViewController *scanQRCodeVC;
    UIButton *btnScanFromPhoto;
    
    WebServiceUtil *webService;
    NSString *port;
    NSString *domain;
    
    NSTimer *loginTimer;
}
@end

@implementation SignInViewController
@synthesize viewWelcome, imgWelcome, imgLogoWelcome, lbSlogan, btnStart;
@synthesize viewSignIn, iconBack, imgLogo, lbHeader, btnAccountID, tfAccountID, btnPassword, tfPassword, btnSignIn, btnQRCode, btnShowPass;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self newSetupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    if (webService == nil) {
        webService = [[WebServiceUtil alloc] init];
        webService.delegate = self;
    }
    [WriteLogsUtil writeForGoToScreen:@"SignInViewController"];
    
    domain = @"";
    port = @"";
    
    [self registerObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    //  [self showWelcomeView];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSignInPress:(UIButton *)sender {
    if ([AppUtil isNullOrEmpty: tfAccountID.text] || [AppUtil isNullOrEmpty: tfPassword.text]) {
        [self.view makeToast:pls_fill_full_info duration:2.0 position:CSToastPositionCenter];
        return;
    }
    [sender setTitleColor:[UIColor colorWithRed:(50/255.0) green:(196/255.0) blue:(124/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    sender.backgroundColor = UIColor.whiteColor;

    [self performSelector:@selector(startLogin:) withObject:sender afterDelay:0.15];
}

- (IBAction)btnShowPassPress:(UIButton *)sender {
    if (tfPassword.secureTextEntry) {
        [sender setImage:[UIImage imageNamed:@"ic_show_pass"] forState:UIControlStateNormal];
        tfPassword.secureTextEntry = FALSE;
    }else{
        [sender setImage:[UIImage imageNamed:@"ic_hide_pass"] forState:UIControlStateNormal];
        tfPassword.secureTextEntry = TRUE;
    }
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateChanged:)
                                                 name:notifRegistrationStateChange object:nil];
}

- (void)registrationStateChanged: (NSNotification *)notif {
    NSNumber *object = notif.object;
    if (object != nil && [object isKindOfClass:[NSNumber class]]) {
        int registrationCode = [object intValue];
        [WriteLogsUtil writeLogContent:SFM(@"[%s] registration state: %d", __FUNCTION__, registrationCode)];
        [ProgressHUD dismiss];
        [self clearLoginTimerIfNeed];
        
        if (registrationCode == 200) {
            [self registrationSIPAccountSuccessfully];
        }else{
            [self.view makeToast:pls_check_signin_info duration:2.0 position:CSToastPositionCenter style: appDelegate.errorStyle];
        }
    }
}

- (void)registrationSIPAccountSuccessfully {
    [WriteLogsUtil writeLogContent:SFM(@">>>>>>>>>>>>>>>>>>> [%s] <<<<<<<<<<<<<<<<<<<<<<<<", __FUNCTION__)];
    
    [[NSUserDefaults standardUserDefaults] setObject:tfAccountID.text forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:tfPassword.text forKey:key_password];
    [[NSUserDefaults standardUserDefaults] setObject:domain forKey:key_domain];
    [[NSUserDefaults standardUserDefaults] setObject:port forKey:key_port];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppTabbarViewController *tabbarVC = [[AppTabbarViewController alloc] init];
    [self presentViewController:tabbarVC animated:TRUE completion:nil];
}

- (void)startLogin: (UIButton *)sender {
    [sender setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    sender.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(196/255.0) blue:(124/255.0) alpha:1.0];

    //  start register pbx
    [self.view endEditing: TRUE];
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:text_waiting Interaction:NO];
    
    NSString *total = SFM(@"%@%@%@", tfPassword.text, appDelegate.randomKey, tfAccountID.text);
    appDelegate.hashStr = [AppUtil getMD5StringOfString: total];

    NSString *params = SFM(@"username=%@", tfAccountID.text);
    [webService callWebServiceWithFunction:login_func withParams:params inBackgroundMode:FALSE];
}

- (IBAction)iconBackPress:(UIButton *)sender {
    [self showWelcomeView];
}

- (BOOL)checkAccountLoginInformationReady {
    if (![AppUtil isNullOrEmpty: tfAccountID.text] && ![AppUtil isNullOrEmpty: tfPassword.text]) {
        return TRUE;
    }
    return FALSE;
}

- (void)showWelcomeView {
    [self.view endEditing: TRUE];
    
    [viewWelcome mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    [viewSignIn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];
  
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)whenTextfieldDidChange:(UITextField *)textfield {
    BOOL ready = [self checkAccountLoginInformationReady];
    if (ready) {
        btnSignIn.enabled = TRUE;
        btnSignIn.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(196/255.0) blue:(124/255.0) alpha:1.0];
        btnSignIn.layer.borderColor = btnSignIn.backgroundColor.CGColor;
    }else{
        btnSignIn.enabled = NO;
        btnSignIn.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(238/255.0) blue:(243/255.0) alpha:1.0];
        btnSignIn.layer.borderColor = btnSignIn.backgroundColor.CGColor;
    }
}

- (void)newSetupUIForView {
    //  Welcome view
    viewWelcome.backgroundColor = GRAY_235;
    viewWelcome.clipsToBounds = TRUE;
    [viewWelcome mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    float wImgWelcome;
    if (IS_IPHONE || IS_IPOD) {
        wImgWelcome = SCREEN_WIDTH*4/6;
    }else{
        wImgWelcome = 300.0;
    }
    
    float mTopLogoWelcome = 20.0;
    float hLogo;
    float hLogoColor = 60.0;
    float marginSlogan = 40.0;
    float wButtonStart = 180;
    float hButtonStart = 55.0;
    float topHeader = 20.0;
    float accMargin = 30.0;
    float hSepa = 45.0;
    float hTextfield = 42.0;
    float edge = 8.0;
    float sizeIconQR = 24.0;
    float edgeBack = 12.0;
    float padding = 30.0;
    float btnMarginTop = 20.0;
    
    if (!IS_IPHONE && !IS_IPOD) {
        //  Screen width: 375.000000 - Screen height: 812.000000;
        hLogo = 60.0;
        marginSlogan = 30.0;
        
        padding = 50.0;
        hLogoColor = 50.0;
        accMargin = 20.0;
        hTextfield = 50.0;
        btnMarginTop = 40.0;
        edge = 10.0;
        
    }else{
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            wImgWelcome = 190.0;
            hLogo = 50.0;
            hTextfield = 40.0;
            hSepa = 20.0;
            topHeader = 10.0;
            
            //  Screen width: 320.000000 - Screen height: 667.000000
            marginSlogan = 20.0;
            wButtonStart = 150.0;
            hButtonStart = 40.0;
            
            padding = 30.0;
            hLogoColor = 40.0;
            accMargin = 5.0;
            
            edge = 10.0;
            sizeIconQR = 20.0;
            btnMarginTop = 20.0;
            
            
            edgeBack = 15.0;
            
            
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            wImgWelcome = 230.0;
            hLogo = 60.0;
            hLogoColor = 60.0;
            
            hButtonStart = 47.0;
            hTextfield = 45.0;
            
            //  Screen width: 375.000000 - Screen height: 667.000000
            marginSlogan = 30.0;
            wButtonStart = 170.0;
            
            padding = 25.0;
            accMargin = 10.0;
            edgeBack = 14.0;
            edge = 9.0;
            
            
            btnMarginTop = 20.0;
            
            
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
        {
            wImgWelcome = 230.0;
            hLogo = 65.0;
            hButtonStart = 47.0;
            mTopLogoWelcome = 30.0;
            hTextfield = 45.0;
            hLogoColor = 50.0;
            
            //  Screen width: 414.000000 - Screen height: 736.000000
            
            
            padding = 30.0;
            
            edgeBack = 14.0;
            edge = 12.0;
            
            accMargin = 20.0;
            
            btnMarginTop = 30.0;
            
            
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
        {
            wImgWelcome = 230.0;
            hLogo = 70.0;
            hButtonStart = 47.0;
            mTopLogoWelcome = 50.0;
            hLogoColor = 60.0;
            hTextfield = 47.0;
            
            //  Screen width: 375.000000 - Screen height: 812.000000;
            marginSlogan = 30.0;
            
            padding = 30.0;
            accMargin = 20.0;
            btnMarginTop = 30.0;
            
        }else{
            //  Screen width: 375.000000 - Screen height: 812.000000;
            hLogo = 55.0;
            marginSlogan = 30.0;
            
            padding = 30.0;
            hLogoColor = 50.0;
            accMargin = 20.0;
            
        }
    }
    
    UIImage *logoImg = [UIImage imageNamed:@"logo_transparent.png"];
    float wLogo = logoImg.size.width * hLogo / logoImg.size.height;
    [imgLogoWelcome mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewWelcome.mas_centerX);
        make.centerY.equalTo(viewWelcome.mas_centerY);
        make.width.mas_equalTo(wLogo);
        make.height.mas_equalTo(hLogo);
    }];
    
    imgWelcome.clipsToBounds = TRUE;
    imgWelcome.layer.cornerRadius = wImgWelcome/2;
    imgWelcome.layer.borderWidth = 5.0;
    imgWelcome.layer.borderColor = [UIColor colorWithRed:(246/255.0) green:(183/255.0) blue:(150/255.0) alpha:1.0].CGColor;
    [imgWelcome mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewWelcome.mas_centerX);
        make.bottom.equalTo(imgLogoWelcome.mas_top).offset(-mTopLogoWelcome);
        make.width.height.mas_equalTo(wImgWelcome);
    }];
    
    CGSize textSize = [AppUtil getSizeWithText:text_slogent withFont:appDelegate.fontLargeRegular andMaxWidth:(SCREEN_WIDTH-50.0)];
    
    lbSlogan.font = appDelegate.fontLargeRegular;
    lbSlogan.text = text_slogent;
    lbSlogan.numberOfLines = 5;
    lbSlogan.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbSlogan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgLogoWelcome.mas_bottom).offset(marginSlogan);
        make.left.equalTo(viewWelcome).offset(5.0);
        make.right.equalTo(viewWelcome).offset(-5.0);
        make.height.mas_equalTo(textSize.height + 10);
    }];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, wButtonStart, hButtonStart);
    gradient.colors = @[(id)[UIColor colorWithRed:(154/255.0) green:(215/255.0) blue:(9/255.0) alpha:1.0].CGColor, (id)[UIColor colorWithRed:(60/255.0) green:(198/255.0) blue:(116/255.0) alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(1, 0);
    gradient.endPoint = CGPointMake(0, 1);
    
    [btnStart.layer insertSublayer:gradient atIndex:0];
    [btnStart setTitle:text_start forState:UIControlStateNormal];
    [btnStart setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnStart.layer.cornerRadius = 7.0;
    btnStart.clipsToBounds = TRUE;
    btnStart.backgroundColor = [UIColor colorWithRed:(154/255.0) green:(215/255.0) blue:(9/255.0) alpha:1.0];
    btnStart.titleLabel.font = appDelegate.fontLargeRegular;
    float wBTN = [AppUtil getSizeWithText:btnStart.currentTitle withFont:btnStart.titleLabel.font].width + 50.0;
    [btnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewWelcome.mas_centerX);
        make.top.equalTo(lbSlogan.mas_bottom).offset(mTopLogoWelcome);
        make.width.mas_equalTo(wBTN);
        make.height.mas_equalTo(hButtonStart);
    }];
    
    //  view sign in
    viewSignIn.clipsToBounds = TRUE;
    [viewSignIn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.view);
        make.width.mas_equalTo(0);
    }];
    
    logoImg = [UIImage imageNamed:@"logo_color.png"];
    wLogo = logoImg.size.width * hLogoColor / logoImg.size.height;
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewSignIn.mas_centerX);
        make.top.equalTo(viewSignIn).offset(appDelegate.hStatus + 5.0);
        make.width.mas_equalTo(wLogo);
        make.height.mas_equalTo(hLogoColor);
    }];
    
    iconBack.imageEdgeInsets = UIEdgeInsetsMake(edgeBack, edgeBack, edgeBack, edgeBack);
    [iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imgLogo.mas_centerY);
        make.left.equalTo(viewSignIn);
        make.width.height.mas_equalTo(50.0);
    }];
    
    NSString *headerContent = text_welcome;
    headerContent = [headerContent stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    textSize = [AppUtil getSizeWithText:headerContent withFont:appDelegate.fontLargeMedium andMaxWidth:(SCREEN_WIDTH - 2*padding)];
    lbHeader.text = headerContent;
    lbHeader.numberOfLines = 0;
    lbHeader.font = appDelegate.fontLargeMedium;
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgLogo.mas_bottom).offset(topHeader);
        make.left.equalTo(viewSignIn).offset(padding);
        make.right.equalTo(viewSignIn).offset(-padding);
        make.height.mas_equalTo(textSize.height + 20);
    }];
    
    //  account textfield
    float textfieldPadding;
    if (IS_IPOD || IS_IPHONE) {
        textfieldPadding = 10.0;
    }else{
        textfieldPadding = 20.0;
    }
    
    tfAccountID.font = tfPassword.font = appDelegate.fontNormalRegular;
    tfAccountID.textColor = tfPassword.textColor = UIColor.blackColor;
    tfAccountID.borderStyle = tfPassword.borderStyle = UITextBorderStyleNone;
    tfAccountID.delegate = tfPassword.delegate = self;
    tfAccountID.returnKeyType = tfPassword.returnKeyType = UIReturnKeyNext;
    
    tfAccountID.placeholder = text_account;
    [tfAccountID addTarget:self
                    action:@selector(whenTextfieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    [tfAccountID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbHeader.mas_bottom).offset(accMargin);
        make.left.right.equalTo(lbHeader);
        make.height.mas_equalTo(hTextfield);
    }];
    
    tfAccountID.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield-edge, hTextfield)];
    tfAccountID.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *lbAccount = [[UILabel alloc] init];
    lbAccount.backgroundColor = GRAY_220;
    [viewSignIn addSubview: lbAccount];
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnAccountID).offset(edge);
        make.bottom.equalTo(tfAccountID.mas_bottom);
        make.right.equalTo(tfAccountID);
        make.height.mas_equalTo(1.0);
    }];
    
    btnAccountID.enabled = FALSE;
    [btnAccountID setImage:[UIImage imageNamed:@"icon_acc"] forState:UIControlStateDisabled];
    btnAccountID.imageEdgeInsets = UIEdgeInsetsMake(edge,edge, edge, edge);
    [btnAccountID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tfAccountID).offset(-edge);
        make.top.bottom.equalTo(tfAccountID);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  password textfield
    tfPassword.placeholder = text_password;
    [tfPassword addTarget:self
                   action:@selector(whenTextfieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    
    tfPassword.secureTextEntry = TRUE;
    [tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfAccountID.mas_bottom).offset(textfieldPadding);
        make.left.right.equalTo(tfAccountID);
        make.height.mas_equalTo(hTextfield);
    }];
    tfPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield-edge, hTextfield)];
    tfPassword.leftViewMode = UITextFieldViewModeAlways;
    
    tfPassword.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfPassword.rightViewMode = UITextFieldViewModeAlways;
    
    //  show, hide password
    btnShowPass.tag = 0;
    btnShowPass.imageEdgeInsets = UIEdgeInsetsMake(6,6, 6, 6);
    [btnShowPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tfPassword).offset(edge);
        make.top.bottom.equalTo(tfPassword);
        make.width.mas_equalTo(hTextfield);
    }];
    
    UILabel *lbPassword = [[UILabel alloc] init];
    lbPassword.backgroundColor = lbAccount.backgroundColor;
    [viewSignIn addSubview: lbPassword];
    [lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnPassword).offset(edge);
        make.right.equalTo(tfPassword);
        make.bottom.equalTo(tfPassword.mas_bottom);
        make.height.mas_equalTo(1.0);
    }];
    
    btnPassword.enabled = FALSE;
    [btnPassword setImage:[UIImage imageNamed:@"icon_pass"] forState:UIControlStateDisabled];
    btnPassword.imageEdgeInsets = UIEdgeInsetsMake(edge,edge, edge, edge);
    [btnPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tfPassword).offset(-edge);
        make.top.left.bottom.equalTo(tfPassword);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  signin button
    btnSignIn.enabled = NO;
    [btnSignIn setTitle:text_sign_in forState:UIControlStateNormal];
    btnSignIn.titleLabel.font = appDelegate.fontNormalRegular;
    btnSignIn.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(238/255.0) blue:(243/255.0) alpha:1.0];
    btnSignIn.layer.borderColor = [UIColor colorWithRed:(234/255.0) green:(238/255.0) blue:(243/255.0) alpha:1.0].CGColor;
    btnSignIn.layer.borderWidth = 1.0;
    [btnSignIn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSignIn setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    btnSignIn.layer.cornerRadius = 5.0;
    [btnSignIn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPassword.mas_bottom).offset(btnMarginTop);
        make.left.right.equalTo(tfPassword);
        make.height.mas_equalTo(hTextfield);
    }];
    
    float hDot = 3.0;
    UILabel *lbDot1 = [[UILabel alloc] init];
    [viewSignIn addSubview: lbDot1];
    [lbDot1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnSignIn.mas_bottom).offset((hSepa-hDot)/2);
        make.centerX.equalTo(viewSignIn.mas_centerX);
        make.width.height.mas_equalTo(hDot);
    }];
    
    UILabel *lbDot2 = [[UILabel alloc] init];
    [viewSignIn addSubview: lbDot2];
    [lbDot2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbDot1);
        make.right.equalTo(lbDot1.mas_left).offset(-4.0);
        make.width.mas_equalTo(hDot);
    }];
    
    UILabel *lbDot3 = [[UILabel alloc] init];
    [viewSignIn addSubview: lbDot3];
    [lbDot3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbDot1);
        make.left.equalTo(lbDot1.mas_right).offset(4.0);
        make.width.mas_equalTo(hDot);
    }];
    
    lbDot1.clipsToBounds = lbDot2.clipsToBounds = lbDot3.clipsToBounds = TRUE;
    lbDot1.layer.cornerRadius = lbDot2.layer.cornerRadius = lbDot3.layer.cornerRadius = hDot/2;
    lbDot1.backgroundColor = lbDot2.backgroundColor = lbDot3.backgroundColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    
    [btnQRCode setAttributedTitle:[self getQRCodeTitleContentWithFont: appDelegate.fontNormalRegular andSizeIcon:sizeIconQR] forState:UIControlStateNormal];
    btnQRCode.titleLabel.font = appDelegate.fontNormalRegular;
    btnQRCode.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(238/255.0) blue:(243/255.0) alpha:1.0];
    btnQRCode.layer.cornerRadius = 5.0;
    [btnQRCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbDot1.mas_bottom).offset((hSepa-hDot)/2);
        make.left.right.equalTo(btnSignIn);
        make.height.equalTo(btnSignIn.mas_height);
    }];
}

- (IBAction)btnQRCodePress:(UIButton *)sender {
    //  [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([DeviceUtil isAvailableVideo]) {
        QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        scanQRCodeVC = [QRCodeReaderViewController readerWithCancelButtonTitle:text_cancel codeReader:reader startScanningAtLoad:TRUE showSwitchCameraButton:TRUE showTorchButton:TRUE];
        scanQRCodeVC.modalPresentationStyle = UIModalPresentationFormSheet;
        scanQRCodeVC.delegate = self;
        
        btnScanFromPhoto = [UIButton buttonWithType: UIButtonTypeCustom];
        btnScanFromPhoto.frame = CGRectMake((SCREEN_WIDTH-250)/2, SCREEN_HEIGHT-38-60, 250, 38);
        btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                            blue:(70/255.0) alpha:1.0];
        [btnScanFromPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnScanFromPhoto.layer.cornerRadius = btnScanFromPhoto.frame.size.height/2;
        btnScanFromPhoto.layer.borderColor = btnScanFromPhoto.backgroundColor.CGColor;
        btnScanFromPhoto.layer.borderWidth = 1.0;
        
        [btnScanFromPhoto setTitle:text_scan_from_photo forState:UIControlStateNormal];
        btnScanFromPhoto.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [btnScanFromPhoto addTarget:self
                             action:@selector(btnScanFromPhotoPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
        [scanQRCodeVC.view addSubview: btnScanFromPhoto];
        
        [scanQRCodeVC setCompletionWithBlock:^(NSString *resultAsString) {
            
        }];
        [self presentViewController:scanQRCodeVC animated:TRUE completion:NULL];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:@"Ứng dụng không thể truy cập vào camera của bạn. Vui lòng kiểm tra lại!"];
        [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontNormalRegular range:NSMakeRange(0, attrTitle.string.length)];
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
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)btnScanFromPhotoPressed {
    //  [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    btnScanFromPhoto.backgroundColor = [UIColor whiteColor];
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                     blue:(70/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [self performSelector:@selector(choosePictureForScanQRCode) withObject:nil afterDelay:0.05];
}

- (void)choosePictureForScanQRCode {
    //  [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                        blue:(70/255.0) alpha:1.0];
    [btnScanFromPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [scanQRCodeVC presentViewController:pickerController animated:TRUE completion:nil];
}

#pragma mark - Image picker delegate
- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    //  [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        [tfAccountID becomeFirstResponder];
    }];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];

    [self dismissViewControllerAnimated:TRUE completion:^{
        [WriteLogsUtil writeLogContent:SFM(@"[%s] result: %@", __FUNCTION__, result)];

        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:text_waiting Interaction:NO];

        [self checkRegistrationInfoFromQRCode: result];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//    [picker dismissViewControllerAnimated:TRUE completion:^{
//        [self dismissViewControllerAnimated:TRUE completion:NULL];
//        NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
//        if ([type isEqualToString: (NSString*)kUTTypeImage] ) {
//            [self hideWaitingView: NO];
//            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//            [self getQRCodeContentFromImage: image];
//        }
//    }];
}

- (void)getQRCodeContentFromImage: (UIImage *)image {
//    [WriteLogsUtils writeLogContent:SFM(@"[%s]", __FUNCTION__) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//    NSArray *qrcodeContent = [self detectQRCode: image];
//    if (qrcodeContent != nil && qrcodeContent.count > 0) {
//        for (CIQRCodeFeature* qrFeature in qrcodeContent)
//        {
//            [self checkRegistrationInfoFromQRCode: qrFeature.messageString];
//            break;
//        }
//    }else{
//        [self showDialerQRCodeNotCorrect];
//    }
}

- (NSArray *)detectQRCode:(UIImage *) image
{
    @autoreleasepool {
        CIImage* ciImage = [[CIImage alloc] initWithCGImage: image.CGImage]; // to use if the underlying data is a CGImage
        NSDictionary* options;
        CIContext* context = [CIContext context];
        options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        //options = @{ CIDetectorAccuracy : CIDetectorAccuracyLow}; // Fast but superficial
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        return features;
    }
}

- (void)checkRegistrationInfoFromQRCode: (NSString *)qrcodeResult {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] qrcodeResult: %@", __FUNCTION__, qrcodeResult)];

    if (![AppUtil isNullOrEmpty: qrcodeResult]) {
        if (qrcodeResult.length > 5) {
            NSString *password = [qrcodeResult substringFromIndex: 5];

            NSString *total = SFM(@"%@%@%@", password, appDelegate.randomKey, qrcodeResult);
            appDelegate.hashStr = [AppUtil getMD5StringOfString: total];

            NSString *params = SFM(@"hashstring=%@", qrcodeResult);
            [webService callWebServiceWithFunction:decryptRSA_func withParams:params inBackgroundMode:TRUE];
            return;
        }
    }
    [ProgressHUD dismiss];
    [self.view makeToast:cannot_detect_QRCode duration:2.0 position:CSToastPositionCenter];
}

- (IBAction)btnStartPress:(UIButton *)sender {
    sender.enabled = FALSE;
    [sender setTitleColor:[UIColor colorWithRed:(60/255.0) green:(198/255.0) blue:(116/255.0) alpha:1.0] forState:UIControlStateNormal];
    [self performSelector:@selector(goToLoginScreen:) withObject:sender afterDelay:0.1];
}

- (void)goToLoginScreen: (UIButton *)sender
{
    if (![AppUtil isNullOrEmpty: USERNAME]) {
        tfAccountID.text = USERNAME;
        [tfPassword becomeFirstResponder];
    }else{
        [tfAccountID becomeFirstResponder];
    }

    sender.enabled = TRUE;
    [sender setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

    BOOL ready = [self checkAccountLoginInformationReady];
    if (ready) {
        btnSignIn.enabled = TRUE;
        btnSignIn.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(196/255.0) blue:(124/255.0) alpha:1.0];
        btnSignIn.layer.borderColor = btnSignIn.backgroundColor.CGColor;
    }else{
        btnSignIn.enabled = FALSE;
        btnSignIn.backgroundColor = [UIColor colorWithRed:(234/255.0) green:(238/255.0) blue:(243/255.0) alpha:1.0];
        btnSignIn.layer.borderColor = btnSignIn.backgroundColor.CGColor;
    }

    [viewWelcome mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];

    [viewSignIn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];

    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (NSAttributedString *)getQRCodeTitleContentWithFont: (UIFont *)textFont andSizeIcon: (float)size
{
    CustomTextAttachment *attachment = [[CustomTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"qrcode.png"];
    [attachment setImageHeight: size];

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];

    NSString *content = SFM(@" %@", or_sign_in_with_QRCode);
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
    [contentString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, contentString.length)];
    [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0] range:NSMakeRange(0, contentString.length)];

    NSMutableAttributedString *verString = [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
    //
    [verString appendAttributedString: contentString];
    return verString;
}

- (void)processingWithQRCodeInfo: (NSDictionary *)info {
    domain = [info objectForKey:@"domain"];
    port = [info objectForKey:@"port"];
    if ([port isKindOfClass:[NSNumber class]]) {
        port = SFM(@"%d", [port intValue]);
    }
    NSString *account = [info objectForKey:@"username"];
    NSString *password = [info objectForKey:@"password"];
    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: password] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: domain])
    {
        tfAccountID.text = account;
        tfPassword.text = password;

        [self startTimerToCheckRegisterSIP];
        
        NSDictionary *accInfo = [[NSDictionary alloc] initWithObjectsAndKeys:domain, @"domain", port, @"port", account, @"account", password, @"password", nil];
        [appDelegate registerSIPAccountWithInfo: accInfo];
    }else{
        [ProgressHUD dismiss];
        [self.view makeToast:cannot_detect_QRCode duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)startTimerToCheckRegisterSIP {
    if (loginTimer != nil) {
        [loginTimer invalidate];
        loginTimer = nil;
    }
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(cannotRegisterSIP) userInfo:nil repeats:NO];
}

- (void)clearLoginTimerIfNeed {
    if (loginTimer != nil) {
        [loginTimer invalidate];
        loginTimer = nil;
    }
}

- (void)cannotRegisterSIP {
    [self clearLoginTimerIfNeed];

    [ProgressHUD dismiss];

    [self.view makeToast:@"Không thể đăng nhập. Vui lòng kiểm tra thông tin tài khoản!" duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - WebServiceUtil delegate
-(void)signInSuccessfullyWithData:(id)data {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] data: %@", __FUNCTION__, @[data])];
    if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
        domain = [data objectForKey:@"domain"];
        port = [data objectForKey:@"port"];
        if ([port isKindOfClass:[NSNumber class]]) {
            port = SFM(@"%d", [port intValue]);
        }
        //  Lấy thông tin domain port thành công thì startPjsua với port vừa get đc
        [[NSUserDefaults standardUserDefaults] setObject:port forKey:key_port];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [appDelegate checkToRestartPjsuaForApp];
        
        [self startTimerToCheckRegisterSIP];
        
        NSDictionary *accInfo = [[NSDictionary alloc] initWithObjectsAndKeys:domain, @"domain", port, @"port", tfAccountID.text, @"account", tfPassword.text, @"password", nil];
        [appDelegate registerSIPAccountWithInfo: accInfo];
    }
}

-(void)failedToSignInWithError:(id)error {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] error: %@", __FUNCTION__, @[error])];
    [ProgressHUD dismiss];
    
    [self.view makeToast:user_or_pass_is_wrong duration:2.0 position:CSToastPositionCenter];
}

-(void)failedToDecryptRSAAccountWithError:(id)error {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] error: %@", __FUNCTION__, @[error])];
    
    [ProgressHUD dismiss];
    [self.view makeToast:cannot_detect_QRCode duration:2.0 position:CSToastPositionCenter];
}

-(void)decryptRSAAccountSuccessfullyWithData:(id)data {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] data: %@", __FUNCTION__, @[data])];
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        [self processingWithQRCodeInfo: data];
    }
}

#pragma mark - Textfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfAccountID) {
        [tfPassword becomeFirstResponder];
        
    }else if (textField == tfPassword) {
        [tfAccountID becomeFirstResponder];
    }
    return TRUE;
}

@end

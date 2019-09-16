//
//  MoreViewController.m
//  linphone
//
//  Created by user on 1/7/14.
//
//

#import "MoreViewController.h"
#import "ChooseRingtoneViewController.h"
#import "SignInViewController.h"
#import "SignInViewController.h"
#import "AboutViewController.h"
#import "SendLogsViewController.h"
#import "PolicyViewController.h"
#import "IntroduceViewController.h"
#import "NSData+Base64.h"
#import "MenuCell.h"
#import "JSONKit.h"
#import "CustomSwitchButton.h"

@interface MoreViewController ()<WebServiceUtilDelegate, CustomSwitchButtonDelegate, UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    float hInfo;
    NSMutableArray *listTitle;
    NSMutableArray *listIcon;
    
    float hCell;
    CustomSwitchButton *switchDND;
    BOOL isEnableDND;
    BOOL isDisableDND;
}

@end

@implementation MoreViewController
@synthesize _viewHeader, bgHeader, _imgAvatar, _lbName, lbPBXAccount, _tbContent;

#pragma mark - my controller

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self createDataForMenuView];
    [self autoLayoutForMainView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [WriteLogsUtil writeForGoToScreen:@"MoreViewController"];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    [self showContentWithCurrentLanguage];
    [self showAccountInformations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    [self createDataForMenuView];
    [_tbContent reloadData];
}

- (void)showAccountInformations
{
    NSString *sipNumber = [[NSUserDefaults standardUserDefaults] objectForKey:SIP_NUMBER];
    if ([AppUtil isNullOrEmpty: sipNumber]) {
        sipNumber = [appDelegate getSipNumberOfAccount];
    }
    PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: sipNumber];
    if (contact != nil) {
        _lbName.text = contact.name;
    }else{
        _lbName.text = USERNAME;
    }
    
    lbPBXAccount.text = SFM(@"Số nội bộ: %@", sipNumber);
}

//  Cập nhật vị trí cho view
- (void)autoLayoutForMainView {
    self.view.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(244/255.0)
                                                 blue:(248/255.0) alpha:1.0];
    
    hInfo = appDelegate.hStatus + appDelegate.hNav + 40.0;
    float wAvatar = 50.0;
    hCell = 60.0;
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        hCell = 70.0;
    }
    
    //  Header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hInfo);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    float topAvatar = appDelegate.hStatus + (hInfo - appDelegate.hStatus - wAvatar)/2;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader).offset(10);
        make.top.equalTo(_viewHeader).offset(topAvatar);
        make.width.height.mas_equalTo(wAvatar);
    }];
    _imgAvatar.clipsToBounds = TRUE;
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.layer.borderColor = [UIColor colorWithRed:(96/255.0) green:(195/255.0)
                                                    blue:(66/255.0) alpha:1.0].CGColor;
    _imgAvatar.layer.borderWidth = 2.0;
    
    _lbName.textColor = UIColor.whiteColor;
    _lbName.font = appDelegate.fontLargeBold;
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.left.equalTo(_imgAvatar.mas_right).offset(5.0);
        make.right.equalTo(_viewHeader).offset(-5.0);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
    }];
    
    lbPBXAccount.textColor = UIColor.whiteColor;
    lbPBXAccount.font = appDelegate.fontNormalRegular;
    [lbPBXAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_lbName);
        make.bottom.equalTo(_imgAvatar.mas_bottom);
    }];
    [_tbContent registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    _tbContent.backgroundColor = UIColor.clearColor;
    [_tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    _tbContent.delegate = self;
    _tbContent.dataSource = self;
    _tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContent.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  Khoi tao du lieu cho view
- (void)createDataForMenuView {
    listTitle = [[NSMutableArray alloc] initWithObjects: text_do_not_disturb, text_choose_ringtone, text_app_info, text_send_reports, text_sign_out, text_privacy_policy, text_introduction, nil];
    
    listIcon = [[NSMutableArray alloc] initWithObjects: @"more_dnd", @"more_ringtone", @"more_app_info", @"more_send_reports", @"more_signout", @"more_policy", @"more_support", nil];
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MenuCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case eDNDMode:{
            cell._iconImage.image = [UIImage imageNamed:@"more_dnd"];
            cell._lbTitle.text = text_do_not_disturb;
            break;
        }
//        case eRingtone:{
//            cell._iconImage.image = [UIImage imageNamed:@"more_ringtone"];
//            cell._lbTitle.text = text_choose_ringtone;
//            break;
//        }
        case eAppInfo:{
            cell._iconImage.image = [UIImage imageNamed:@"more_app_info"];
            cell._lbTitle.text = text_app_info;
            break;
        }
//        case eSendLogs:{
//            cell._iconImage.image = [UIImage imageNamed:@"more_send_reports"];
//            cell._lbTitle.text = text_send_reports;
//            break;
//        }
        case ePrivayPolicy:{
            cell._iconImage.image = [UIImage imageNamed:@"more_policy"];
            cell._lbTitle.text = text_privacy_policy;
            break;
        }
        case eIntroduction:{
            cell._iconImage.image = [UIImage imageNamed:@"more_support"];
            cell._lbTitle.text = text_introduction;
            break;
        }
        case eSignOut:{
            cell._iconImage.image = [UIImage imageNamed:@"more_signout"];
            cell._lbTitle.text = text_sign_out;
            break;
        }
        default:
            break;
    }
    cell._iconImage.hidden = FALSE;
    cell._lbTitle.textAlignment = NSTextAlignmentLeft;
    
    if (indexPath.row == eDNDMode) {
        cell.imgNext.hidden = TRUE;
        
        BOOL state = FALSE;
        BOOL isDNDMode = [AppUtil checkDoNotDisturbMode];
        if (isDNDMode) {
            state = TRUE;
        }
        switchDND = [[CustomSwitchButton alloc] initWithState:state frame:CGRectMake(SCREEN_WIDTH-20-85.0, (hCell-32.0)/2, 85.0, 32.0)];
        switchDND.delegate = self;
        [cell addSubview: switchDND];
    }else{
        cell.imgNext.hidden = FALSE;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
//        case eRingtone:{
//            ChooseRingtoneViewController *ringtoneVC = [[ChooseRingtoneViewController alloc] initWithNibName:@"ChooseRingtoneViewController" bundle:nil];
//            ringtoneVC.hidesBottomBarWhenPushed = TRUE;
//            [self.navigationController pushViewController:ringtoneVC animated:TRUE];
//            break;
//        }
        case eAppInfo:{
            AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            aboutVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:aboutVC animated:TRUE];
            break;
        }
//        case eSendLogs:{
//            SendLogsViewController *sendLogsVC = [[SendLogsViewController alloc] initWithNibName:@"SendLogsViewController" bundle:nil];
//            sendLogsVC.hidesBottomBarWhenPushed = TRUE;
//            [self.navigationController pushViewController:sendLogsVC animated:TRUE];
//            break;
//        }
        case eSignOut:{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:text_confirm_sign_out];
                [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontLargeRegular range:NSMakeRange(0, attrTitle.string.length)];
                [alertVC setValue:attrTitle forKey:@"attributedTitle"];
                
                UIAlertAction *btnClose = [UIAlertAction actionWithTitle:text_no style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [btnClose setValue:BLUE_COLOR forKey:@"titleTextColor"];
                
                UIAlertAction *btnDelete = [UIAlertAction actionWithTitle:text_sign_out style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {
                                                [self startLogout];
                                            }];
                [btnDelete setValue:UIColor.redColor forKey:@"titleTextColor"];
                [alertVC addAction:btnClose];
                [alertVC addAction:btnDelete];
                [self presentViewController:alertVC animated:YES completion:nil];
            });
            break;
        }
        case ePrivayPolicy:{
            PolicyViewController *policyVC = [[PolicyViewController alloc] initWithNibName:@"PolicyViewController" bundle:nil];
            policyVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:policyVC animated:TRUE];
            
            break;
        }
        case eIntroduction:{
            IntroduceViewController *introduceVC = [[IntroduceViewController alloc] initWithNibName:@"IntroduceViewController" bundle:nil];
            introduceVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:introduceVC animated:TRUE];
            
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (void)startLogout {
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter style:appDelegate.warningStyle];
        return;
    }
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:text_waiting Interaction:NO];
    
    //  clear token to avoid push when user signed out
    [self clearPushTokenOfUser];
}

- (void)clearPushTokenOfUser {
    appDelegate.updateTokenSuccess = FALSE;
    
    NSString *params = SFM(@"pushtoken=%@&username=%@", @"", USERNAME);
    [WebServiceUtil getInstance].delegate = self;
    [[WebServiceUtil getInstance] callWebServiceWithFunction:update_token_func withParams:params inBackgroundMode:TRUE];
}

- (void)startResetValueWhenLogout
{
//    linphone_core_clear_proxy_config(LC);
//    [self performSelector:@selector(goToSignView) withObject:nil afterDelay:1.0];
}

- (void)goToSignScreenView {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SignInViewController *signInVC = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    UINavigationController *signInNav = [[UINavigationController alloc] initWithRootViewController:signInVC];
    [self presentViewController:signInNav animated:TRUE completion:nil];
}


#pragma mark - Webservice delegate
-(void)failedToUpdateTokenWithError:(id)error {
    [ProgressHUD dismiss];
    
    if (isEnableDND) {
        [self.view makeToast:@"Đã xảy ra lỗi, vui lòng thử lại!" duration:2.0 position:CSToastPositionCenter];
        isEnableDND = FALSE;
        [switchDND setUIForDisableStateWithActionTarget: FALSE];
        
    }else if (isDisableDND){
        [self.view makeToast:@"Đã xảy ra lỗi, vui lòng thử lại!" duration:2.0 position:CSToastPositionCenter];
        isDisableDND = FALSE;
        [switchDND setUIForEnableStateWithActionTarget: FALSE];
        
    }else{
        BOOL result = [appDelegate deleteSIPAccountDefault];
        if (!result) {
            [self.view makeToast:text_can_not_signout_at_this_time duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        }else{
            [self goToSignScreenView];
        }
    }
}

-(void)updateTokenSuccessfully {
    [ProgressHUD dismiss];
    
    if (isEnableDND) {
        [ProgressHUD dismiss];
        [AppUtil enableDoNotDisturbMode: TRUE];
        
        [self.view makeToast:@"Bạn đã bật chế độ \"Không làm phiền\"." duration:2.0 position:CSToastPositionCenter];
        isEnableDND = FALSE;
    }else if (isDisableDND){
        [ProgressHUD dismiss];
        
        [AppUtil enableDoNotDisturbMode: FALSE];
        
        [self.view makeToast:@"Bạn đã tắt chế độ \"Không làm phiền\"." duration:2.0 position:CSToastPositionCenter];
        isDisableDND = FALSE;
        
    }else{
        BOOL result = [appDelegate deleteSIPAccountDefault];
        if (!result) {
            [self.view makeToast:text_can_not_signout_at_this_time duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        }else{
            [self goToSignScreenView];
        }
    }
}

- (void)failedToCallWebService:(NSString *)link andError:(id)error {
//    [WriteLogsUtils writeLogContent:SFM(@"[%s] link: %@, error: %@", __FUNCTION__, link, @[error]) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//    [icWaiting stopAnimating];
//    icWaiting.hidden = TRUE;
//
//    if ([link isEqualToString: update_token_func]) {
//        if (isDisableDND) {
    
//        }else{
//            [self startResetValueWhenLogout];
//        }
//    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
//    [WriteLogsUtils writeLogContent:SFM(@"[%s] link: %@, data: %@", __FUNCTION__, link, @[data]) toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//    if ([link isEqualToString: update_token_func]) {
//        if (isDisableDND){
    
//        }else{
//            [self startResetValueWhenLogout];
//        }
//    }else{
//        [icWaiting stopAnimating];
//        icWaiting.hidden = TRUE;
//    }
}

#pragma mark - Switch Custom Delegate
- (void)switchButtonEnabled
{
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter];
        return;
    }
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:text_waiting Interaction:FALSE];
    
    isEnableDND = TRUE;
    [self clearPushTokenOfUser];
}

- (void)switchButtonDisabled {
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([AppUtil isNullOrEmpty: appDelegate.deviceToken]) {
        [self.view makeToast:text_token_is_not_exists duration:2.0 position:CSToastPositionCenter];
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:text_waiting Interaction:FALSE];

    isDisableDND = TRUE;

    [self updateCustomerTokenIOS];
}

- (void)updateCustomerTokenIOS {
    if (USERNAME != nil) {
        NSString *destToken = SFM(@"ios%@", appDelegate.deviceToken);
        NSString *params = SFM(@"pushtoken=%@&username=%@", destToken, USERNAME);
        [WebServiceUtil getInstance].delegate = self;
        [[WebServiceUtil getInstance] callWebServiceWithFunction:update_token_func withParams:params inBackgroundMode:TRUE];
    }
}

@end

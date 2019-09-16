//
//  AboutViewController.m
//  linphone
//
//  Created by lam quang quan on 10/26/18.
//

#import "AboutViewController.h"

@interface AboutViewController (){
    AppDelegate *appDelegate;
    NSString *linkToAppStore;
    NSString* appStoreVersion;
}
@end

@implementation AboutViewController
@synthesize viewHeader, icBack, bgHeader, lbHeader, imgAppLogo, lbVersion, btnCheckForUpdate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [WriteLogsUtil writeForGoToScreen:@"AboutViewController"];
    
    linkToAppStore = @"";
    lbHeader.text = text_app_info;
    [btnCheckForUpdate setTitle:text_check_for_update forState:UIControlStateNormal];
    
    NSString *str = SFM(@"%@: %@\n%@: %@", text_version, [AppUtil getAppVersionWithBuildVersion: TRUE], text_release_date, [AppUtil getBuildDate]);
    lbVersion.text = str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)btnCheckForUpdatePress:(UIButton *)sender {
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:pls_check_your_network_connection duration:1.5 position:CSToastPositionBottom style:nil];
        return;
    }
    [self startCheckNewVersionFromAppStore];
}

#pragma mark - my functions

- (void)startCheckNewVersionFromAppStore {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        if (appID.length > 0) {
            NSURL* url = [NSURL URLWithString:SFM(@"http://itunes.apple.com/lookup?bundleId=%@", appID)];
            NSData* data = [NSData dataWithContentsOfURL:url];
            
            if (data) {
                NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([lookup[@"resultCount"] integerValue] == 1){
                    appStoreVersion = lookup[@"results"][0][@"version"];
                    NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
                    
                    if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                        // app needs to be updated
                        linkToAppStore = lookup[@"results"][0][@"trackViewUrl"] ? lookup[@"results"][0][@"trackViewUrl"] : @"";
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![AppUtil isNullOrEmpty: linkToAppStore] && ![AppUtil isNullOrEmpty: appStoreVersion]) {
                NSString *content = SFM(@"Phiên bản hiện tại trên App Store là %@. Bạn có muốn cập nhật không?", appStoreVersion);
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] message:content delegate:self cancelButtonTitle:text_close otherButtonTitles:text_update, nil];
                alert.tag = 2;
                [alert show];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] message:text_newest_version delegate:self cancelButtonTitle:text_close otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

//  setup ui trong view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        icBack.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }else{
        icBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    }
    
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate.hStatus + appDelegate.hNav);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    lbHeader.font = appDelegate.fontLargeRegular;
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(appDelegate.hStatus);
        make.bottom.equalTo(viewHeader);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    if (SCREEN_WIDTH > 320) {
        icBack.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }else{
        icBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    }
    [icBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    //
    imgAppLogo.clipsToBounds = TRUE;
    imgAppLogo.layer.cornerRadius = 10.0;
    [imgAppLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(viewHeader.mas_bottom).offset(30.0);
        make.width.height.mas_equalTo(120.0);
    }];
    
    lbVersion.font = appDelegate.fontLargeRegular;
    lbVersion.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAppLogo.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(20.0);
        make.right.equalTo(self.view).offset(-20.0);
        make.height.mas_lessThanOrEqualTo(100.0);
    }];
    
    btnCheckForUpdate.titleLabel.font = appDelegate.fontLargeRegular;
    [btnCheckForUpdate setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCheckForUpdate.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                         blue:(70/255.0) alpha:1.0];
    btnCheckForUpdate.clipsToBounds = YES;
    btnCheckForUpdate.layer.cornerRadius = 45.0/2;
    [btnCheckForUpdate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbVersion.mas_bottom).offset(40.0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(45.0);
    }];
}

#pragma mark - UIAlertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkToAppStore]];
    }
}

@end

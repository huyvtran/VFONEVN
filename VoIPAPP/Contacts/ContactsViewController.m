//
//  ContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "ContactsViewController.h"
#import "AllContactsViewController.h"
#import "PBXContactsViewController.h"
#import "PBXGroupsViewController.h"

@interface ContactsViewController ()<UITextFieldDelegate>
{
    AppDelegate *appDelegate;
    AllContactsViewController *allContactsVC;
    PBXContactsViewController *pbxContactsVC;
    PBXGroupsViewController *groupsVC;
    int currentView;
    float hIcon;
    float paddingContent;
    
    NSTimer *searchTimer;
    UIColor *unselectedColor;
}
@end

@implementation ContactsViewController
@synthesize _pageViewController, _viewHeader, _iconAll, _iconPBX, icGroupPBX, _tfSearch, imgBackground, _icClearSearch, lbSepa, lbSepa2;
@synthesize _listSyncContact, _phoneForSync;

#pragma mark - My controller

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    unselectedColor = GRAY_220;
    [self autoLayoutForMainView];
    
    currentView = eContactAll;
    [self updateStateIconWithView: currentView];
    
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    pbxContactsVC = [[PBXContactsViewController alloc] init];
    allContactsVC = [[AllContactsViewController alloc] init];
    groupsVC = [[PBXGroupsViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:allContactsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:true completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0.0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    if (![_tfSearch.text isEqualToString:@""]) {
        _icClearSearch.hidden = FALSE;
    }else{
        _icClearSearch.hidden = TRUE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard)
                                                 name:@"closeKeyboard" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [AppUtil addBoxShadowForView:_tfSearch withColor:[UIColor colorWithRed:(100/255.0) green:(100/255.0) blue:(100/255.0) alpha:1.0]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark – UIPageViewControllerDelegate Method

- (IBAction)_iconAllClicked:(id)sender {
    currentView = eContactAll;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[allContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
    
    _tfSearch.text = @"";
    _icClearSearch.hidden = TRUE;
    [[NSNotificationCenter defaultCenter] postNotificationName:searchContactWithValue
                                                        object:_tfSearch.text];
}

- (IBAction)_iconPBXClicked:(UIButton *)sender {
    currentView = eContactPBX;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[pbxContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionForward
                                   animated: false completion: nil];
    
    _tfSearch.text = @"";
    _icClearSearch.hidden = TRUE;
}

- (IBAction)iconGroupPBXPress:(UIButton *)sender {
    currentView = eContactGroup;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[groupsVC]
                                  direction: UIPageViewControllerNavigationDirectionForward
                                   animated: false completion: nil];
    
    _tfSearch.text = @"";
    _icClearSearch.hidden = TRUE;
}

- (IBAction)_icClearSearchClicked:(UIButton *)sender {
    _icClearSearch.hidden = TRUE;
    _tfSearch.text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:searchContactWithValue
                                                        object:_tfSearch.text];
}

//  setup trạng thái cho các button
- (void)autoLayoutForMainView {
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    
    float hTextfield = 40.0;
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: IphoneSE])
    {
        hTextfield = 33.0;
        
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: simulator])
    {
        hTextfield = 45.0;
        
    }
    
    paddingContent = 30.0;
    
    float hHeader = appDelegate.hStatus + appDelegate.hNav + hTextfield;
    _viewHeader.backgroundColor = UIColor.whiteColor;
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [imgBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(_viewHeader);
        make.bottom.equalTo(_viewHeader).offset(-hTextfield/2);
    }];
    
    float sizeText = [AppUtil getSizeWithText:text_pbx_contacts withFont:appDelegate.fontNormalMedium].width + 10.0;
    
    _iconPBX.titleLabel.font = _iconAll.titleLabel.font = icGroupPBX.titleLabel.font = appDelegate.fontNormalMedium;
    
    //  icon pbx
    [_iconPBX setTitle:text_pbx_contacts forState:UIControlStateNormal];
    [_iconPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
    [_iconPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(sizeText);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    lbSepa.backgroundColor = unselectedColor;
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconPBX.mas_centerY);
        make.right.equalTo(_iconPBX.mas_left).offset(-10.0);
        make.width.mas_equalTo(1.0);
        make.height.mas_equalTo(25.0);
    }];
    
    //  icon all
    [_iconAll setTitle:text_all_contacts forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lbSepa.mas_left).offset(-10.0);
        make.top.bottom.equalTo(_iconPBX);
        make.left.equalTo(_viewHeader).offset(5.0);
    }];
    
    lbSepa2.backgroundColor = lbSepa.backgroundColor;
    [lbSepa2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbSepa);
        make.left.equalTo(_iconPBX.mas_right).offset(10.0);
        make.width.mas_equalTo(1.0);
    }];
    
    //  icon groups
    [icGroupPBX setTitle:text_pbx_groups forState:UIControlStateNormal];
    [icGroupPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
    [icGroupPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbSepa2.mas_right).offset(10.0);
        make.top.bottom.equalTo(_iconPBX);
        make.right.equalTo(_viewHeader).offset(-5.0);
    }];
    
    _tfSearch.returnKeyType = UIReturnKeyDone;
    _tfSearch.font = appDelegate.fontNormalRegular;
    _tfSearch.placeholder = search_name_or_phone;
    _tfSearch.textColor = UIColor.darkGrayColor;
    _tfSearch.clipsToBounds = TRUE;
    _tfSearch.layer.cornerRadius = 7.0;
    [_tfSearch addTarget:self
                  action:@selector(onSearchContactChange:)
        forControlEvents:UIControlEventEditingChanged];
    _tfSearch.delegate = self;
    [_tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_viewHeader);
        make.left.equalTo(self.view).offset(paddingContent);
        make.right.equalTo(self.view).offset(-paddingContent);
        make.height.mas_equalTo(hTextfield);
    }];
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22.0, hTextfield)];
    _tfSearch.leftView = pLeft;
    _tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *imgSearch = [[UIImageView alloc] init];
    imgSearch.image = [UIImage imageNamed:@"ic_search_gray"];
    [_tfSearch addSubview: imgSearch];
    [imgSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tfSearch.mas_centerY);
        make.left.equalTo(_tfSearch).offset(8.0);
        make.width.height.mas_equalTo(17.0);
    }];
    
    _icClearSearch.backgroundColor = UIColor.clearColor;
    [_icClearSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(_tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view {
    if (view == eContactAll){
        [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_iconPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
        [icGroupPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
        
    }else if (view == eContactPBX) {
        [_iconAll setTitleColor:unselectedColor forState:UIControlStateNormal];
        [_iconPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [icGroupPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
        
    }else{
        [_iconAll setTitleColor:unselectedColor forState:UIControlStateNormal];
        [_iconPBX setTitleColor:unselectedColor forState:UIControlStateNormal];
        [icGroupPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
}

//  Added by Khai Le on 04/10/2018
- (void)onSearchContactChange: (UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        _icClearSearch.hidden = NO;
    }else{
        _icClearSearch.hidden = YES;
    }
    
    [searchTimer invalidate];
    searchTimer = nil;
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                                                 selector:@selector(startSearchPhoneBook)
                                                 userInfo:nil repeats:NO];
}

- (void)startSearchPhoneBook {
    [[NSNotificationCenter defaultCenter] postNotificationName:searchContactWithValue
                                                        object:_tfSearch.text];
}

- (void)closeKeyboard {
    [self.view endEditing: YES];
}

#pragma mark - UITextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _tfSearch) {
        [self.view endEditing: TRUE];
    }
    return TRUE;
}

@end

//
//  CallsHistoryViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "CallsHistoryViewController.h"
#import "AllCallsViewController.h"
#import "MissedCallViewController.h"
#import "RecordsCallViewController.h"

@interface CallsHistoryViewController ()
{
    AppDelegate *appDelegate;
    int currentView;
    AllCallsViewController *allCallsVC;
    MissedCallViewController *missedCallsVC;
    RecordsCallViewController *recordCallsVC;
    UIColor *noActiveColor;
    float hIcon;
}

@end

@implementation CallsHistoryViewController
@synthesize _viewHeader, _btnEdit, _iconAll, _iconMissed, bgHeader, lbSepa, lbSepa2, _iconRecord;
@synthesize _pageViewController, _vcIndex;

#pragma mark - My controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  notifications
    //  Sau khi xoá tất cả các cuộc gọi
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUIForView)
//                                                 name:k11ReloadAfterDeleteAllCall object:nil];
    
    self.view.backgroundColor = UIColor.whiteColor;
    noActiveColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0];
    [self autoLayoutForView];
    currentView = eAllCalls;
    [self updateStateIconWithView: currentView];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    allCallsVC = [[AllCallsViewController alloc] init];
    missedCallsVC = [[MissedCallViewController alloc] init];
    recordCallsVC = [[RecordsCallViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:allCallsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:false
                                 completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0;
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
    _btnEdit.tag = 0;
    [_btnEdit setImage:[UIImage imageNamed:@"ic_trash"] forState:UIControlStateNormal];
    
    //  Reset lại các UI khi vào màn hình
    [self resetUIForView];
    
    // Fake event
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneCallUpdate object:self];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeleteCallHistory:)
//                                                 name:showOrHideDeleteCallHistoryButton object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (IBAction)_iconAllClicked:(id)sender {
    _btnEdit.hidden = FALSE;
    
    if (currentView == eAllCalls) {
        return;
    }
    
    currentView = eAllCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers:@[allCallsVC]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:false completion:nil];
}

- (IBAction)_iconMissedClicked:(id)sender {
    _btnEdit.hidden = FALSE;
    
    if (currentView == eMissedCalls) {
        return;
    }
    
    currentView = eMissedCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[missedCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_iconRecordClicked:(UIButton *)sender {
    _btnEdit.hidden = TRUE;
    
    if (currentView == eRecordCalls) {
        return;
    }
    
    currentView = eRecordCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[recordCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_btnEditPressed:(id)sender {
    if (_btnEdit.tag == 0) {
        _btnEdit.tag = 1;
        [_btnEdit setImage:[UIImage imageNamed:@"ic_tick"]
                  forState:UIControlStateNormal];
    }else{
        _btnEdit.tag = 0;
        [_btnEdit setImage:[UIImage imageNamed:@"ic_trash"]
                  forState:UIControlStateNormal];
    }
    
    if (currentView == eAllCalls) {
        [allCallsVC showDeleteCallHistoryWithTag: (int)_btnEdit.tag];
        
    }else if (currentView == eMissedCalls){
        [missedCallsVC showDeleteCallHistoryWithTag: (int)_btnEdit.tag];
    }
}

- (void)showDeleteCallHistory: (NSNotification *)notif {
    if (currentView == eRecordCalls) {
        _btnEdit.hidden = TRUE;
        return;
    }
    
    if ([notif.object isKindOfClass:[NSString class]]) {
        NSString *value = [notif object];
        if ([value isEqualToString:@"1"]) {
            _btnEdit.hidden = FALSE;
        }else{
            _btnEdit.hidden = TRUE;
        }
    }
}

#pragma mark - My functions

//  Reset lại các UI khi vào màn hình
- (void)resetUIForView {
    _btnEdit.hidden = _iconAll.hidden = _iconMissed.hidden = FALSE;
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eAllCalls){
        [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_iconMissed setTitleColor:noActiveColor forState:UIControlStateNormal];
        [_iconRecord setTitleColor:noActiveColor forState:UIControlStateNormal];
    }else if (view == eMissedCalls){
        [_iconAll setTitleColor:noActiveColor forState:UIControlStateNormal];
        [_iconMissed setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_iconRecord setTitleColor:noActiveColor forState:UIControlStateNormal];
    }else{
        [_iconAll setTitleColor:noActiveColor forState:UIControlStateNormal];
        [_iconMissed setTitleColor:noActiveColor forState:UIControlStateNormal];
        [_iconRecord setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    _btnEdit.tag = 0;
    [_btnEdit setImage:[UIImage imageNamed:@"ic_trash"] forState:UIControlStateNormal];
}


//  setup trạng thái cho các button
- (void)autoLayoutForView {
    float hHeader = appDelegate.hStatus + appDelegate.hNav;
    float padding = 15.0;
    float more = 15.0;
    if (!IS_IPHONE && !IS_IPOD) {
        padding = 40.0;
        more = 40.0;
    }
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    float sizeMissed = [AppUtil getSizeWithText:text_missed_call withFont:appDelegate.fontNormalMedium andMaxWidth:SCREEN_WIDTH].width + 10.0;
    float sizeAll = [AppUtil getSizeWithText:text_all_call withFont:appDelegate.fontNormalMedium andMaxWidth:SCREEN_WIDTH].width + 10.0;
    float sizeRecords = [AppUtil getSizeWithText:text_record_call withFont:appDelegate.fontNormalMedium andMaxWidth:SCREEN_WIDTH].width + 10.0;
    
    _iconMissed.backgroundColor = UIColor.clearColor;
    _iconMissed.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_iconMissed setTitle:text_missed_call forState:UIControlStateNormal];
    [_iconMissed setTitleColor:noActiveColor forState:UIControlStateNormal];
    _iconMissed.titleLabel.font = appDelegate.fontNormalMedium;
    [_iconMissed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(sizeMissed);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                              blue:(220/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconMissed.mas_centerY);
        make.right.equalTo(_iconMissed.mas_left).offset(-padding);
        make.width.mas_equalTo(1.0);
        make.height.mas_equalTo(25.0);
    }];
    
    _iconAll.backgroundColor = UIColor.clearColor;
    _iconAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_iconAll setTitle:text_all_call forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _iconAll.titleLabel.font = appDelegate.fontNormalMedium;
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lbSepa.mas_left).offset(-padding);
        make.top.bottom.equalTo(_iconMissed);
        make.width.mas_equalTo(sizeAll);
    }];
    
    lbSepa2.backgroundColor = lbSepa.backgroundColor;
    [lbSepa2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbSepa);
        make.left.equalTo(_iconMissed.mas_right).offset(padding);
        make.width.mas_equalTo(1.0);
    }];
    
    _iconRecord.backgroundColor = UIColor.clearColor;
    [_iconRecord setTitle:text_record_call forState:UIControlStateNormal];
    [_iconRecord setTitleColor:noActiveColor forState:UIControlStateNormal];
    _iconRecord.titleLabel.font = appDelegate.fontNormalMedium;
    [_iconRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbSepa2.mas_right).offset(padding);
        make.top.bottom.equalTo(_iconMissed);
        make.width.mas_equalTo(sizeRecords);
    }];
    
    _btnEdit.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right).offset(-2.0);
        make.centerY.equalTo(_iconAll.mas_centerY);
        make.width.height.equalTo(_iconAll.mas_height);
    }];
}

@end

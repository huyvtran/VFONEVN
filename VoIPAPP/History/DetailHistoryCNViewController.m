//
//  DetailHistoryCNViewController.m
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import "DetailHistoryCNViewController.h"
#import "NewHistoryDetailCell.h"
#import "HistoryCallDetailTableViewCell.h"
#import "CallHistoryObject.h"
#import "NSData+Base64.h"

@interface DetailHistoryCNViewController ()<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>
{
    AppDelegate *appDelegate;
    NSString *displayName;
    NSMutableArray *listHistoryCalls;
}
@end

@implementation DetailHistoryCNViewController

@synthesize _viewHeader, _iconBack, _lbHeader, _imgAvatar, _lbName, icDelete, _tbHistory, lbPhone, viewInfo, iconAudio;
@synthesize phoneNumber, onDate, onlyMissedCall;

#pragma mark - View controllers

- (IBAction)btnCallPressed:(UIButton *)sender {
//    if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]) {
//        [SipUtils makeCallWithPhoneNumber: phoneNumber];
//    }else{
//        [self.view makeToast:text_phone_empty duration:2.0 position:CSToastPositionCenter];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = TRUE;
    _lbHeader.text = text_call_details;
    
    [self displayInformationForView];
    
    //  reset missed call
    [DatabaseUtil resetMissedCallOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateMissedCallBadge object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInformationForView)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)displayInformationForView
{
    if ([phoneNumber isEqualToString: hotline]) {
        displayName = text_hotline;
        _imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }else{
        PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: phoneNumber];
        if (![AppUtil isNullOrEmpty:contact.name]) {
            displayName = contact.name;
        }else{
            displayName = [AppUtil getNameWasStoredFromUserInfo: phoneNumber];
        }
        
        if (![AppUtil isNullOrEmpty: contact.avatar]) {
            _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: contact.avatar]];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }
    }
    _lbName.text = displayName;
    lbPhone.text = phoneNumber;
    
    if (listHistoryCalls == nil) {
        listHistoryCalls = [[NSMutableArray alloc] init];
    }
    [listHistoryCalls removeAllObjects];
    [_tbHistory reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([AppUtil isNullOrEmpty: onDate]) {
            [listHistoryCalls addObjectsFromArray: [DatabaseUtil getAllListCallOfMe:USERNAME withPhoneNumber:phoneNumber]];
        }else{
            [listHistoryCalls addObjectsFromArray: [DatabaseUtil getAllCallOfMe:USERNAME withPhone:phoneNumber onDate:onDate onlyMissedCall: onlyMissedCall]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tbHistory reloadData];
        });
    });
}

#pragma mark - my functions

- (void)setupUIForView
{
    float sizeIcon = 60.0;
    float hAvatar = 100.0;
    float hHeader = 220 + appDelegate.hStatus;
    UIEdgeInsets backEdge = UIEdgeInsetsMake(7, 7, 7, 7);
    float hInfo = 80.0;
    
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: IphoneSE])
    {
        sizeIcon = 50.0;
        hAvatar = 80.0;
        hHeader = 200 + appDelegate.hStatus;
        backEdge = UIEdgeInsetsMake(6.5, 6.5, 6.5, 6.5);
        hInfo = 65.0;
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    //  header
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    _lbHeader.font = appDelegate.fontLargeMedium;
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.left.equalTo(_iconBack.mas_right).offset(5);
        make.right.equalTo(icDelete.mas_left).offset(-5);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    _iconBack.imageEdgeInsets = backEdge;
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    icDelete.imageEdgeInsets = backEdge;
    [icDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_iconBack);
        make.right.equalTo(_viewHeader).offset(-5);
        make.width.equalTo(_iconBack.mas_width);
    }];
    
    _imgAvatar.layer.cornerRadius = hAvatar/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbHeader.mas_bottom);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(hAvatar);
    }];
    
    _lbName.font = appDelegate.fontLargeRegular;
    _lbName.textColor = UIColor.whiteColor;
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(30.0);
    }];
    
    lbPhone.font = appDelegate.fontSmallRegular;
    lbPhone.textColor = UIColor.whiteColor;
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(30.0);
    }];
    
    //  view info
    [viewInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(hInfo);
    }];
    
    iconAudio.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [iconAudio mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewInfo.mas_centerY);
        make.centerX.equalTo(viewInfo.mas_centerX);
        make.width.height.mas_equalTo(sizeIcon);
    }];
    
    //  content
    [_tbHistory registerNib:[UINib nibWithNibName:@"HistoryCallDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"HistoryCallDetailTableViewCell"];
    _tbHistory.delegate = self;
    _tbHistory.dataSource = self;
    _tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbHistory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewInfo.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    listHistoryCalls = [[NSMutableArray alloc] init];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint: CGPointMake(0, hHeader-50)];
    [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH, hHeader-50) controlPoint:CGPointMake(SCREEN_WIDTH/2, hHeader+50)];
    [path addLineToPoint: CGPointMake(SCREEN_WIDTH, 0)];
    [path closePath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = path.CGPath;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader+100);
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.colors = @[(id)[UIColor colorWithRed:(154/255.0) green:(215/255.0) blue:(9/255.0) alpha:1.0].CGColor, (id)[UIColor colorWithRed:(60/255.0) green:(198/255.0) blue:(116/255.0) alpha:1.0].CGColor];
    
    //Add gradient layer to view
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    gradientLayer.mask = shapeLayer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listHistoryCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCallDetailTableViewCell *cell = (HistoryCallDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier: @"HistoryCallDetailTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CallHistoryObject *aCall = [listHistoryCalls objectAtIndex: indexPath.row];
    
    cell.lbTime.text = aCall._time;
    cell.lbDuration.text = [AppUtil convertDurtationToString: aCall._duration];
    
    //  Show direction and type call
    if (aCall.typeCall == AUDIO_CALL_TYPE) {
        cell.imgCallType.image = [UIImage imageNamed:@"contact_audio_call.png"];
    }else{
        cell.imgCallType.image = [UIImage imageNamed:@"contact_video_call.png"];
    }
    
    if ([aCall._status isEqualToString: aborted_call]){
        cell.lbCallState.text = @"Hủy bỏ";
        
    }else if ([aCall._status isEqualToString: declined_call]){
        cell.lbCallState.text = @"Bị từ chối";
        
    }else if ([aCall._status isEqualToString: missed_call]){
        cell.lbCallState.text = @"Cuộc gọi nhỡ";
        
    }else if ([aCall._status isEqualToString: success_call]){
        cell.lbCallState.text = @"Đã kết nối";
        
    }else{
        cell.lbCallState.text = @"";
    }
    
    if ([aCall._callDirection isEqualToString: incomming_call]) {
        if ([aCall._status isEqualToString: missed_call]) {
            cell.imgDirection.image = [UIImage imageNamed:@"ic_call_missed.png"];
        }else{
            cell.imgDirection.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        }
    }else{
        cell.imgDirection.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
    }
    
    NSString *dateStr = [AppUtil getDateStringFromTimeInterval: aCall._timeInt];
    cell.lbDate.text = dateStr;
    
    return cell;
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)icDeleteClick:(UIButton *)sender
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:do_you_want_to_delete_call_history];
    [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontLargeRegular range:NSMakeRange(0, attrTitle.string.length)];
    [alertVC setValue:attrTitle forKey:@"attributedTitle"];
    
    UIAlertAction *btnClose = [UIAlertAction actionWithTitle:text_no style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [btnClose setValue:BLUE_COLOR forKey:@"titleTextColor"];
    
    UIAlertAction *btnDelete = [UIAlertAction actionWithTitle:text_delete style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   [DatabaseUtil deleteCallHistoryOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
                                   [self.navigationController popViewControllerAnimated: TRUE];
                               }];
    [btnDelete setValue:UIColor.redColor forKey:@"titleTextColor"];
    [alertVC addAction:btnClose];
    [alertVC addAction:btnDelete];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)iconAudioClick:(UIButton *)sender {
    appDelegate.phoneForCall = phoneNumber;
    [appDelegate getDIDListForCall];
}

@end


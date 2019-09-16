//
//  KContactDetailViewController.m
//  linphone
//
//  Created by mac book on 11/5/15.
//
//

#import "KContactDetailViewController.h"
#import "UIKContactCell.h"
#import "UIContactPhoneCell.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import "ContactDetailObj.h"

@interface KContactDetailViewController (){
    AppDelegate *appDelegate;
    float hCell;
    ABRecordRef contact;
    NSMutableArray *listPhone;
}
@end

@implementation KContactDetailViewController
@synthesize _viewHeader, _iconBack, _imgAvatar, _lbContactName, _tbContactInfo;
@synthesize detailsContact, idContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  MY CODE HERE
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [WriteLogsUtil writeForGoToScreen: @"KContactDetailViewController"];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    [self displayContactInformation];
    [_tbContactInfo reloadData];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_tbContactInfo.frame.size.height >= _tbContactInfo.contentSize.height) {
        _tbContactInfo.scrollEnabled = NO;
    }else{
        _tbContactInfo.scrollEnabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    _tbContactInfo.tableFooterView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

#pragma mark - my functions

- (void)autoLayoutForView
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIEdgeInsets backEdge = UIEdgeInsetsMake(5, 5, 5, 5);
    float wAvatar = 100.0;
    float hHeader = 180+appDelegate.hStatus;
    hCell = 70.0;
    
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: IphoneSE])
    {
        backEdge = UIEdgeInsetsMake(6.5, 6.5, 6.5, 6.5);
        wAvatar = 80.0;
        hHeader = 170+appDelegate.hStatus;
        hCell = 60.0;
    }
    
    //  header
    _viewHeader.backgroundColor = UIColor.clearColor;
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    _iconBack.imageEdgeInsets = backEdge;
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.left.equalTo(_viewHeader);
        make.width.height.mas_equalTo(40.0);
    }];
    
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack.mas_centerY);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    [_lbContactName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom).offset(5.0);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(45.0);
    }];
    _lbContactName.font = appDelegate.fontLargeMedium;
    _lbContactName.textColor = UIColor.whiteColor;
    
    
    //  content
    [_tbContactInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [_tbContactInfo registerNib:[UINib nibWithNibName:@"UIContactPhoneCell" bundle:nil] forCellReuseIdentifier:@"UIContactPhoneCell"];
    [_tbContactInfo registerNib:[UINib nibWithNibName:@"UIKContactCell" bundle:nil] forCellReuseIdentifier:@"UIKContactCell"];
    
    _tbContactInfo.delegate = self;
    _tbContactInfo.dataSource = self;
    _tbContactInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContactInfo.backgroundColor = UIColor.clearColor;
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint: CGPointMake(0, 0)];
    [path addLineToPoint: CGPointMake(0, hHeader-50)];
    [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH, hHeader-50) controlPoint:CGPointMake(SCREEN_WIDTH/2, hHeader+50)];
    [path addLineToPoint: CGPointMake(SCREEN_WIDTH, 0)];
    [path closePath];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = path.CGPath;
    //  shapeLayer.fillColor = UIColor.clearColor.CGColor;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader+100);
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.colors = @[(id)[UIColor colorWithRed:(154/255.0) green:(215/255.0) blue:(9/255.0) alpha:1.0].CGColor, (id)[UIColor colorWithRed:(60/255.0) green:(198/255.0) blue:(116/255.0) alpha:1.0].CGColor];
    
    //Add gradient layer to view
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    gradientLayer.mask = shapeLayer;
}

//  Hiển thị thông tin của contact
- (void)displayContactInformation
{
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    contact = ABAddressBookGetPersonWithRecordID(addressListBook, idContact);
    NSString *name = [ContactsUtil getFullNameFromContact: contact];
    _lbContactName.text = name;
    
    UIImage *avatar = [ContactsUtil getAvatarFromContact: contact];
    _imgAvatar.image = avatar;
    
    listPhone = [ContactsUtil getListPhoneOfContactPerson: contact];
    [_tbContactInfo reloadData];
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numRow = [self getRowForSection];
    return numRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < listPhone.count)
    {
        UIContactPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: @"UIContactPhoneCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ContactDetailObj *anItem = [listPhone objectAtIndex: indexPath.row];
        cell.lbTitle.text = anItem._titleStr;
        cell.lbPhone.text = anItem._valueStr;
        
        [cell.icCall setTitle:anItem._valueStr forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        UIKContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"UIKContactCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *company = [ContactsUtil getCompanyFromContact: contact];
        NSString *email = [ContactsUtil getEmailFromContact: contact];
        
        if (indexPath.row == listPhone.count) {
            if (![AppUtil isNullOrEmpty: company]) {
                cell.lbTitle.text = text_company;
                cell.lbValue.text = company;
                
            }else if (![AppUtil isNullOrEmpty: email]){
                cell.lbTitle.text = text_email;
                cell.lbValue.text = email;
            }
        }else if (indexPath.row == listPhone.count + 1){
            if (email != nil && ![email isEqualToString:@""]){
                cell.lbTitle.text = text_email;
                cell.lbValue.text = email;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

//  Added by Khai Le on 05/10/2018
- (int)getRowForSection {
    int result = (int)listPhone.count;
    
    NSString *company = [ContactsUtil getCompanyFromContact: contact];
    if (company != nil && ![company isEqualToString:@""]) {
        result = result + 1;
    }
    
    NSString *email = [ContactsUtil getEmailFromContact: contact];
    if (email != nil && ![email isEqualToString:@""]) {
        result = result + 1;
    }
    return result;
}

- (void)onIconCallClicked: (UIButton *)sender
{
    if (![AppUtil isNullOrEmpty: sender.currentTitle]) {
        NSString *phoneNumber = [AppUtil removeAllSpecialInString: sender.currentTitle];
        if (![AppUtil isNullOrEmpty: phoneNumber])
        {
            appDelegate.phoneForCall = phoneNumber;
            [appDelegate getDIDListForCall];
        }
        return;
    }
    [self.view makeToast:phone_number_can_not_empty duration:2.0 position:CSToastPositionCenter];
}

@end

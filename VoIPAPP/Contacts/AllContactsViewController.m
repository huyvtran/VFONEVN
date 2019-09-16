//
//  AllContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "AllContactsViewController.h"
#import "ContactsViewController.h"
#import "KContactDetailViewController.h"
#import "NSData+Base64.h"
#import "ContactCell.h"
#import "ContactObject.h"
#import "ContactDetailObj.h"

@interface AllContactsViewController ()
{
    AppDelegate *appDelegate;
    BOOL isSearching;
    float hSection;
    float hHeader;
    float hCell;
    
    NSArray *listCharacter;
    
    NSMutableArray *tbDatas;
    UILabel *lbAllContacts;
    float marginLeft;
}

@end

@implementation AllContactsViewController
@synthesize _tbContacts, _lbNoContacts, btnGoSettings;
@synthesize searchResults, contactSections;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                  @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self autoLayoutForView];
    [self addHeaderForTableContactsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [WriteLogsUtil writeForGoToScreen: @"AllContactsViewController"];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        _lbNoContacts.hidden = btnGoSettings.hidden = FALSE;
        _tbContacts.hidden = TRUE;
        _lbNoContacts.text = @"Không có quyền truy cập vào Danh bạ!";
        
    }else{
        btnGoSettings.hidden = TRUE;
        
        if (tbDatas == nil) {
            tbDatas = [[NSMutableArray alloc] init];
        }
        [tbDatas removeAllObjects];
        
        if (!appDelegate.contactLoaded)
        {
            [WriteLogsUtil writeLogContent:@">>>>>>>>>>>>>> CONTACTS HAVE NOT LOADED YET!!! <<<<<<<<<<<<<<<"];
            _lbNoContacts.hidden = FALSE;
            _tbContacts.hidden = TRUE;
            
            _lbNoContacts.text = @"Danh bạ đang được tải...";
            
        }else{
            [self showAndReloadContactList];
            lbAllContacts.text = SFM(@"%@ (%d)", count_all_contacts, (int)tbDatas.count);
        }
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLoadContactFinish)
                                                 name:finishLoadContacts object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearchContactWithValue:)
                                                 name:searchContactWithValue object:nil];
    //  ---------
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Functions

- (void)addHeaderForTableContactsView {
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader);
    headerView.backgroundColor = UIColor.whiteColor;
    
    lbAllContacts = [[UILabel alloc] init];
    lbAllContacts.font = appDelegate.fontNormalRegular;
    lbAllContacts.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [headerView addSubview: lbAllContacts];
    [lbAllContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(headerView);
        make.left.equalTo(headerView).offset(marginLeft);
        make.right.equalTo(headerView).offset(-marginLeft);
    }];
    _tbContacts.tableHeaderView = headerView;
}

- (void)whenLoadContactFinish {
    [WriteLogsUtil writeLogContent:SFM(@"[%s]", __FUNCTION__)];
    [self showAndReloadContactList];
}

- (void)autoLayoutForView {
    hSection = 30.0;
    marginLeft = 15.0;
    hHeader = 40.0;
    hCell = 65.0;
    
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        hHeader = 60.0;
        hCell = 70.0;
    }
    
    [_tbContacts registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    _tbContacts.delegate = self;
    _tbContacts.dataSource = self;
    _tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    //  khong co lien he
    _lbNoContacts.font = appDelegate.fontLargeRegular;
    _lbNoContacts.textColor = UIColor.grayColor;
    _lbNoContacts.text = text_no_contacts;
    [_lbNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5.0);
        make.right.equalTo(self.view).offset(-5.0);
        make.bottom.equalTo(self.view.mas_centerY).offset(-40.0);
    }];
    
    btnGoSettings.layer.cornerRadius = 5.0;
    [btnGoSettings setTitle:text_go_to_settings forState:UIControlStateNormal];
    [btnGoSettings setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    btnGoSettings.backgroundColor = GRAY_235;
    btnGoSettings.titleLabel.font = appDelegate.fontLargeRegular;
    
    float widthBTN = [AppUtil getSizeWithText:text_go_to_settings withFont:btnGoSettings.titleLabel.font].width + 20.0;
    btnGoSettings.hidden = TRUE;
    [btnGoSettings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbNoContacts.mas_bottom).offset(20.0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(widthBTN);
        make.height.mas_equalTo(45.0);
    }];
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    if (contactSections == nil) {
        contactSections = [[NSMutableDictionary alloc] init];
    }
    [contactSections removeAllObjects];
    
    // Loop through the books and create our keys
    for (int index=0; index<contactList.count; index++) {
        ABRecordRef person = (__bridge ABRecordRef)[contactList objectAtIndex: index];
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        
        NSString *c = @"";
        if (fullname.length > 1) {
            c = [[fullname substringToIndex: 1] uppercaseString];
            c = [AppUtil convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        if (![[contactSections allKeys] containsObject: c]) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactSections setObject:list forKey:c];
        }else{
            NSMutableArray *list = [contactSections objectForKey: c];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactSections setObject:list forKey:c];
        }
    }
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching) {
        [self getSectionsForContactsList: searchResults];
    }else{
        [self getSectionsForContactsList: tbDatas];
    }
    return [[contactSections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *str = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[contactSections objectForKey:str] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ContactCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactSections objectForKey: key] objectAtIndex:indexPath.row];
    
    NSString *fullname = [ContactsUtil getFullNameFromContact: person];
    cell.name.text = fullname;
    
    UIImage *avatar = [ContactsUtil getAvatarFromContact: person];
    cell.image.image = avatar;
    
    NSString *firstPhone = [ContactsUtil getFirstPhoneFromContact: person];
    cell.phone.text = firstPhone;
    if (![AppUtil isNullOrEmpty: firstPhone]) {
        cell.icCall.hidden = FALSE;
        [cell.icCall setTitle:firstPhone forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.icCall.hidden = TRUE;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactSections objectForKey: key] objectAtIndex:indexPath.row];
    int contactId = ABRecordGetRecordID(person);
    NSNumber *pbxIdContact = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_ID_CONTACT];
    if (pbxIdContact != nil && [pbxIdContact intValue] == contactId) {
        return;
    }
    
    KContactDetailViewController *contactDetailVC = [[KContactDetailViewController alloc] initWithNibName:@"KContactDetailViewController" bundle:nil];
    contactDetailVC.idContact = contactId;
    [self.navigationController pushViewController:contactDetailVC animated:TRUE];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, hSection)];
    headerView.backgroundColor = GRAY_240;
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginLeft, 0, 150, hSection)];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                           blue:(50/255.0) alpha:1.0];
    descLabel.font = appDelegate.fontLargeMedium;
    if ([titleHeader isEqualToString:@"z#"]) {
        descLabel.text = @"#";
    }else{
        descLabel.text = titleHeader;
    }
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    int index = 0;
    while (index < tmpArr.count) {
        NSString *title = [tmpArr objectAtIndex: index];
        if ([title isEqualToString:@"z#"]) {
            [tmpArr replaceObjectAtIndex:index withObject:@"#"];
            break;
        }
        index++;
    }
    return tmpArr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

//  Added by Khai Le on 04/10/2018
- (void)startSearchContactWithValue: (NSNotification *)notif {
    //  Don't search when don't have permission to access to contacts
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        return;
    }
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        if ([object isEqualToString:@""]) {
            isSearching = FALSE;
            lbAllContacts.text = SFM(@"%@ (%d)", count_all_contacts, (int)tbDatas.count);
            [_tbContacts reloadData];
        }else{
            isSearching = TRUE;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self searchPhoneBook: object];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    lbAllContacts.text = SFM(@"%@ (%d)", count_all_contacts, (int)searchResults.count);
                    [_tbContacts reloadData];
                });
            });
        }
    }
}

- (void)searchPhoneBook: (NSString *)strSearch
{
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    [searchResults removeAllObjects];
    
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int i=0; i<[arrayOfAllPeople count]; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:i];
        
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
        
        if ([convertName rangeOfString: strSearch options: NSCaseInsensitiveSearch].location != NSNotFound) {
            [searchResults addObject: (__bridge id _Nonnull)(person)];
            continue;
        }
        
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for (int k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            NSString *phoneNumber = (__bridge NSString *)phoneNumberValue;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            if ([phoneNumber containsString: strSearch]) {
                [searchResults addObject: (__bridge id _Nonnull)(person)];
                break;
            }
        }
    }
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

- (void)showAndReloadContactList {
    [tbDatas removeAllObjects];
    [tbDatas addObjectsFromArray:[appDelegate.listContacts copy]];
    
    if (tbDatas.count > 0) {
        _tbContacts.hidden = FALSE;
        _lbNoContacts.hidden = TRUE;
        [_tbContacts reloadData];
    }else{
        _tbContacts.hidden = TRUE;
        _lbNoContacts.hidden = FALSE;
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGPoint scrollViewOffset = scrollView.contentOffset;
    if (scrollViewOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (IBAction)btnGoSettingsPress:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[[NSDictionary alloc] init] completionHandler:nil];
}

@end

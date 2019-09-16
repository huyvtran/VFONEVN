//
//  PBXContactsViewController.m
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import "PBXContactsViewController.h"
#import "JSONKit.h"
#import "PBXContact.h"
#import "PBXContactTableCell.h"
#import "CustomTextAttachment.h"
#import "PBXHeaderView.h"
#import "ChooseSortCell.h"

@interface PBXContactsViewController ()<PBXHeaderViewDelegate, WebServiceUtilDelegate>
{
    AppDelegate *appDelegate;
    BOOL isSearching;
    
    NSMutableArray *listSearch;
    NSMutableDictionary *contactSections;
    NSArray *listCharacter;
    float wIconSync;
    float hSection;
    float hCell;
    float hHeader;
    NSMutableArray *pbxList;
    
    float marginLeft;
    
    PBXHeaderView *pbxHeaderView;
}

@end

@implementation PBXContactsViewController
@synthesize _tbContacts, lbNoContacts, btnGoSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
    
    contactSections = [[NSMutableDictionary alloc] init];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [WriteLogsUtil writeForGoToScreen: @"PBXContactsViewController"];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
        lbNoContacts.hidden = btnGoSettings.hidden = FALSE;
        _tbContacts.hidden = TRUE;
        lbNoContacts.text = @"Không có quyền truy cập vào Danh bạ!";
        
    }else{
        btnGoSettings.hidden = lbNoContacts.hidden = TRUE;
        _tbContacts.hidden = FALSE;
        
        //  create temp pbx contacts list
        if (pbxList == nil) {
            pbxList = [[NSMutableArray alloc] init];
        }
        [pbxList removeAllObjects];
        
        if (listSearch == nil) {
            listSearch = [[NSMutableArray alloc] init];
        }
        [listSearch removeAllObjects];
        
        if (pbxHeaderView == nil) {
            [self addHeaderForTableContactsView];
        }
        [pbxHeaderView updateUIWithCurrentInfo];
        
        isSearching = FALSE;
        
        if (!appDelegate.contactLoaded)
        {
            NSNumber *pbxId = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID_CONTACT];
            if (pbxId != nil) {
                NSArray *contacts = [appDelegate getPBXContactPhone:[pbxId intValue]];
                [pbxList addObjectsFromArray: contacts];
                
                if (pbxList.count > 0) {
                    [_tbContacts reloadData];
                }
            }
        }else{
            if (appDelegate.pbxContacts != nil) {
                [pbxList addObjectsFromArray: [appDelegate.pbxContacts copy]];
            }
            pbxHeaderView.lbTitle.text = SFM(@"Tất cả liên hện (%d)", (int)pbxList.count);
            if (pbxList.count > 0) {
                [_tbContacts reloadData];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearchContactWithValue:)
                                                 name:searchContactWithValue object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterFinishGetPBXContactsList:)
                                                 name:finishGetPBXContacts object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGPoint scrollViewOffset = scrollView.contentOffset;
    if (scrollViewOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconClearClicked:(UIButton *)sender {
    [self.view endEditing: true];
    isSearching = FALSE;
    [_tbContacts reloadData];
}

#pragma mark - Header delegate
- (void)onSyncButtonPress {
    if (USERNAME != nil) {
        if (appDelegate.isSyncing) {
            [self.view makeToast:@"Danh bạ đang được đồng bộ..." duration:2.0 position:CSToastPositionCenter style:appDelegate.warningStyle];
            return;
        }
        appDelegate.isSyncing = TRUE;
        pbxHeaderView.btnSync.enabled = FALSE;
        
        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:text_syncing_contacts Interaction:FALSE];
        
        NSString *params = SFM(@"username=%@", USERNAME);
        [WebServiceUtil getInstance].delegate = self;
        [[WebServiceUtil getInstance] callWebServiceWithFunction:get_contacts_func withParams:params inBackgroundMode:TRUE];
    }
}

-(void)onIconSortClick {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_pbx];
    if ([sort intValue] == eSort91) {
        sort = [NSNumber numberWithInt: eSortAZ];
    }else {
        sort = [NSNumber numberWithInt:([sort intValue] + 1)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:sort forKey:sort_pbx];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [pbxHeaderView updateUIWithCurrentInfo];
    
    [_tbContacts reloadData];
}

#pragma mark - my functions

- (void)addHeaderForTableContactsView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"PBXHeaderView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[PBXHeaderView class]]) {
            pbxHeaderView = (PBXHeaderView *) currentObject;
            break;
        }
    }
    pbxHeaderView.delegate = self;
    pbxHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader);
    [pbxHeaderView setupUIForView];
    _tbContacts.tableHeaderView = pbxHeaderView;
}

//  setup thông tin cho tableview
- (void)autoLayoutForView {
    wIconSync = 17.0;
    hSection = 30.0;
    marginLeft = 15.0;
    hCell = 65.0;
    hHeader = 40.0;
    
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        hHeader = 60.0;
        hCell = 70.0;
    }
    
    //  table contacts
    [_tbContacts registerNib:[UINib nibWithNibName:@"PBXContactTableCell" bundle:nil] forCellReuseIdentifier:@"PBXContactTableCell"];
//    _tbContacts.alwaysBounceVertical = FALSE;
//    _tbContacts.alwaysBounceHorizontal = FALSE;
    _tbContacts.delegate = self;
    _tbContacts.dataSource = self;
    _tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    lbNoContacts.font = appDelegate.fontLargeRegular;
    lbNoContacts.textColor = UIColor.grayColor;
    lbNoContacts.text = text_no_contacts;
    [lbNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(lbNoContacts.mas_bottom).offset(20.0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(widthBTN);
        make.height.mas_equalTo(45.0);
    }];
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        [self getSectionsForContactsList: listSearch];
    }else{
        [self getSectionsForContactsList: pbxList];
    }
    return [[contactSections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:pbxHeaderView.sortAscending selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray* sortedArray = [[contactSections allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSString *str = [sortedArray objectAtIndex:section];
    
    return [[contactSections objectForKey:str] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBXContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"PBXContactTableCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL sortAscending = FALSE;
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_pbx];
    if ([sort intValue] == eSortAZ || [sort intValue] == eSort19) {
        sortAscending = TRUE;
    }
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:sortAscending selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray* sortedArray = [[contactSections allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    
    PBXContact *contact = [[contactSections objectForKey: key] objectAtIndex:indexPath.row];
    
    // Tên contact
    if (contact._name != nil && ![contact._name isKindOfClass:[NSNull class]]) {
        cell._lbName.text = contact._name;
    }else{
        cell._lbName.text = @"";
    }
    
    if (contact._number != nil && ![contact._number isKindOfClass:[NSNull class]]) {
        cell._lbPhone.text = contact._number;
        
        [cell.icCall setTitle:contact._number forState:UIControlStateNormal];
        cell.icCall.hidden = FALSE;
        cell.icCall.tag = AUDIO_CALL_TYPE;
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [cell.icVideoCall setTitle:contact._number forState:UIControlStateNormal];
        cell.icVideoCall.hidden = FALSE;
        cell.icVideoCall.tag = VIDEO_CALL_TYPE;
        [cell.icVideoCall addTarget:self
                             action:@selector(onIconCallClicked:)
                   forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell._lbPhone.text = @"";
        cell.icCall.hidden = TRUE;
        cell.icVideoCall.hidden = TRUE;
    }
    cell.icVideoCall.hidden = TRUE;
    cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
    
    int count = (int)[[contactSections objectForKey:key] count];
    if (indexPath.row == count-1) {
        cell._lbSepa.hidden = TRUE;
    }else{
        cell._lbSepa.hidden = FALSE;
    }
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:pbxHeaderView.sortAscending selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray* sortedArray = [[contactSections allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSString *titleHeader = [sortedArray objectAtIndex:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, hSection)];
    headerView.backgroundColor = GRAY_240;
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    descLabel.font = appDelegate.fontLargeMedium;
    if ([titleHeader isEqualToString:@"z#"]) {
        descLabel.text = @"#";
    }else{
        descLabel.text = titleHeader;
    }
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(marginLeft);
        make.right.equalTo(headerView).offset(-marginLeft);
        make.top.bottom.equalTo(headerView);
    }];
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

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

//  Added by Khai Le on 04/10/2018
- (void)startSearchContactWithValue: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            isSearching = FALSE;
            [_tbContacts reloadData];
            pbxHeaderView.lbTitle.text = SFM(@"Tất cả liên hệ (%d)", (int)pbxList.count);
            
        }else{
            isSearching = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self startSearchPBXContactsWithContent: object];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    pbxHeaderView.lbTitle.text = SFM(@"Tất cả liên hệ (%d)", (int)listSearch.count);
                    [_tbContacts reloadData];
                });
            });
        }
    }
}

- (void)startSearchPBXContactsWithContent: (NSString *)content {
    [listSearch removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _nameForSearch CONTAINS[cd] %@  OR _number CONTAINS[cd] %@", content, content, content];
    
    NSArray *filter = [pbxList filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_pbx];
    if ([sort intValue] == eSortAZ || [sort intValue] == eSortZA) {
        [contactSections removeAllObjects];
        
        // Loop through the books and create our keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._name.length > 1) {
                c = [[contactItem._name substringToIndex: 1] uppercaseString];
                c = [AppUtil convertUTF8StringToString: c];
            }
            
            if (![listCharacter containsObject:c]) {
                c = @"z#";
            }
            
            if (![[contactSections allKeys] containsObject: c]) {
                [contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
            }
        }
        
        // Loop again and sort the books into their respective keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._name.length > 1) {
                c = [[contactItem._name substringToIndex: 1] uppercaseString];
                c = [AppUtil convertUTF8StringToString: c];
            }
            if (![listCharacter containsObject:c]) {
                c = @"z#";
            }
            if (contactItem != nil) {
                [[contactSections objectForKey: c] addObject:contactItem];
            }
        }
        // Sort each section array
        for (NSString *key in [contactSections allKeys]){
            [[contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_name" ascending:pbxHeaderView.sortAscending]]];
        }
        
    }else{
        [contactSections removeAllObjects];
        
        // Loop through the books and create our keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._number.length > 1) {
                c = [contactItem._number substringToIndex: 1];
            }
            
            if (![[contactSections allKeys] containsObject: c]) {
                [contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
            }
        }
        
        // Loop again and sort the books into their respective keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._number.length > 1) {
                c = [contactItem._number substringToIndex: 1];
            }
            if (contactItem != nil) {
                [[contactSections objectForKey: c] addObject:contactItem];
            }
        }
        // Sort each section array
        for (NSString *key in [contactSections allKeys]){
            [[contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_number" ascending:pbxHeaderView.sortAscending]]];
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

- (void)afterFinishGetPBXContactsList: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        if (pbxList == nil) {
            pbxList = [[NSMutableArray alloc] init];
        }
        [pbxList removeAllObjects];
        if (appDelegate.pbxContacts != nil) {
            [pbxList addObjectsFromArray:[appDelegate.pbxContacts copy]];
        }

        if (pbxList.count > 0) {
            [_tbContacts reloadData];
        }
    }
}

- (NSAttributedString *)getSyncTitleContentWithFont: (UIFont *)textFont andSizeIcon: (float)size
{
    CustomTextAttachment *attachment = [[CustomTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"sync.png"];
    [attachment setImageHeight: size];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSString *content = SFM(@"  %@", text_sync_contacts);
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
    [contentString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, contentString.length)];
    [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0] range:NSMakeRange(0, contentString.length)];
    
    NSMutableAttributedString *verString = [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
    //
    [verString appendAttributedString: contentString];
    return verString;
}

#pragma mark - Webservice delegate
-(void)failedToGetContactsWithError:(id)error {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] error: %@", __FUNCTION__, @[error])];
    
    appDelegate.isSyncing = FALSE;
    pbxHeaderView.btnSync.enabled = TRUE;
    [ProgressHUD dismiss];
    [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

-(void)getContactsSuccessfullyWithData:(id)data {
    [WriteLogsUtil writeLogContent:SFM(@"[%s] data: %@", __FUNCTION__, @[data])];
    
    appDelegate.isSyncing = FALSE;
    if (data != nil && [data isKindOfClass:[NSArray class]]) {
        [self whenStartSyncPBXContacts: (NSArray *)data];
    }else{
        [ProgressHUD dismiss];
        pbxHeaderView.btnSync.enabled = TRUE;
    }
}

//  Xử lý pbx contacts trả về
- (void)whenStartSyncPBXContacts: (NSArray *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self savePBXContactInPhoneBook: data];
        [self getListPhoneWithCurrentContactPBX];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self syncContactsSuccessfully];
        });
    });
}

- (void)savePBXContactInPhoneBook: (NSArray *)pbxData
{
    NSString *pbxContactName = @"";

    ABAddressBookRef addressListBook = ABAddressBookCreateWithOptions(NULL, NULL);

    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    NSUInteger peopleCounter = 0;

    BOOL exists = FALSE;

    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count]; peopleCounter++)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX]) {
            pbxContactName = [AppUtil getNameOfContact: aPerson];
            exists = TRUE;

            ABRecordSetValue(aPerson, kABPersonPhoneProperty, nil, nil);
            BOOL isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
            // Phone number
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            for (int iCount=0; iCount<pbxData.count; iCount++) {
                NSDictionary *dict = [pbxData objectAtIndex: iCount];
                NSString *name = [dict objectForKey:@"name"];
                NSString *number = [dict objectForKey:@"num"];
                if (![AppUtil isNullOrEmpty: name] && ![AppUtil isNullOrEmpty: number]) {
                    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
                }
            }

            ABRecordSetValue(aPerson, kABPersonPhoneProperty, multiPhone,nil);
            isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
        }
    }
    if (!exists) {
        [self addContactsWithData:pbxData withContactName:nameContactSyncPBX andCompany:nameSyncCompany];
    }
}

- (void)getListPhoneWithCurrentContactPBX {
    if (appDelegate.pbxContacts == nil) {
        appDelegate.pbxContacts = [[NSMutableArray alloc] init];
    }
    [appDelegate.pbxContacts removeAllObjects];

    ABAddressBookRef addressListBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int peopleCounter = (int)arrayOfAllPeople.count-1; peopleCounter >= 0; peopleCounter--)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];

        ABRecordID idContact = ABRecordGetRecordID(aPerson);
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX])
        {
            ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phones) > 0)
            {
                for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);

                    NSString *curPhoneValue = (__bridge NSString *)phoneNumberRef;
                    curPhoneValue = [[curPhoneValue componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

                    NSString *nameValue = (__bridge NSString *)locLabel;

                    if (curPhoneValue != nil && nameValue != nil) {
                        PBXContact *aContact = [[PBXContact alloc] init];
                        aContact._name = nameValue;
                        aContact._number = curPhoneValue;

                        [appDelegate.pbxContacts addObject: aContact];
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:idContact]
                                                          forKey:PBX_ID_CONTACT];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

//  Thêm mới contact
- (void)addContactsWithData: (NSArray *)pbxData withContactName: (NSString *)contactName andCompany: (NSString *)company
{
    NSString *strEmail = @"";
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contactName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(@""), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(keySyncPBX), &anError);
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(strEmail), CFSTR("email"), NULL);
    ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    
    UIImage *logoImage = [UIImage imageNamed:@"lauch_icon"];
    NSData *avatarData = UIImagePNGRepresentation(logoImage);
    if (avatarData != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[avatarData bytes], [avatarData length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    //  NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<pbxData.count; iCount++) {
        NSDictionary *dict = [pbxData objectAtIndex: iCount];
        NSString *name = [dict objectForKey:@"name"];
        NSString *number = [dict objectForKey:@"num"];
        
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
    }
    
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    // Instant Message
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"SIP", (NSString*)kABPersonInstantMessageServiceKey,
                                @"", (NSString*)kABPersonInstantMessageUsernameKey, nil];
    CFStringRef label = NULL; // in this case 'IM' will be set. But you could use something like = CFSTR("Personal IM");
    CFErrorRef errorf = NULL;
    ABMutableMultiValueRef values =  ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    BOOL didAdd = ABMultiValueAddValueAndLabel(values, (__bridge CFTypeRef)(dictionary), label, NULL);
    BOOL didSet = ABRecordSetValue(aRecord, kABPersonInstantMessageProperty, values, &errorf);
    if (!didAdd || !didSet) {
        CFStringRef errorDescription = CFErrorCopyDescription(errorf);
        NSLog(@"%s error %@ while inserting multi dictionary property %@ into ABRecordRef", __FUNCTION__, dictionary, errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(values);
    
    //Address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStateKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCityKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCountryKey];
    ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
    ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &anError);
    
    if (anError != NULL) {
        NSLog(@"error while creating..");
    }
    
    ABAddressBookRef addressBook;
    CFErrorRef error = NULL;
    addressBook = ABAddressBookCreateWithOptions(nil, &error);
    
    BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&error);
    
    if(isAdded){
        NSLog(@"added..");
    }
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    BOOL isSaved = ABAddressBookSave (addressBook,&error);
    if(isSaved){
        NSLog(@"saved..");
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
}

//  Thông báo kết thúc sync contacts
- (void)syncContactsSuccessfully
{
    [pbxList removeAllObjects];
    if (appDelegate.pbxContacts != nil) {
        [pbxList addObjectsFromArray:[appDelegate.pbxContacts copy]];
    }
    [_tbContacts reloadData];
    
    pbxHeaderView.lbTitle.text = SFM(@"Tất cả liên hện (%d)", (int)pbxList.count);
    pbxHeaderView.btnSync.enabled = TRUE;
    [ProgressHUD dismiss];
    [appDelegate.window makeToast:text_successful duration:2.0 position:CSToastPositionCenter];
}

- (IBAction)btnGoSettingsPress:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[[NSDictionary alloc] init] completionHandler:nil];
}

@end

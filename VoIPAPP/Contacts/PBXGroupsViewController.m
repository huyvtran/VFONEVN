//
//  PBXGroupsViewController.m
//  linphone
//
//  Created by lam quang quan on 5/16/19.
//

#import "PBXGroupsViewController.h"
#import "PBXContactTableCell.h"
#import "GroupHeaderView.h"

@interface PBXGroupsViewController ()<UITableViewDelegate, UITableViewDataSource, WebServiceUtilDelegate> {
    AppDelegate *appDelegate;
    NSMutableArray *listData;
    
    NSMutableArray *listSearch;
    NSMutableDictionary *contactSections;
    float hSection;
    float hHeader;
    float hCell;
    
    GroupHeaderView *tbHeader;
    int sectionSelected;
    
    BOOL isSearching;
    
}
@end

@implementation PBXGroupsViewController
@synthesize tbGroup;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if (listData == nil) {
        listData = [[NSMutableArray alloc] init];
    }
    [listData removeAllObjects];
    
    if (listSearch == nil) {
        listSearch = [[NSMutableArray alloc] init];
    }
    [listSearch removeAllObjects];
    
    if (tbHeader == nil) {
        [self addHeaderForTableContactsView];
    }
    [tbHeader updateUIWithCurrentInfo];
    
    
    sectionSelected = -1;
    
    if (appDelegate.listGroup == nil || appDelegate.listGroup.count == 0) {
        if (appDelegate.listGroup == nil) {
            appDelegate.listGroup = [[NSMutableArray alloc] init];
        }
        [self getPBXGroupContactsList];
    }else{
        [self storeCurrentListToListData];
        [self prepareDataToDisplay: nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearchContactWithValue:)
                                                 name:searchContactWithValue object:nil];
}

- (void)storeCurrentListToListData {
    for (int index=0; index<appDelegate.listGroup.count; index++) {
        NSDictionary *info = [appDelegate.listGroup objectAtIndex: index];
        
        NSMutableDictionary *tmpInfo = [[NSMutableDictionary alloc] initWithDictionary: info];
        NSString *queue = [info objectForKey:@"queue"];
        [tmpInfo setObject:[NSNumber numberWithInt:[queue intValue]] forKeyedSubscript:@"tmp_queue"];
        [listData addObject: tmpInfo];
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

- (void)startSearchContactWithValue: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        if ([object isEqualToString:@""]) {
            isSearching = NO;
            [tbGroup reloadData];
            tbHeader.lbTitle.text = SFM(@"Tổng cộng %d nhóm", (int)listData.count);
            
        }else{
            isSearching = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self startSearchPBXGroupsWithContent: object];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    tbHeader.lbTitle.text = SFM(@"Tổng cộng %d nhóm", (int)listSearch.count);
                    [tbGroup reloadData];
                });
            });
        }
    }
}

- (void)startSearchPBXGroupsWithContent: (NSString *)content
{
    [listSearch removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"queue CONTAINS[cd] %@ OR queuename CONTAINS[cd] %@ ", content, content];
    NSArray *filter = [listData filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
}

- (void)getPBXGroupContactsList {
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:text_waiting Interaction:NO];
    
    NSString *params = SFM(@"username=%@", USERNAME);
    [WebServiceUtil getInstance].delegate = self;
    [[WebServiceUtil getInstance] callWebServiceWithFunction:GetServerGroup withParams:params inBackgroundMode:TRUE];
}

- (void)addHeaderForTableContactsView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"GroupHeaderView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[GroupHeaderView class]]) {
            tbHeader = (GroupHeaderView *) currentObject;
            break;
        }
    }
    tbHeader.lbTitle.text = @"";
    [tbHeader.icSort addTarget:self
                        action:@selector(onIconSortClick)
              forControlEvents:UIControlEventTouchUpInside];
    tbHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader);
    [tbHeader setupUIForView];
    tbGroup.tableHeaderView = tbHeader;
}

- (void)onIconSortClick {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_group];
    if ([sort intValue] == eSort91) {
        sort = [NSNumber numberWithInt: eSortAZ];
    }else {
        sort = [NSNumber numberWithInt:([sort intValue] + 1)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:sort forKey:sort_group];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tbHeader updateUIWithCurrentInfo];
    
    NSSortDescriptor *sortDescriptor;
    if ([sort intValue] == eSortZA || [sort intValue] == eSortAZ) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"queuename" ascending:tbHeader.sortAscending selector:@selector(localizedCaseInsensitiveCompare:)];
    }else{
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tmp_queue" ascending:tbHeader.sortAscending];
    }
    
    if (isSearching) {
        NSArray *sortArr = [listSearch sortedArrayUsingDescriptors:@[sortDescriptor]];
        [listSearch removeAllObjects];
        [listSearch addObjectsFromArray: sortArr];
    }else{
        NSArray *sortArr = [listData sortedArrayUsingDescriptors:@[sortDescriptor]];
        [listData removeAllObjects];
        [listData addObjectsFromArray: sortArr];
    }
    [tbGroup reloadData];
}

- (void)sortDataListWithType {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_group];
    if ([sort intValue] == eSortAZ) {
        
    }
    //  1: is z --> a
//    if (type == 1) {
//        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
//        NSArray *sortArr = [listQueuename sortedArrayUsingDescriptors:@[sort]];
//        [listQueuename removeAllObjects];
//        [listQueuename addObjectsFromArray: sortArr];
//    }else{
//        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
//        NSArray *sortArr = [listQueuename sortedArrayUsingDescriptors:@[sort]];
//        [listQueuename removeAllObjects];
//        [listQueuename addObjectsFromArray: sortArr];
//    }
    [tbGroup reloadData];
}

- (void)setupUIForView {
    hSection = 60.0;
    hHeader = 40.0;
    hCell = 60.0;
    
    NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
    if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        hHeader = 60.0;
        hCell = 70.0;
    }
    
    [tbGroup registerNib:[UINib nibWithNibName:@"PBXContactTableCell" bundle:nil] forCellReuseIdentifier:@"PBXContactTableCell"];
    tbGroup.backgroundColor = UIColor.whiteColor;
    tbGroup.separatorStyle = UITableViewCellSelectionStyleNone;
    tbGroup.delegate = self;
    tbGroup.dataSource = self;
    [tbGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

- (void)prepareDataToDisplay: (NSArray *)data {
    if (data != nil) {
        [appDelegate.listGroup removeAllObjects];
        [appDelegate.listGroup addObjectsFromArray:(NSArray *)data];
        
        [self storeCurrentListToListData];
    }
    
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_group];
    NSSortDescriptor *sortDescriptor;
    if ([sort intValue] == eSortZA || [sort intValue] == eSortAZ) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"queuename" ascending:tbHeader.sortAscending selector:@selector(localizedCaseInsensitiveCompare:)];
    }else{
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tmp_queue" ascending:tbHeader.sortAscending];
    }
    
    NSArray *sortArr = [listData sortedArrayUsingDescriptors:@[sortDescriptor]];
    [listData removeAllObjects];
    [listData addObjectsFromArray: sortArr];
    
    if (tbHeader != nil) {
        if (listData.count == 0) {
            tbHeader.lbTitle.text = @"Chưa có danh sách nhóm";
        }else{
            tbHeader.lbTitle.text = SFM(@"Tổng cộng %d nhóm", (int)listData.count);
        }
    }
    [tbGroup reloadData];
}

- (void)clickOnIconCall: (UIButton *)sender {
    NSString *num = sender.currentTitle;
    if (![AppUtil isNullOrEmpty: num]) {
        num = [AppUtil removeAllSpecialInString: num];
        appDelegate.phoneForCall = num;
        [appDelegate getDIDListForCall];
    }
}

- (NSString *)getQueueNameWithSection: (int)section {
    NSDictionary *info;
    if (isSearching) {
        info = [listSearch objectAtIndex: section];
    }else{
        info = [listData objectAtIndex: section];
    }
    
    if (info != nil) {
        return [info objectForKey:@"queuename"];
    }
    return @"";
}

- (int)getNumRowsForSection: (NSInteger)section {
    NSString *queuename = [self getQueueNameWithSection: (int)section];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.queuename == %@", queuename];
    NSArray *tmpArr = [listData filteredArrayUsingPredicate: predicate];
    if (tmpArr.count > 0) {
        NSDictionary *info = [tmpArr objectAtIndex: 0];
        NSArray *members = [info objectForKey:@"members"];
        if (members != nil && [members isKindOfClass:[NSArray class]]) {
            return (int)members.count;
        }
        return 0;
    }
    return 0;
}

- (NSDictionary *)getMembersAtIndex: (int)row section: (int)section {
    NSString *queuename = [self getQueueNameWithSection: (int)section];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.queuename == %@", queuename];
    NSArray *tmpArr = [listData filteredArrayUsingPredicate: predicate];
    if (tmpArr.count > 0) {
        NSDictionary *info = [tmpArr objectAtIndex: 0];
        NSArray *members = [info objectForKey:@"members"];
        if (members != nil && [members isKindOfClass:[NSArray class]]) {
            if (row < members.count) {
                return [members objectAtIndex: row];
            }
        }
    }
    return nil;
}

- (NSString *)getQueueNumberWithQueueName: (NSString *)queuename {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.queuename == %@", queuename];
    NSArray *tmpArr = [listData filteredArrayUsingPredicate: predicate];
    if (tmpArr.count > 0) {
        NSDictionary *info = [tmpArr objectAtIndex: 0];
        NSString *queueNum = [info objectForKey:@"queue"];
        if (![AppUtil isNullOrEmpty: queueNum]) {
            return queueNum;
        }
    }
    return @"";
}

- (void)whenTapOnHeader: (UIGestureRecognizer *)recognizer {
    int section = (int)recognizer.view.tag;
    if (section == sectionSelected) {
        sectionSelected = -1;
    }else{
        sectionSelected = section;
    }
    [tbGroup reloadData];
}

- (void)callGroup: (UIButton *)sender {
    NSString *value = sender.currentTitle;
    if (![AppUtil isNullOrEmpty: value]) {
        NSArray *tmpArr = [value componentsSeparatedByString:@"|||"];
        if (tmpArr.count == 2) {
            NSString *queue = [tmpArr firstObject];
            NSString *group_name = [tmpArr lastObject];
            [SipUtil makeCallToPhoneNumber:queue prefix:@"" displayName: group_name];
            return;
        }
    }
    [self.view makeToast:phone_number_is_invalid duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - Webservice Delegate

-(void)failedToGetServerGroupsWithError:(id)error {
    [ProgressHUD dismiss];
    [self.view makeToast:text_failed duration:1.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

-(void)getServerGroupsSuccessfullyWithData:(id)data {
    [ProgressHUD dismiss];
    if (data != nil && [data isKindOfClass:[NSArray class]]) {
        [self prepareDataToDisplay: (NSArray *)data];
    }
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        return listSearch.count;
    }else{
        return listData.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self getNumRowsForSection: section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBXContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"PBXContactTableCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *member = [self getMembersAtIndex: (int)indexPath.row section: (int)indexPath.section];
    if (member == nil) {
        cell._lbName.text = text_unknown;
        cell._lbPhone.text = @"";
    }else{
        NSString *name = [member objectForKey:@"name"];
        NSString *num = [member objectForKey:@"num"];
        cell._lbName.text = name;
        cell._lbPhone.text = num;
        
        [cell.icCall setTitle:num forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(clickOnIconCall:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    cell.icVideoCall.hidden = TRUE;
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *queueName = [self getQueueNameWithSection: (int)section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, hSection)];
    headerView.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imgArrow = [[UIImageView alloc] init];
    
    [headerView addSubview: imgArrow];
    [imgArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(15.0);
        make.centerY.equalTo(headerView.mas_centerY);
        make.width.height.mas_equalTo(18.0);
    }];
    if (section == sectionSelected) {
        imgArrow.image = [UIImage imageNamed:@"right-arrow-down"];
    }else{
        imgArrow.image = [UIImage imageNamed:@"right-arrow"];
    }
    
    //  group call icon
    UIButton *btnCall = [[UIButton alloc] init];
    btnCall.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [btnCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    [btnCall setImage:[UIImage imageNamed:@"contact_audio_call.png"] forState:UIControlStateNormal];
    [headerView addSubview: btnCall];
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-7.0);
        make.centerY.equalTo(headerView.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    NSString *queueNum = [self getQueueNumberWithQueueName: queueName];
    [btnCall setTitle:SFM(@"%@|||%@", queueNum, queueName) forState:UIControlStateNormal];
    [btnCall addTarget:self
                action:@selector(callGroup:)
      forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    descLabel.font = appDelegate.fontNormalRegular;
    descLabel.text = queueName;
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView.mas_centerY).offset(-2.0);
        make.left.equalTo(imgArrow.mas_right).offset(10.0);
        make.right.equalTo(btnCall.mas_left).offset(-10.0);
    }];
    
    UILabel *lbCount = [[UILabel alloc] init];
    lbCount.textColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0) blue:(150/255.0) alpha:1.0];
    lbCount.font = [UIFont italicSystemFontOfSize: 14.0];
    lbCount.backgroundColor = UIColor.clearColor;
    [headerView addSubview: lbCount];
    [lbCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_centerY).offset(2.0);
        make.left.right.equalTo(descLabel);
    }];
    int membersCount = [self getNumRowsForSection: section];
    if (membersCount > 0) {
        lbCount.text = SFM(@"%d thành viên", membersCount);
    }else{
        lbCount.text = @"Chưa có thành viên";
    }
    
    
    UILabel *lbSepa = [[UILabel alloc] init];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
    [headerView addSubview: lbSepa];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(headerView);
        make.height.mas_equalTo(1.0);
    }];
    
    UITapGestureRecognizer *tapOnHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnHeader:)];
    headerView.userInteractionEnabled = TRUE;
    headerView.tag = section;
    [headerView addGestureRecognizer: tapOnHeader];
    
    return headerView;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
//
//    int iCount = 0;
//    while (iCount < tmpArr.count) {
//        NSString *title = [tmpArr objectAtIndex: iCount];
//        if ([title isEqualToString:@"z#"]) {
//            [tmpArr replaceObjectAtIndex:iCount withObject:@"#"];
//            break;
//        }
//        iCount++;
//    }
//    return tmpArr;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == sectionSelected) {
        return hCell;
    }
    return 0;
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

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGPoint scrollViewOffset = scrollView.contentOffset;
    if (scrollViewOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

@end

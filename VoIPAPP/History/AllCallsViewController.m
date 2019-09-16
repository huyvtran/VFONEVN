//
//  AllCallsViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "AllCallsViewController.h"
#import "DetailHistoryCNViewController.h"
#import "KHistoryCallObject.h"
#import "HistoryCallCell.h"
#import "NSData+Base64.h"
#import "UIView+Toast.h"

@interface AllCallsViewController ()
{
    AppDelegate *appDelegate;
    NSMutableArray *listCalls;
    
    float hCell;
    float hSection;
    
    NSMutableArray *listDelete;
    BOOL isDeleted;
}

@end

@implementation AllCallsViewController
@synthesize _lbNoCalls, _tbListCalls;

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (SCREEN_WIDTH > 320) {
        hCell = 70.0;
        hSection = 35.0;
    }else{
        hCell = 60.0;
        hSection = 35.0;
    }
    
    _lbNoCalls.font = appDelegate.fontLargeRegular;
    _lbNoCalls.textColor = UIColor.grayColor;
    _lbNoCalls.textAlignment = NSTextAlignmentCenter;
    _lbNoCalls.text = text_no_calls;
    _lbNoCalls.hidden = TRUE;
    [_lbNoCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    //  tableview
    [_tbListCalls registerNib:[UINib nibWithNibName:@"HistoryCallCell" bundle:nil] forCellReuseIdentifier:@"HistoryCallCell"];
    _tbListCalls.delegate = self;
    _tbListCalls.dataSource = self;
    _tbListCalls.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbListCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getHistoryCallForUser];
    
    _tbListCalls.hidden = TRUE;
    isDeleted = FALSE;
    if (listDelete != nil) {
        [listDelete removeAllObjects];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistoryCallForUser)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My functions

- (void)getHistoryCallForUser
{
    if (listCalls == nil) {
        listCalls = [[NSMutableArray alloc] init];
    }
    [listCalls removeAllObjects];
    [_tbListCalls reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *tmpArr = [DatabaseUtil getHistoryCallListOfUser:USERNAME isMissed: FALSE];
        [listCalls addObjectsFromArray: tmpArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (listCalls.count == 0) {
                _tbListCalls.hidden = TRUE;
                _lbNoCalls.hidden = FALSE;
//                [[NSNotificationCenter defaultCenter] postNotificationName:showOrHideDeleteCallHistoryButton
//                                                                    object:@"0"];
            }else {
                _tbListCalls.hidden = FALSE;
                _lbNoCalls.hidden = TRUE;
                [_tbListCalls reloadData];
//                [[NSNotificationCenter defaultCenter] postNotificationName:showOrHideDeleteCallHistoryButton
//                                                                    object:@"1"];
            }
        });
    });
}

//  Get lại danh sách các cuộc gọi sau khi xoá
- (void)reGetListCallsForHistory {
    [listCalls removeAllObjects];
    [listCalls addObjectsFromArray:[DatabaseUtil getHistoryCallListOfUser:USERNAME isMissed:false]];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return listCalls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[listCalls objectAtIndex:section] valueForKey:@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCallCell *cell = (HistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: @"HistoryCallCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
    
    // Set name for cell
    cell._lbPhone.text = aCall._phoneNumber;
    cell._phoneNumber = aCall._phoneNumber;
    
    [cell updateFrameForHotline: FALSE];
    cell._lbPhone.hidden = FALSE;
    
    if ([AppUtil isNullOrEmpty: aCall._phoneName]) {
        NSString *groupName = [AppUtil getGroupNameWithQueueNumber: aCall._phoneNumber];
        cell._lbName.text = groupName;
        
    }else{
        cell._lbName.text = aCall._phoneName;
    }
    
    if ([AppUtil isNullOrEmpty: aCall._phoneAvatar]){
        cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
    }else{
        NSData *imgData = [[NSData alloc] initWithData:[NSData dataFromBase64String: aCall._phoneAvatar]];
        cell._imgAvatar.image = [UIImage imageWithData: imgData];
    }
    
    //  Show missed notification
    if (aCall.newMissedCall > 0) {
        cell.lbMissed.hidden = FALSE;
    }else{
        cell.lbMissed.hidden = TRUE;
    }
    
    NSString *strDate = [AppUtil getDateStringFromTimeInterval: aCall.timeInt];
    NSString *strTime = [AppUtil getTimeStringFromTimeInterval: aCall.timeInt];
    
    cell.lbTime.text = strTime;
    cell.lbDate.text = strDate;
    
    if (isDeleted) {
        cell._btnCall.hidden = TRUE;
        //  show current delete state
        cell.imgDelete.hidden = FALSE;
        if ([listDelete containsObject: [NSNumber numberWithInt:aCall._callId]]) {
            cell.imgDelete.image = [UIImage imageNamed:@"ticked_red"];
        }else{
            cell.imgDelete.image = [UIImage imageNamed:@"unticked_red"];
        }
    }else{
        cell.imgDelete.hidden = TRUE;
        cell._btnCall.hidden = FALSE;
    }
    
    if ([aCall._callDirection isEqualToString: incomming_call]) {
        if ([aCall._status isEqualToString: missed_call]) {
            cell._imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
        }else{
            cell._imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        }
    }else{
        cell._imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
    }
    cell.idHistoryCall = aCall._callId;
    
    [cell._btnCall setTitle:aCall._phoneNumber forState:UIControlStateNormal];
    [cell._btnCall setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell._btnCall addTarget:self
                      action:@selector(btnCallOnCellPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    //  get missed call
    if (aCall.newMissedCall > 0) {
        NSString *strMissed = SFM(@"%d", aCall.newMissedCall);
        if (aCall.newMissedCall > 5) {
            strMissed = @"+5";
        }
        cell.lbMissed.hidden = FALSE;
        cell.lbMissed.text = strMissed;
    }else{
        cell.lbMissed.hidden = TRUE;
    }
    
    if (aCall.callType == AUDIO_CALL_TYPE) {
        cell._btnCall.tag = AUDIO_CALL_TYPE;
        [cell._btnCall setImage:[UIImage imageNamed:@"contact_audio_call.png"]
                       forState:UIControlStateNormal];
    }else{
        cell._btnCall.tag = VIDEO_CALL_TYPE;
        [cell._btnCall setImage:[UIImage imageNamed:@"contact_video_call.png"]
                       forState:UIControlStateNormal];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleted) {
        if (listDelete == nil) {
            listDelete = [[NSMutableArray alloc] init];
        }

        HistoryCallCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
        if ([listDelete containsObject: [NSNumber numberWithInt:curCell.idHistoryCall]]) {
            [listDelete removeObject: [NSNumber numberWithInt:curCell.idHistoryCall]];
            curCell.imgDelete.image = [UIImage imageNamed:@"unticked_red"];
        }else{
            [listDelete addObject: [NSNumber numberWithInt:curCell.idHistoryCall]];
            curCell.imgDelete.image = [UIImage imageNamed:@"ticked_red"];
        }
    }else{
        KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
        
        DetailHistoryCNViewController *detailVC = [[DetailHistoryCNViewController alloc] initWithNibName:@"DetailHistoryCNViewController" bundle:nil];
        detailVC.phoneNumber = aCall._phoneNumber;
        detailVC.onDate = aCall._callDate;
        detailVC.onlyMissedCall = FALSE;
        [self.navigationController pushViewController:detailVC animated:TRUE];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = @"";
    NSString *currentDate = [[listCalls objectAtIndex: section] valueForKey:@"title"];
    NSString *today = [AppUtil checkTodayForHistoryCall: currentDate];
    if ([today isEqualToString: @"Today"]) {
        titleHeader =  text_today;
    }else{
        NSString *yesterday = [AppUtil checkYesterdayForHistoryCall:currentDate];
        if ([yesterday isEqualToString:@"Yesterday"]) {
            titleHeader =  text_yesterday;
        }else{
            titleHeader = [currentDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, hSection)];
    headerView.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(244/255.0)
                                                  blue:(248/255.0) alpha:1.0];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    descLabel.textColor = UIColor.darkGrayColor;
    descLabel.font = appDelegate.fontLargeMedium;
    descLabel.text = titleHeader;
    [headerView addSubview: descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(10.0);
        make.right.equalTo(headerView).offset(-10.0);
        make.top.bottom.equalTo(headerView);
    }];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    CGPoint scrollViewOffset = scrollView.contentOffset;
    if (scrollViewOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)btnCallOnCellPressed: (UIButton *)sender {
    if (![AppUtil isNullOrEmpty: sender.currentTitle]) {
        NSString *phoneNumber = [AppUtil removeAllSpecialInString: sender.currentTitle];
        if (![phoneNumber isEqualToString:@""]) {
            appDelegate.phoneForCall = phoneNumber;
            [appDelegate getDIDListForCall];
        }
        return;
    }
    [self.view makeToast:phone_number_can_not_empty duration:2.0 position:CSToastPositionCenter];
}

- (void)showDeleteCallHistoryWithTag: (int)tag {
    if (tag == 0) {
        isDeleted = FALSE;
        
        if (listDelete != nil && listDelete.count > 0) {
            for (int iCount=0; iCount<listDelete.count; iCount++) {
                int idHisCall = [[listDelete objectAtIndex: iCount] intValue];
                NSDictionary *callInfo = [DatabaseUtil getCallInfoWithHistoryCallId: idHisCall];
                if (callInfo != nil) {
                    NSString *phoneNumber = [callInfo objectForKey:@"phone_number"];
                    if (![AppUtil isNullOrEmpty: phoneNumber]) {
                        NSString *date = [callInfo objectForKey:@"date"];
                        [DatabaseUtil removeHistoryCallsOfUser:phoneNumber onDate:date ofAccount:USERNAME onlyMissed: FALSE];
                    }
                }
            }
        }
        [self getHistoryCallForUser];
    }else{
        isDeleted = TRUE;
        [_tbListCalls reloadData];
    }
}

@end

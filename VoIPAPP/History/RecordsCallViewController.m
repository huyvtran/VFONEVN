//
//  RecordsCallViewController.m
//  linphone
//
//  Created by lam quang quan on 3/25/19.
//

#import "RecordsCallViewController.h"
#import "RecordsListViewController.h"
#import "HistoryCallCell.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVKit/AVKit.h>

@interface RecordsCallViewController ()<WebServiceUtilDelegate, UITableViewDelegate, UITableViewDataSource, AVPlayerViewControllerDelegate>
{
    AppDelegate *appDelegate;
    UIDatePicker *datePicker;
    UIToolbar *toolBar;
    NSDateFormatter *dateFormatter;
    float hPicker;
    int indexSelected;
    
    NSMutableArray *listData;
    NSString *myExt;
    float hCell;
    NSString *recordFile;
    
    float padding;
    float hTextfield;
    
    NSDate *startDate;
    NSDate *endDate;
}

@end

@implementation RecordsCallViewController
@synthesize lbStartTime, tfStartTime, btnStartTime, lbEndTime, tfEndTime, btnEndTime, btnSearch, lbNoData, tbListCall, imgArrowEnd, imgArrowStart, btnListFiles;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (SCREEN_WIDTH > 320) {
        padding = 15.0;
        hCell = 70.0;
        hTextfield = 40.0;
    }else{
        hCell = 60.0;
        padding = 9.0;
        hTextfield = 35.0;
    }
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    startDate = nil;
    endDate = nil;
    indexSelected = 0;
    tbListCall.hidden = YES;
    lbNoData.hidden = NO;
    tfStartTime.text = @"";
    tfEndTime.text = @"";
    
    if (listData == nil) {
        listData = [[NSMutableArray alloc] init];
    }else{
        [listData removeAllObjects];
    }
    
    myExt = [[NSUserDefaults standardUserDefaults] objectForKey:SIP_NUMBER];
//    [[NSNotificationCenter defaultCenter] postNotificationName:showOrHideDeleteCallHistoryButton
//                                                        object:@"0"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [self closeDatePicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnStartTimePress:(UIButton *)sender {
    indexSelected = 1;
    //  change hover background
    tfStartTime.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                   blue:(70/255.0) alpha:0.4];
    [self performSelector:@selector(resetBackgroundSender:)
               withObject:tfStartTime afterDelay:0.2];
    
    [self showHideDatePickerView];
}

- (IBAction)btnEndTimePress:(UIButton *)sender {
    tfEndTime.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                 blue:(70/255.0) alpha:0.4];
    [self performSelector:@selector(resetBackgroundSender:)
               withObject:tfEndTime afterDelay:0.2];
    
    if ([tfStartTime.text isEqualToString:@""]) {
        [self.view makeToast:@"Vui lòng chọn thời gian bắt đầu" duration:1.5 position:CSToastPositionCenter];
        return;
    }
    indexSelected = 2;
    
    [self showHideDatePickerView];
}

- (IBAction)btnSearchPress:(UIButton *)sender {
    [self closeDatePicker];
    [listData removeAllObjects];
    
    if (startDate != nil && endDate != nil) {
        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:text_waiting Interaction:NO];
        
        long dateFromInterval = [startDate timeIntervalSince1970];
        long dateToInterval = [endDate timeIntervalSince1970];
        
        NSString *params = SFM(@"username=%@&datefrom=%ld&dateto=%ld&as=%d", USERNAME, dateFromInterval, dateToInterval, 1);
        
        [WebServiceUtil getInstance].delegate = self;
        [[WebServiceUtil getInstance] callWebServiceWithFunction:get_list_record_file withParams:params inBackgroundMode:TRUE];
    }
}

- (IBAction)btnListFilesPress:(UIButton *)sender {
    RecordsListViewController *recordListVC = [[RecordsListViewController alloc] initWithNibName:@"RecordsListViewController" bundle:nil];
    [self.navigationController pushViewController:recordListVC animated:TRUE];
}

- (void)resetBackgroundSender: (UITextField *)sender {
    sender.backgroundColor = UIColor.clearColor;
}

- (void)showHideDatePickerView {
    float hPickerView;
    float hToolbar;
    if (datePicker.frame.size.height > 0) {
        hPickerView = 0;
        hToolbar = 0;
    }else{
        hPickerView = hPicker;
        hToolbar = 44.0;
    }
    
    [datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(hPickerView);
    }];
    [toolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(datePicker.mas_top);
        make.height.mas_equalTo(hToolbar);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        datePicker.date = [NSDate date];
        datePicker.maximumDate = [NSDate date];
    }];
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
    if (indexSelected == 1) {
        tfStartTime.text = [dateFormatter stringFromDate:datePicker.date];
    }else if (indexSelected == 2) {
        tfEndTime.text = [dateFormatter stringFromDate:datePicker.date];
    }
}

- (void)autoLayoutForView {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-YYYY HH:mm"];
    
    
    hPicker = 200.0;
    
    lbStartTime.text = text_start_date;
    lbStartTime.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    lbStartTime.font = appDelegate.fontNormalRegular;
    [lbStartTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.top.equalTo(self.view).offset(padding);
        make.width.mas_equalTo((SCREEN_WIDTH-3*padding)/2-20.0);
        make.height.mas_equalTo(hTextfield);
    }];
    
    tfStartTime.placeholder = SFM(@"--%@--", text_choose_time);
    tfStartTime.textColor = lbStartTime.textColor;
    tfStartTime.font = appDelegate.fontNormalRegular;
    [tfStartTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbStartTime.mas_right).offset(padding);
        make.top.bottom.equalTo(lbStartTime);
        make.right.equalTo(self.view).offset(-padding);
    }];
    
    [imgArrowStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tfStartTime).offset(-5.0);
        make.centerY.equalTo(tfStartTime.mas_centerY);
        make.width.height.mas_equalTo(16.0);
    }];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                  blue:(70/255.0) alpha:1.0];
    [datePicker setValue:UIColor.whiteColor forKey:@"textColor"];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
//    [datePicker addTarget:self
//                   action:@selector(onDatePickerValueChanged:)
//         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    //  add start toolbar
    toolBar = [[UIToolbar alloc] init];
    toolBar.barTintColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                            blue:(70/255.0) alpha:1.0];
    toolBar.tintColor = UIColor.whiteColor;
    toolBar.translucent = NO;
    toolBar.clipsToBounds = YES;
    [self.view addSubview: toolBar];
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(datePicker.mas_top);
        make.height.mas_equalTo(0);
    }];
    [self addActionForToolbarView];
    
    UILabel *lbSepa = [[UILabel alloc] init];
    lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                              blue:(220/255.0) alpha:1.0];
    [toolBar addSubview: lbSepa];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(toolBar);
        make.height.mas_equalTo(1.0);
    }];
    
    [btnStartTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(tfStartTime);
    }];
    
    lbEndTime.text = text_end_date;
    lbEndTime.textColor = lbStartTime.textColor;
    lbEndTime.font = lbStartTime.font;
    [lbEndTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbStartTime);
        make.top.equalTo(lbStartTime.mas_bottom).offset(padding);
        make.height.mas_equalTo(hTextfield);
    }];
    
    tfEndTime.placeholder = SFM(@"--%@--", text_choose_time);
    tfEndTime.textColor = tfStartTime.textColor;
    tfEndTime.font = tfStartTime.font;
    [tfEndTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tfStartTime);
        make.top.bottom.equalTo(lbEndTime);
    }];
    
    [imgArrowEnd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tfEndTime).offset(-5.0);
        make.centerY.equalTo(tfEndTime.mas_centerY);
        make.width.height.mas_equalTo(16.0);
    }];
    
    [btnEndTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(tfEndTime);
    }];
    
    [btnSearch setTitle:text_search forState:UIControlStateNormal];
    btnSearch.titleLabel.font = appDelegate.fontNormalRegular;
    [btnSearch setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSearch.backgroundColor = [UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                                 blue:(70/255.0) alpha:1.0];
    btnSearch.layer.cornerRadius = 8.0;
    [btnSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tfEndTime);
        make.top.equalTo(tfEndTime.mas_bottom).offset(padding);
        make.height.mas_equalTo(hTextfield);
    }];
    
    [btnListFiles setTitle:text_saved_list forState:UIControlStateNormal];
    btnListFiles.titleLabel.font = appDelegate.fontNormalRegular;
    [btnListFiles setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    btnListFiles.backgroundColor = GRAY_235;
    btnListFiles.layer.cornerRadius = btnSearch.layer.cornerRadius;
    [btnListFiles mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbEndTime);
        make.top.bottom.equalTo(btnSearch);
    }];
    
    
    lbNoData.backgroundColor = GRAY_235;
    lbNoData.textColor = UIColor.darkGrayColor;
    lbNoData.font = appDelegate.fontNormalRegular;
    lbNoData.text = text_no_data;
    [lbNoData mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.bottom.equalTo(self.view).offset(-padding-self.tabBarController.tabBar.frame.size.height);
        make.top.equalTo(btnSearch.mas_bottom).offset(padding);
    }];
    
    [tbListCall registerNib:[UINib nibWithNibName:@"HistoryCallCell" bundle:nil] forCellReuseIdentifier:@"HistoryCallCell"];
    tbListCall.delegate = self;
    tbListCall.dataSource = self;
    tbListCall.backgroundColor = GRAY_235;
    tbListCall.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbListCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(lbNoData);
    }];
}

- (void)showSelectedDate {
    [self closeDatePicker];
    if (indexSelected == 1) {
        tfStartTime.text = [dateFormatter stringFromDate:datePicker.date];
        startDate = datePicker.date;
        
    }else if (indexSelected == 2) {
        tfEndTime.text = [dateFormatter stringFromDate:datePicker.date];
        endDate = datePicker.date;
    }
}

- (void)addActionForToolbarView {
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:text_choose style:UIBarButtonItemStyleBordered target:self action:@selector(showSelectedDate)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *todayBtn = [[UIBarButtonItem alloc]initWithTitle:[text_today uppercaseString] style:UIBarButtonItemStyleBordered target:self action:@selector(showTodayDate)];
    
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:text_close style:UIBarButtonItemStyleBordered target:self action:@selector(closeDatePicker)];
    
    [toolBar setItems:[NSArray arrayWithObjects:cancelBtn, space1, todayBtn,space,doneBtn, nil]];
}

- (void)showTodayDate {
    datePicker.date = [NSDate date];
}

- (void)closeDatePicker {
    [datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    [toolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(datePicker.mas_top);
        make.height.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showListRecordsFileIfNeed {
    if (listData.count > 0) {
        tbListCall.hidden = NO;
        lbNoData.hidden = YES;
        [tbListCall reloadData];
    }else{
        tbListCall.hidden = YES;
        lbNoData.hidden = NO;
    }
}

- (void)btnRecordOnCellPressed: (UIButton *)sender {
    NSString *userfield = sender.currentTitle;
    if (![AppUtil isNullOrEmpty: userfield]) {
        NSArray *tmpArr = [userfield componentsSeparatedByString:@"/"];
        if (tmpArr.count > 0) {
            recordFile = [tmpArr lastObject];
            
            BOOL exists = [AppUtil checkRecordsFileExistsInLocal: recordFile];
            if (!exists) {
                [ProgressHUD backgroundColor: ProgressHUD_BG];
                [ProgressHUD show:text_waiting Interaction:NO];
                
                NSString *params = SFM(@"username=%@&userfield=%@", USERNAME, userfield);
                [WebServiceUtil getInstance].delegate = self;
                [[WebServiceUtil getInstance] callWebServiceWithFunction:get_file_record withParams:params inBackgroundMode:TRUE];
                
            }else{
                [self openAudioRecordFileWithName: recordFile];
            }
        }
    }
}

- (void)openAudioRecordFileWithName: (NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    NSString *localFile = SFM(@"%@/%@/%@", url, recordsFolderName, filename);
    NSURL *audioURL = [NSURL fileURLWithPath: localFile];
    //init player
    AVPlayer *player = [AVPlayer playerWithURL: audioURL];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.showsPlaybackControls = YES;
    playerViewController.player = player;
    //  [self presentViewController:playerViewController animated:YES completion:nil];
    [player play];
    
    [self.view.window.rootViewController presentViewController:playerViewController animated:YES completion:nil];
}

#pragma mark - webservice delegate
-(void)failedToGetListRecordFilesWithError:(id)error {
    [ProgressHUD dismiss];
    [self.view makeToast:@"Không thể lấy danh sách file ghi âm!" duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

-(void)getListRecordFilesSuccessfullyWithData:(id)data {
    [ProgressHUD dismiss];
    if ([data isKindOfClass:[NSArray class]]) {
        [listData addObjectsFromArray:(NSArray *)data];
    }
    [self showListRecordsFileIfNeed];
}

-(void)failedToGetFileRecordWithError:(id)error {
    [ProgressHUD dismiss];
    [self.view makeToast:@"Không thể lấy nội dung file ghi âm!" duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

-(void)getFileRecordSuccessfullyWithData:(id)data {
    [ProgressHUD dismiss];
    
    if (![AppUtil isNullOrEmpty: recordFile]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *url = [paths objectAtIndex:0];
        
        NSString *filePath = SFM(@"%@/%@/%@", url, recordsFolderName, recordFile);
        BOOL success = [data writeToFile:filePath atomically:YES];
        if (success) {
            [self openAudioRecordFileWithName: recordFile];
        }else{
            [self.view makeToast:@"Không thể tải file ghi âm. Vui lòng thử lại sau!" duration:2.5 position:CSToastPositionCenter];
        }
    }
}

#pragma mark - UITableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCallCell *cell = (HistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: @"HistoryCallCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *callInfo = [listData objectAtIndex: indexPath.row];
    NSString *dst = [callInfo objectForKey:@"dst"];
    NSString *src = [callInfo objectForKey:@"src"];
    NSString *userfield = [callInfo objectForKey:@"userfield"];
    
    id timeObj = [callInfo objectForKey:@"createdate"];
    
    long timeInterval = 0;
    if ([timeObj isKindOfClass:[NSNumber class]] || [timeObj isKindOfClass:[NSString class]]) {
        timeInterval = [timeObj longValue];
    }
    
    if ([src isEqualToString: myExt]) {
        cell._imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
        cell._lbPhone.text = dst;
    }else{
        cell._imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        cell._lbPhone.text = src;
    }
    
    if (timeInterval > 0) {
        NSString *date = [AppUtil getDateStringFromTimeInterval: timeInterval];
        cell.lbDate.text = date;
        
        NSString *time = [AppUtil getTimeStringFromTimeInterval: timeInterval];
        cell.lbTime.text = time;
    }else{
        cell.lbDate.text = @"N/A";
        cell.lbTime.text = @"N/A";
    }
    
    NSString *name = [ContactsUtil getContactNameWithNumber: cell._lbPhone.text];
    if (![AppUtil isNullOrEmpty: name]) {
        if (![name isEqualToString: cell._lbPhone.text]) {
            cell._lbName.text = name;
        }else{
            cell._lbName.text = text_unknown;
        }
    }else{
        cell._lbName.text = text_unknown;
    }
    cell.lbMissed.hidden = TRUE;
//    cell._cbDelete.hidden = TRUE;
    
    [cell._btnCall setTitle:userfield forState:UIControlStateNormal];
    [cell._btnCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    [cell._btnCall setImage:[UIImage imageNamed:@"ic_record.png"] forState:UIControlStateNormal];
    [cell._btnCall addTarget:self
                      action:@selector(btnRecordOnCellPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    cell._lbSepa.backgroundColor = GRAY_240;

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

@end

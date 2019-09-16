//
//  SendLogsViewController.m
//  linphone
//
//  Created by lam quang quan on 11/27/18.
//

#import "SendLogsViewController.h"
#import "SendLogFileCell.h"
#import <MessageUI/MessageUI.h>
#import "AESCrypt.h"

@interface SendLogsViewController ()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>{
    AppDelegate *appDelegate;
    NSMutableArray *listFiles;
    NSMutableArray *listSelect;
}

@end

@implementation SendLogsViewController
@synthesize viewHeader, bgHeader, icBack, lbHeader, icSend, tbLogs;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    //  remove other files if it is not log file
    [DeviceUtil cleanLogFolder];
    [WriteLogsUtil clearLogFilesAfterExpireTime: DAY_FOR_LOGS*24*3600];
    
    icSend.enabled = NO;
    lbHeader.text = text_send_logs;
    [icSend setTitle:text_send forState:UIControlStateNormal];
    [icSend setTitle:text_send forState:UIControlStateDisabled];
    
    if (listSelect == nil) {
        listSelect = [[NSMutableArray alloc] init];
    }
    [listSelect removeAllObjects];
    
    if (listFiles == nil) {
        listFiles = [[NSMutableArray alloc] init];
    }
    [listFiles removeAllObjects];
    [listFiles addObjectsFromArray:[WriteLogsUtil getAllFilesInDirectory:logsFolderName]];
    [tbLogs reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)icSendClicked:(UIButton *)sender {
    /*
    NSString *totalEmail = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"lekhai0212@gmail.com", @"Send logs file", messageSend];
    NSString *url = [totalEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
    */
    
    if ([MFMailComposeViewController canSendMail]) {
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:pls_check_your_network_connection duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        
        NSString *emailTitle =  @"Gửi nhật ký ứng dụng";
        NSString *messageBody = @"";
        NSArray *toRecipents = [NSArray arrayWithObject:@"lekhai0212@gmail.com"];
        
        for (int i=0; i<listSelect.count; i++)
        {
            NSIndexPath *curIndex = [listSelect objectAtIndex: i];
            NSString *fileName = [listFiles objectAtIndex: curIndex.row];
            NSString *path = [WriteLogsUtil getPathOfFileWithSubDir:SFM(@"%@/%@", logsFolderName, fileName)];
            NSString* content = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
            NSString *encryptStr = [AESCrypt encrypt:content password:AES_KEY];
            NSData *logFileData = [encryptStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *nameForSend = [DeviceUtil convertLogFileName: fileName];
            [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:nameForSend];
        }
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        [self.view makeToast:text_can_not_send_email duration:3.0 position:CSToastPositionCenter];
    }
}

//  setup ui trong view
- (void)setupUIForView
{
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
    
    [icSend setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [icSend setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    [icSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader).offset(-10.0);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.mas_equalTo(80.0);
        make.height.mas_equalTo(40.0);
    }];
    
    tbLogs.backgroundColor = UIColor.clearColor;
    [tbLogs registerNib:[UINib nibWithNibName:@"SendLogFileCell" bundle:nil] forCellReuseIdentifier:@"SendLogFileCell"];
    tbLogs.delegate = self;
    tbLogs.dataSource = self;
    tbLogs.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbLogs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.bottom.left.right.equalTo(self.view);
    }];
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SendLogFileCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SendLogFileCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *fileName = [listFiles objectAtIndex: indexPath.row];
    fileName = [DeviceUtil convertLogFileName: fileName];
    cell.lbName.text = fileName;
    
    if (![listSelect containsObject: indexPath]) {
        cell.imgSelect.image = [UIImage imageNamed:@"ic_not_check.png"];
    }else{
        cell.imgSelect.image = [UIImage imageNamed:@"ic_checked.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![listSelect containsObject: indexPath]) {
        [listSelect addObject: indexPath];
    }else{
        [listSelect removeObject: indexPath];
    }
    [tbLogs reloadData];
    if (listSelect.count > 0) {
        icSend.enabled = YES;
    }else{
        icSend.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        [self.view makeToast:text_can_not_send_email_check_later duration:4.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:text_email_was_sent duration:4.0 position:CSToastPositionCenter];
    }
    [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

//
//  ChooseRingtoneViewController.m
//  linphone
//
//  Created by lam quang quan on 3/14/19.
//

#import "ChooseRingtoneViewController.h"
#import "ChooseRingToneCell.h"
#import "PlayRingTonePopupView.h"

@interface ChooseRingtoneViewController ()<UITableViewDelegate, UITableViewDataSource, PlayRingTonePopupViewDelegate>{
    AppDelegate *appDelegate;
    NSMutableArray *ringtones;
}

@end

@implementation ChooseRingtoneViewController
@synthesize viewHeader, bgHeader, iconBack, lbTitle, tbList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtil writeForGoToScreen:@"ChooseRingtoneViewController"];
    
    self.navigationController.navigationBarHidden = TRUE;
    [self getListRingTonesFromFile];
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iconBackClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (void)autoLayoutForView {
    float hHeader = appDelegate.hStatus + appDelegate.hNav;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    lbTitle.font = appDelegate.fontLargeRegular;
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(appDelegate.hStatus);
        make.bottom.equalTo(viewHeader);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(250);
    }];
    
    if (SCREEN_WIDTH > 320) {
        iconBack.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    }else{
        iconBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    }
    [iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbTitle.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    tbList.showsVerticalScrollIndicator = FALSE;
    tbList.separatorStyle = UITableViewCellSelectionStyleNone;
    [tbList registerNib:[UINib nibWithNibName:@"ChooseRingToneCell" bundle:nil] forCellReuseIdentifier:@"ChooseRingToneCell"];
    tbList.delegate = self;
    tbList.dataSource = self;
    [tbList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)getListRingTonesFromFile {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"RingTone"
                                                         ofType:@"plist"];
    NSArray *plist = [NSArray arrayWithContentsOfFile: filePath];
    if (ringtones == nil) {
        ringtones = [[NSMutableArray alloc] init];
    }
    [ringtones removeAllObjects];
    
    if (plist != nil) {
        [ringtones addObjectsFromArray: plist];
    }
}

- (void)finishedSetRingTone:(NSString *)ringtone {
    [tbList reloadData];
    appDelegate.del = nil;
    appDelegate.del = [[ProviderDelegate alloc] init];
    [appDelegate.del config];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ringtones.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseRingToneCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ChooseRingToneCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *curRingTone = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_RINGTONE];
    
    if (indexPath.row == 0) {
        cell.lbName.text = text_silent;
        cell.imgRingTone.image = [UIImage imageNamed:@"no_sound"];
        
        if ([curRingTone isEqualToString:@"silence.mp3"]) {
            cell.imgSelected.hidden = FALSE;
        }else{
            cell.imgSelected.hidden = TRUE;
        }
    }else if (indexPath.row == 1){
        cell.lbName.text = text_default;
        cell.imgRingTone.image = [UIImage imageNamed:@"more_ringtone"];
        if ([AppUtil isNullOrEmpty: curRingTone]) {
            cell.imgSelected.hidden = FALSE;
        }else{
            cell.imgSelected.hidden = TRUE;
        }
    }else{
        NSDictionary *ringtone = [ringtones objectAtIndex: (indexPath.row-2)];
        NSString *name = [ringtone objectForKey:@"name"];
        cell.lbName.text = name;
        cell.imgRingTone.image = [UIImage imageNamed:@"more_ringtone"];
        
        NSString *file = [ringtone objectForKey:@"file"];
        if ([file isEqualToString: curRingTone]) {
            cell.imgSelected.hidden = FALSE;
        }else{
            cell.imgSelected.hidden = TRUE;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:SILENCE_RINGTONE forKey:DEFAULT_RINGTONE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self finishedSetRingTone: SILENCE_RINGTONE];
        
    }else if (indexPath.row == 1){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DEFAULT_RINGTONE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self finishedSetRingTone: SILENCE_RINGTONE];
    }else{
        float hPopup = 15 + 40.0 + 15.0 + 50.0;
        PlayRingTonePopupView *popupRingTone = [[PlayRingTonePopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-300.0)/2, (SCREEN_HEIGHT-hPopup)/2, 300.0, hPopup)];
        popupRingTone.delegate = self;
        [popupRingTone showInView:self.view animated:TRUE];
        
        NSDictionary *ringtone = [ringtones objectAtIndex: (indexPath.row-2)];
        [popupRingTone setRingtoneInfoContent: ringtone];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}


@end

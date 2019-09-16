//
//  PlayRingTonePopupView.m
//  linphone
//
//  Created by lam quang quan on 3/15/19.
//

#import "PlayRingTonePopupView.h"

@implementation PlayRingTonePopupView
@synthesize delegate, lbTitle, btnPlay, btnClose, btnSet, lbSepaVertical, lbSepaHorzital, file, player;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        float hButton = 50.0;
        
        // Initialization code
        self.backgroundColor =  UIColor.whiteColor;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 12.0;
        
        btnClose = [[UIButton alloc] init];
        [btnClose setTitle:text_close forState:UIControlStateNormal];
        btnClose.titleLabel.font = [AppDelegate sharedInstance].fontNormalRegular;
        [btnClose setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [btnClose addTarget:self
                     action:@selector(closePopupView)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: btnClose];
        [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(self);
            make.right.equalTo(self.mas_centerX);
            make.height.mas_equalTo(hButton);
        }];
        
        btnSet = [[UIButton alloc] init];
        [btnSet setTitle:text_setup forState:UIControlStateNormal];
        btnSet.titleLabel.font = [AppDelegate sharedInstance].fontNormalMedium;
        [btnSet setTitleColor:[UIColor colorWithRed:(101/255.0) green:(205/255.0)
                                               blue:(70/255.0) alpha:1.0]
                     forState:UIControlStateNormal];
        [btnSet addTarget:self
                   action:@selector(setRingtoneForCall)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: btnSet];
        [btnSet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX);
            make.right.bottom.equalTo(self);
            make.height.mas_equalTo(hButton);
        }];
        
        lbSepaVertical = [[UILabel alloc] init];
        lbSepaVertical.backgroundColor = GRAY_240;
        [self addSubview: lbSepaVertical];
        [lbSepaVertical mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(1.0);
            make.height.mas_equalTo(hButton);
        }];
        
        lbSepaHorzital = [[UILabel alloc] init];
        lbSepaHorzital.backgroundColor = GRAY_240;
        [self addSubview: lbSepaHorzital];
        [lbSepaHorzital mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(-hButton);
            make.height.mas_equalTo(1.0);
        }];
        
        
        btnPlay = [[UIButton alloc] init];
        [btnPlay setImage:[UIImage imageNamed:@"ringtone_play"] forState:UIControlStateNormal];
        [btnPlay addTarget:self
                    action:@selector(playRingTone:)
          forControlEvents:UIControlEventTouchUpInside];
        btnPlay.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [self addSubview: btnPlay];
        
        [btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10.0);
            make.top.equalTo(self).offset(15.0);
            make.width.height.mas_equalTo(40.0);
        }];
        
        lbTitle = [[UILabel alloc] init];
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.font = [AppDelegate sharedInstance].fontNormalRegular;
        lbTitle.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
        [self addSubview: lbTitle];
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(btnPlay.mas_right).offset(5.0);
            make.right.equalTo(self).offset(-5.0);
            make.top.bottom.equalTo(btnPlay);
        }];
    }
    return self;
}


- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    UIView *viewBackground = [[UIView alloc] init];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    [viewBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(aView);
    }];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.superview.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

- (void)setRingtoneInfoContent: (NSDictionary *)ringtone {
    NSString *name = [ringtone objectForKey:@"name"];
    file = [ringtone objectForKey:@"file"];
    lbTitle.text = name;
}

- (void)playRingTone: (UIButton *)sender
{
    if (player == nil) {
        NSString *tmpFile = file;
        if ([tmpFile hasSuffix:@".mp3"]) {
            tmpFile = [tmpFile stringByReplacingOccurrencesOfString:@".mp3" withString:@""];
        }
        
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:tmpFile ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL URLWithString: soundFilePath];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        player.numberOfLoops = 0; //Infinite
        player.volume = 1.0;
        [player prepareToPlay];
        player.delegate = self;
    }
    
    if (player.playing) {
        [player stop];
        player.currentTime = 0;
        [sender setImage:[UIImage imageNamed:@"ringtone_play"] forState:UIControlStateNormal];
    }else {
        [player play];
        [sender setImage:[UIImage imageNamed:@"ringtone_stop"] forState:UIControlStateNormal];
    }
}

- (void)closePopupView {
    if (player.playing) {
        [player stop];
    }
    player = nil;
    [self fadeOut];
}

- (void)setRingtoneForCall {
    if (![AppUtil isNullOrEmpty: file]) {
        [[NSUserDefaults standardUserDefaults] setObject:file forKey:DEFAULT_RINGTONE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [delegate finishedSetRingTone: file];
    [self closePopupView];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [btnPlay setImage:[UIImage imageNamed:@"ringtone_play"] forState:UIControlStateNormal];
    player.currentTime = 0;
}

@end

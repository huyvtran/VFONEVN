//
//  CallViewController.h
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"

typedef enum CallDirection{
    OutgoingCall,
    IncomingCall,
}CallDirection;

NS_ASSUME_NONNULL_BEGIN

@interface CallViewController : UIViewController

//  out going call view
@property (weak, nonatomic) IBOutlet UIView *viewOutgoing;
@property (weak, nonatomic) IBOutlet UIImageView *bgOutgoing;
@property (weak, nonatomic) IBOutlet UILabel *lbOutgoingName;
@property (weak, nonatomic) IBOutlet UILabel *lbOutgoingPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgCallState;
@property (weak, nonatomic) IBOutlet UILabel *lbOutgoingState;
@property (weak, nonatomic) IBOutlet UIImageView *imgOutgoingAvatar;
@property (weak, nonatomic) IBOutlet UIButton *icOutgoingSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *icOutgoingHangup;
@property (weak, nonatomic) IBOutlet UIButton *icOutgoingMute;

- (IBAction)icOutgoingSpeakerClick:(UIButton *)sender;
- (IBAction)icOutgoingHangupCallClick:(UIButton *)sender;
- (IBAction)icOutgoingMuteClick:(UIButton *)sender;

//  call detail view

@property (weak, nonatomic) IBOutlet UIView *viewCall;
@property (weak, nonatomic) IBOutlet UIImageView *bgCall;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbConnect;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *iconMute;
@property (weak, nonatomic) IBOutlet UIButton *iconSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *iconHangup;
@property (weak, nonatomic) IBOutlet UIButton *iconHold;
@property (weak, nonatomic) IBOutlet UIButton *iconMiniKeypad;

- (IBAction)iconMuteClick:(UIButton *)sender;
- (IBAction)iconSpeakerClick:(UIButton *)sender;
- (IBAction)iconHangupClick:(UIButton *)sender;
- (IBAction)iconHoldCallClick:(UIButton *)sender;
- (IBAction)iconMiniKeypadClick:(UIButton *)sender;

@property (nonatomic, strong) NSString *remoteNumber;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) CallDirection callDirection;
@property (nonatomic, weak) PulsingHaloLayer *halo;

@end

NS_ASSUME_NONNULL_END

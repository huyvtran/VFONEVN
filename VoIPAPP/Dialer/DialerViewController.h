//
//  DialerViewController.h
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DialerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogoSmall;
@property (weak, nonatomic) IBOutlet UILabel *lbAccount;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

@property (weak, nonatomic) IBOutlet UIView *viewNumber;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *icClear;

@property(nonatomic, strong) IBOutlet UIButton *oneButton;
@property(nonatomic, strong) IBOutlet UIButton *twoButton;
@property(nonatomic, strong) IBOutlet UIButton *threeButton;
@property(nonatomic, strong) IBOutlet UIButton *fourButton;
@property(nonatomic, strong) IBOutlet UIButton *fiveButton;
@property(nonatomic, strong) IBOutlet UIButton *sixButton;
@property(nonatomic, strong) IBOutlet UIButton *sevenButton;
@property(nonatomic, strong) IBOutlet UIButton *eightButton;
@property(nonatomic, strong) IBOutlet UIButton *nineButton;
@property(nonatomic, strong) IBOutlet UIButton *starButton;
@property(nonatomic, strong) IBOutlet UIButton *zeroButton;
@property(nonatomic, strong) IBOutlet UIButton *hashButton;
@property(weak, nonatomic) IBOutlet UIView *padView;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa123;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa456;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa789;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoCall;
@property(nonatomic, strong) IBOutlet UIButton *callButton;
@property(weak, nonatomic) IBOutlet UIButton *backspaceButton;

- (IBAction)btnNumberPressed:(UIButton *)sender;
- (IBAction)btnCallPressed:(UIButton *)sender;
- (IBAction)icClearClick:(UIButton *)sender;
- (IBAction)btnVideoCallPress:(UIButton *)sender;
- (IBAction)onBackspaceClick:(id)sender;

@end

NS_ASSUME_NONNULL_END

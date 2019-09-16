//
//  SignInViewController.h
//  linphone
//
//  Created by lam quang quan on 2/25/19.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderDelegate.h"

@interface SignInViewController : UIViewController<QRCodeReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//  Welcome view
@property (weak, nonatomic) IBOutlet UIView *viewWelcome;
@property (weak, nonatomic) IBOutlet UIImageView *imgWelcome;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogoWelcome;
@property (weak, nonatomic) IBOutlet UILabel *lbSlogan;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
- (IBAction)btnStartPress:(UIButton *)sender;

//  signin view
@property (weak, nonatomic) IBOutlet UIView *viewSignIn;
@property (weak, nonatomic) IBOutlet UIButton *iconBack;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;

@property (weak, nonatomic) IBOutlet UITextField *tfAccountID;
@property (weak, nonatomic) IBOutlet UIButton *btnAccountID;

@property (weak, nonatomic) IBOutlet UIButton *btnShowPass;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnQRCode;

- (IBAction)iconBackPress:(UIButton *)sender;
- (IBAction)btnQRCodePress:(UIButton *)sender;
- (IBAction)btnSignInPress:(UIButton *)sender;
- (IBAction)btnShowPassPress:(UIButton *)sender;

@end

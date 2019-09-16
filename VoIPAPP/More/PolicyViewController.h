//
//  PolicyViewController.h
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import <UIKit/UIKit.h>

@interface PolicyViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIWebView *_wvPolicy;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

- (IBAction)_iconBackClicked:(UIButton *)sender;

@end

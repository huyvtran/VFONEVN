//
//  MoreViewController.h
//  linphone
//
//  Created by user on 1/7/14.
//
//

#import <UIKit/UIKit.h>

enum moreValue{
    eDNDMode,
    eAppInfo,
//    eSendLogs,
    ePrivayPolicy,
    eIntroduction,
    eSignOut,
};

enum stateLogout {
    eRemoveTokenSIP = 1,
    eRemoveTokenPBX
};

@interface MoreViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPBXAccount;
@property (weak, nonatomic) IBOutlet UITableView *_tbContent;

@end

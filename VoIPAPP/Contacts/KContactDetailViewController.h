//
//  KContactDetailViewController.h
//  linphone
//
//  Created by mac book on 11/5/15.
//
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@interface KContactDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

//  view header
@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (retain, nonatomic) IBOutlet UILabel *_lbContactName;
@property (retain, nonatomic) IBOutlet UITableView *_tbContactInfo;

- (IBAction)_iconBackClicked:(id)sender;

@property (nonatomic, strong) ContactObject *detailsContact;
@property (nonatomic, assign) int idContact;

@end

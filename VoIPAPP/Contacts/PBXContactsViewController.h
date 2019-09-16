//
//  PBXContactsViewController.h
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import <UIKit/UIKit.h>

@interface PBXContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnGoSettings;

- (IBAction)btnGoSettingsPress:(UIButton *)sender;
@end

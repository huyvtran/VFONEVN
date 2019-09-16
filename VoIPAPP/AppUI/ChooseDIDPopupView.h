//
//  ChooseDIDPopupView.h
//  linphone
//
//  Created by lam quang quan on 3/13/19.
//

#import <UIKit/UIKit.h>

@protocol ChooseDIDPopupViewDelegate
@optional
- (void)selectDIDForCallWithPrefix: (NSString *)prefix;
@end

@interface ChooseDIDPopupView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) id <NSObject, ChooseDIDPopupViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *listDID;
@property (nonatomic, strong) UILabel *lbHeader;
@property (nonatomic, strong) UILabel *lbSepa;
@property (nonatomic, strong) UITableView *tbDIDList;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) float hCell;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end

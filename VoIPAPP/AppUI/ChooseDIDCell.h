//
//  ChooseDIDCell.h
//  linphone
//
//  Created by admin on 3/13/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseDIDCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbDIDNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

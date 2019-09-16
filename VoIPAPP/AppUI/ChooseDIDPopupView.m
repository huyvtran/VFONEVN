//
//  ChooseDIDPopupView.m
//  linphone
//
//  Created by lam quang quan on 3/13/19.
//

#import "ChooseDIDPopupView.h"
#import "ChooseDIDCell.h"

@implementation ChooseDIDPopupView
@synthesize tbDIDList, lbHeader, tapGesture, delegate, listDID, lbSepa, hCell;

-(void)layoutSubviews {
    NSLog(@"layoutSubviews");
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        // Initialization code
        if (SCREEN_WIDTH > 320) {
            hCell = 60.0;
        }else{
            hCell = 50.0;
        }
        
        self.backgroundColor =  UIColor.whiteColor;
        listDID = [[NSMutableArray alloc] init];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 12.0;
        
        lbHeader = [[UILabel alloc] init];
        lbHeader.textAlignment = NSTextAlignmentCenter;
        lbHeader.text = text_choose_DID;
        lbHeader.textColor = [UIColor colorWithRed:(80/255.0) green:(208/255.0) blue:(135/255.0) alpha:1.0];
        lbHeader.font = [AppDelegate sharedInstance].fontLargeMedium;
        [self addSubview: lbHeader];
        [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(hCell);
        }];
        
        tbDIDList = [[UITableView alloc] init];
        [tbDIDList registerNib:[UINib nibWithNibName:@"ChooseDIDCell" bundle:nil] forCellReuseIdentifier:@"ChooseDIDCell"];
        tbDIDList.delegate = self;
        tbDIDList.dataSource = self;
        tbDIDList.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: tbDIDList];
        
        [tbDIDList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lbHeader.mas_bottom);
            make.left.bottom.right.equalTo(self);
        }];
        
        lbSepa = [[UILabel alloc] init];
        lbSepa.backgroundColor = GRAY_245;
        [self addSubview: lbSepa];
        [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(lbHeader.mas_bottom);
            make.height.mas_equalTo(1.0);
        }];
    }
    return self;
}


- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] init];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    [viewBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(aView);
    }];
    
    [viewBackground addGestureRecognizer:tapGesture];
    
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
    }completion:^(BOOL finished) {
        [self updateScrollEnable];
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews)
    {
        if (subView.tag == 20)
        {
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

- (void)closePopupViewWhenTagOut{
    [AppDelegate sharedInstance].phoneForCall = @"";
    
    [self fadeOut];
    [self.superview removeGestureRecognizer:tapGesture];
}

- (void)updateScrollEnable {
    if (tbDIDList.frame.size.height < tbDIDList.contentSize.height) {
        tbDIDList.scrollEnabled = YES;
    }else{
        tbDIDList.scrollEnabled = NO;
    }
}

#pragma mark - UITableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listDID.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseDIDCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ChooseDIDCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        cell.lbTitle.text = text_default;
        cell.lbDIDNumber.text = @"";
    }else{
        NSDictionary *info = [listDID objectAtIndex: indexPath.row-1];
        NSString *did = [info objectForKey:@"did"];
        NSString *name = [info objectForKey:@"name"];
        
        if (![AppUtil isNullOrEmpty: did]) {
            cell.lbDIDNumber.text = did;
        }else{
            cell.lbDIDNumber.text = @"";
        }
        
        if (![AppUtil isNullOrEmpty: name]) {
            cell.lbTitle.text = name;
        }else{
            cell.lbTitle.text = @"";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    if (indexPath.row == 0) {
        if ([delegate respondsToSelector:@selector(selectDIDForCallWithPrefix:)]) {
            [delegate selectDIDForCallWithPrefix:@""];
        }
    }else{
        NSDictionary *info = [listDID objectAtIndex: indexPath.row-1];
        NSString *prefix = [info objectForKey:@"prefix"];
        if ([delegate respondsToSelector:@selector(selectDIDForCallWithPrefix:)]) {
            [delegate selectDIDForCallWithPrefix: prefix];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

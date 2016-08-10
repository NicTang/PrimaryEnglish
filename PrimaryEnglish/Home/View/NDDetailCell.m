//
//  NDDetailCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDDetailCell.h"
#import "NDDetailModel.h"
#import "UIImageView+AFNetworking.h"

@interface NDDetailCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIButton *isFreeBtn;
- (IBAction)freeBtnClick:(id)sender;

@end
@implementation NDDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setModel:(NDDetailModel *)model
{
    _model = model;
    NSString *imgStr = [NSString stringWithFormat:PrefixForUrl,model.cover];
    [self.iconView setImageWithURL:[NSURL URLWithString:imgStr]];
    self.unitLabel.text = model.title;
    self.isFreeBtn.contentMode = UIViewContentModeLeft;
    self.isFreeBtn.layer.borderWidth = 1;
    self.isFreeBtn.layer.cornerRadius = 6;
    [self.isFreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.isFreeBtn.layer.borderColor = Color(234, 103, 37).CGColor;
    self.isFreeBtn.backgroundColor = Color(234, 103, 37);
    self.isFreeBtn.hidden = [model.free doubleValue]==0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)freeBtnClick:(id)sender {
}
@end

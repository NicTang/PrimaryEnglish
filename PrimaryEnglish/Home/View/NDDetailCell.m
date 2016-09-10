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
    [self.unitLabel setFont:[UIFont systemFontOfSize:15*ScaleValueY]];
    
    NSDictionary *dict = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:15*ScaleValueY]};
    NSAttributedString *attrs = [[NSAttributedString alloc]initWithString:@"免费试学" attributes:dict];
    self.isFreeBtn.contentMode = UIViewContentModeCenter;
    [self.isFreeBtn setAttributedTitle:attrs forState:UIControlStateNormal];
    self.isFreeBtn.layer.cornerRadius = 6;
    self.isFreeBtn.backgroundColor = Color(234, 103, 37);
    self.isFreeBtn.hidden = [model.free doubleValue]==0;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)freeBtnClick:(id)sender {
}
@end

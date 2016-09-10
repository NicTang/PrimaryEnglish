//
//  NDHomeCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDHomeCell.h"
#import "UIImageView+AFNetworking.h"
#import "NDHomeModel.h"

@interface NDHomeCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation NDHomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setModel:(NDHomeModel *)model
{
    _model = model;
    NSString *imgStr = [NSString stringWithFormat:@"http://app.ekaola.com/%@",model.img];
    [self.iconView setImageWithURL:[NSURL URLWithString:imgStr]];
    self.nameLabel.text = model.name;
    [self.nameLabel setFont:[UIFont systemFontOfSize:10*ScaleValueY]];
}
@end

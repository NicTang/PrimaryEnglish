//
//  NDMeCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/12.
//  Copyright © 2020年 Nic. All rights reserved.
//

#import "NDIconCell.h"
#import "UserModel.h"

@interface NDIconCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end
@implementation NDIconCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setModel:(UserModel *)model
{
    _model = model;
    self.iconView.image = [UIImage imageNamed:model.icon];
    self.nickNameLabel.text = model.nickName;
    
}
@end

//
//  NDHeaderCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDHeaderCell.h"
#import "UserModel.h"
#import "UIImage+NewImage.h"

@interface NDHeaderCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end
@implementation NDHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = Color(234, 103, 37);
}

- (void)setModel:(UserModel *)model
{
    _model = model;
    UIImage *image = [UIImage clipImageWithImage:model.image setSize:self.iconView.frame.size];
    self.iconView.image = image;
        
//    self.iconView.image = model.image;
    self.nickNameLabel.text = model.nickName;
//    self.iconView.layer.cornerRadius = 50;
//    self.iconView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

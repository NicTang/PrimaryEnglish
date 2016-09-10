//
//  NDHeaderCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define PlaceHolderImg [UIImage imageNamed:@"placeholderImage"]

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
    
    UIImage *image = PlaceHolderImg;
    if (model.status==0&&image!=model.image) {
        image = [UIImage clipImageWithImage:model.image setSize:self.iconView.frame.size];
    }
    self.iconView.image = image;
    self.nickNameLabel.text = model.nickName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

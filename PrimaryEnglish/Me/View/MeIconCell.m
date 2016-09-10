//
//  MeIconCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "MeIconCell.h"
#import "UIImage+NewImage.h"

@interface MeIconCell ()


@end

@implementation MeIconCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setIcon:(UIImage *)icon
{
    _icon = icon;
    UIImage *image = [UIImage clipImageWithImage:icon setSize:self.iconView.frame.size];
    self.iconView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

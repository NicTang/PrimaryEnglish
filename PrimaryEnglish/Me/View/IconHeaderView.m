//
//  IconHeaderView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/12.
//  Copyright © 2020年 Nic. All rights reserved.
//

#import "IconHeaderView.h"
#import "UserModel.h"

@interface IconHeaderView()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

@end
@implementation IconHeaderView

+(instancetype)iconHeaderView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"IconHeaderView" owner:nil options:nil]lastObject];
}
- (void)setModel:(UserModel *)model
{
    _model = model;
    self.iconView.image = [UIImage imageNamed:model.icon];
    self.nickNameLabel.text = model.nickName;
}
@end

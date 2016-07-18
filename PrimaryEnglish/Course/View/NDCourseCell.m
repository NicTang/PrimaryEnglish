//
//  NDCourseCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/12.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDCourseCell.h"
#import "UIImageView+AFNetworking.h"
#import "NDCourseModel.h"

@interface NDCourseCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIView *isFreeBgView;
@property (weak, nonatomic) IBOutlet UILabel *isFreeLabel;

@end
@implementation NDCourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 5;
}
- (void)setModel:(NDCourseModel *)model
{
    _model = model;
    NSString *imgStr = [NSString stringWithFormat:@"http://app.ekaola.com/%@",model.cover];
    [self.iconView setImageWithURL:[NSURL URLWithString:imgStr]];
    self.nameLabel.text = model.title;
    
    [self.isFreeLabel setTextColor:[UIColor whiteColor]];
    self.isFreeBgView.transform = CGAffineTransformMakeRotation(M_PI_4);
    if ([model.price doubleValue]==0) {
        self.isFreeLabel.text = @"免费";
        self.isFreeBgView.backgroundColor = [UIColor greenColor];
    }else
    {
        self.isFreeLabel.text = [NSString stringWithFormat:@"¥ %d",[model.price intValue]];
        self.isFreeBgView.backgroundColor = [UIColor redColor];
    }
}
@end

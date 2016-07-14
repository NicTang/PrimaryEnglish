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
}
@end

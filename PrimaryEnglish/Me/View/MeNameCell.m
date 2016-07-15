//
//  MeNameCell.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "MeNameCell.h"

@interface MeNameCell()
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end
@implementation MeNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setName:(NSString *)name
{
    _name = name;
    self.nickNameLabel.text = name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

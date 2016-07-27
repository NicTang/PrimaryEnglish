//
//  SelectCourseHeader.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/25.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "SelectCourseHeader.h"

@interface SelectCourseHeader ()

- (IBAction)cancelBtnClick:(UIButton *)sender;

@end

@implementation SelectCourseHeader

+ (instancetype)selectCourseHeader
{
    return [[[NSBundle mainBundle]loadNibNamed:@"SelectCourseHeader" owner:nil options:nil]lastObject];
}
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(selectCourseCancel:)]) {
        [self.delegate selectCourseCancel:self];
    }
}
@end

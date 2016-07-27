//
//  SelectCourseHeader.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/25.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectCourseHeader;

@protocol SelectCourseHeaderDelegate <NSObject>

@optional
- (void)selectCourseCancel:(SelectCourseHeader *)header;

@end

@interface SelectCourseHeader : UIView

@property (nonatomic,weak) id<SelectCourseHeaderDelegate> delegate;

+ (instancetype)selectCourseHeader;

@end

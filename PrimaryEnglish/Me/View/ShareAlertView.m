//
//  ShareAlertView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/15.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "ShareAlertView.h"

@interface ShareAlertView()

@property (weak, nonatomic) IBOutlet UIImageView *shareToWeChat;
@property (weak, nonatomic) IBOutlet UIImageView *shareToFriends;
- (IBAction)cancel:(id)sender;

@end

@implementation ShareAlertView

+ (instancetype)shareAlertView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"ShareAlertView" owner:nil options:nil]lastObject];
}

//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    
//}
- (IBAction)cancel:(id)sender
{
    
}
@end

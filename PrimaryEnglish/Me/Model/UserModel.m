//
//  UserModel.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/12.
//  Copyright © 2020年 Nic. All rights reserved.
//
#define NDModelImageKey @"image"
#define NDModelPhoneKey @"phone"
#define NDModelNickNameKey @"nickName"
#define NDModelCodeKey @"code"
#define NDModelStatusKey @"status"

#import "UserModel.h"

@implementation UserModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSData *data = [aDecoder decodeObjectForKey:NDModelImageKey];
    self.image = [UIImage imageWithData:data];
//    self.image = [aDecoder decodeObjectForKey:NDModelImageKey];
    self.phone = [aDecoder decodeObjectForKey:NDModelPhoneKey];
    self.nickName = [aDecoder decodeObjectForKey:NDModelNickNameKey];
    self.code = [aDecoder decodeObjectForKey:NDModelCodeKey];
    self.status = [aDecoder decodeIntegerForKey:NDModelStatusKey];
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSData *data = UIImagePNGRepresentation(self.image);
    [aCoder encodeObject:data forKey:NDModelImageKey];
//    [aCoder encodeObject:self.image forKey:NDModelImageKey];
    [aCoder encodeObject:self.phone forKey:NDModelPhoneKey];
    [aCoder encodeObject:self.nickName forKey:NDModelNickNameKey];
    [aCoder encodeObject:self.code forKey:NDModelCodeKey];
    [aCoder encodeInteger:self.status forKey:NDModelStatusKey];
}
@end

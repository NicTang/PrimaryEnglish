//
//  NDWordModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/3.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDWordModel : NSObject

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *mp3Url;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *tipLabelText;

@end

//
//  UIImage+NewImage.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NewImage)

+ (instancetype)createImageWithColor:(UIColor *)color;

+(instancetype)clipImageWithImage:(UIImage *)image setSize:(CGSize)imgSize;

@end

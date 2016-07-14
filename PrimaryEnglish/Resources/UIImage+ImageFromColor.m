//
//  UIImage+ImageFromColor.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/13.
//  Copyright © 2020年 Nic. All rights reserved.
//

#import "UIImage+ImageFromColor.h"

@implementation UIImage (ImageFromColor)


+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx,rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

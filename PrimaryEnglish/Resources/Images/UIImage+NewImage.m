//
//  UIImage+NewImage.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "UIImage+NewImage.h"

@implementation UIImage (NewImage)

+ (instancetype)createImageWithColor:(UIColor *)color
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
/**
 *  重新设置图片的大小
 */
+ (instancetype)resizeImage:(UIImage *)image ToSize:(CGSize)size
{
    
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}
/**
 *  根据一张图片，返回一张新的指定大小的圆形裁剪图片
 */
+ (instancetype)clipImageWithImage:(UIImage *)image setSize:(CGSize)imgSize
{
    //指定大小的宽度、高度
    CGFloat imageW = imgSize.width;
    CGFloat imageH = imgSize.height;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat radius = imageW * 0.5;
    CGFloat centerX = radius;
    CGFloat centerY = imageH * 0.5;
    CGContextAddArc(ctx, centerX, centerY, radius, 0, M_PI * 2, 0);
    CGContextClip(ctx);
    
    CGContextFillPath(ctx);//画圆
    
    //5、将原图片再画上去
    [image drawInRect:CGRectMake(0, 0, imageW, imageH)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //6、关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

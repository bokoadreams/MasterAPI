//
//  NSImage+ImageEffects.m
//  MasterAPI
//
//  Created by sim on 16/07/17.
//  Copyright © 2017 sim. All rights reserved.
//
#import <CoreImage/CoreImage.h>
#import "NSImage+ImageEffects.h"

@implementation NSImage (ImageEffects)

- (NSImage*)blurImage:(NSURL*)imageURL :(nullable NSData*)data withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radius{
    CIImage *ciImage;
    if(data == nil){
        ciImage = [CIImage imageWithContentsOfURL:imageURL];
    }
    else{
        ciImage = [CIImage imageWithData:data];
    }
    
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    NSImage *nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(radius) forKey:kCIInputRadiusKey];
    
    CIImage *outputCIImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    
    nsImage = [[NSImage alloc]initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return  nsImage;
    
}
@end

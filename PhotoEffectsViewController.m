//
//  PhotoEffectsViewController.m
//  MasterAPI
//
//  Created by sim on 17/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "PhotoEffectsViewController.h"
#import "NSImage+ImageEffects.h"
#import "SYFlatButton+ButtonsStyle.h"
@interface PhotoEffectsViewController ()

@end

@implementation PhotoEffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    effectedImage = [[NSImage alloc]init];
    originalImage = [[NSImage alloc]initWithContentsOfURL:_originalImageURLs[0]];
    [self setImagePreview:originalImage];
    controlsData = [NSMutableDictionary dictionaryWithDictionary:@{@"saturation":@1, @"brightness":@0, @"contrast":@1}];
     ;
    self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    SYFlatButton *flatBut = [[SYFlatButton alloc]init];
    [flatBut simpleWithBlackStorkes:(SYFlatButton*)acceptBut];
    
}

- (void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=NO;
    self.view.window.movable=YES;
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.cornerRadius=3;
    self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
    [self.view.window standardWindowButton:NSWindowMiniaturizeButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowZoomButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowCloseButton].hidden=NO;
}

- (void)setImagePreview:(NSImage*)image{
    previewImage.image = image;
}

- (IBAction)saturation:(id)sender {
//    NSLog(@"%f", saturationControl.doubleValue);
    [self updateWithEffects];
}

- (IBAction)brightness:(id)sender {
    [self updateWithEffects];
}

- (IBAction)contrast:(id)sender {
    [self updateWithEffects];
}
- (IBAction)sharpnessAdjust:(id)sender {
    [self updateWithEffects];
}

- (IBAction)imageWithTriangles:(id)sender {
    if(makeTriangles.state){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            effectedImage = [effectedImage imageWithTriangulars:_originalImageURLs[0] scale:@50 center:[CIVector vectorWithX:10 Y:10 Z:60] vertexAngle:@30];
            dispatch_async(dispatch_get_main_queue(), ^{
                previewImage.image = effectedImage;
            });
        });
    }else{
        [self refresh];
    }

}

- (IBAction)monoImage:(id)sender {
    [self updateWithEffects];
}

- (IBAction)blurImage:(id)sender {
    if(makeBlur.state){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            effectedImage = [effectedImage blurImage:_originalImageURLs[0] :nil withBottomInset:3 blurRadius:5];
            dispatch_async(dispatch_get_main_queue(), ^{
                previewImage.image = effectedImage;
            });
        });
    }else{
        [self refresh];
    }
}
- (IBAction)exposureAdjust:(id)sender {
    [self updateWithEffects];
}


- (IBAction)refreshToOriginal:(id)sender {
    [self refresh];
}

- (void)refresh{
    previewImage.image = originalImage;
    saturationControl.doubleValue=[controlsData[@"saturation"] doubleValue];
    brightnessControl.doubleValue=[controlsData[@"brightness"]doubleValue];
    contrastControl.doubleValue=[controlsData[@"contrast"]doubleValue];
}

- (void)updateWithEffects{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        effectedImage = [effectedImage imageSaturation:_originalImageURLs[0] data:nil saturation:[NSNumber numberWithDouble:saturationControl.doubleValue] brightness:[NSNumber numberWithDouble:brightnessControl.doubleValue] contrast:[NSNumber numberWithDouble:contrastControl.doubleValue ]inputEV:[NSNumber numberWithDouble:exposure.doubleValue] mono:checkMono.state sharpness:[NSNumber numberWithDouble:sharpnessControl.doubleValue]];
         dispatch_async(dispatch_get_main_queue(), ^{
             previewImage.image = effectedImage;
         });
    });
  
}

- (IBAction)acceptEffects:(id)sender {
    if(_profilePhoto){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadProfilePhotoWithEffects" object:nil  userInfo:@{@"photo":[previewImage.image TIFFRepresentation]}];
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPhotoToAlbumWithEffects" object:nil  userInfo:@{@"photo":[previewImage.image TIFFRepresentation]}];
        
    }
    [self dismissController:self];
   
}


@end

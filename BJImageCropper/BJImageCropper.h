//
//  BJImageCropper.h
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE 40.0f
#define IMAGE_CROPPER_INSIDE_STILL_EDGE 20.0f

#ifndef __has_feature
// not LLVM Compiler
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#define ARC
#endif

@interface BJImageCropper : UIView {
    UIImageView *imageView;
    
    UIView *cropView;
    
    UIView *topView;
    UIView *bottomView;
    UIView *leftView;
    UIView *rightView;

    UIView *topLeftView;
    UIView *topRightView;
    UIView *bottomLeftView;
    UIView *bottomRightView;

    CGFloat imageScale;
    
    BOOL isPanning;
    NSInteger currentTouches;
    CGPoint panTouch;
    CGFloat scaleDistance;
    UIView *currentDragView; // Weak reference 
}

@property (nonatomic, assign) CGRect crop;
@property (nonatomic, readonly) CGRect unscaledCrop;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain, readonly) UIImageView* imageView;

+ (UIView *)initialCropViewForImageView:(UIImageView*)imageView;

- (id)initWithImage:(UIImage*)newImage;
- (id)initWithImage:(UIImage*)newImage andMaxSize:(CGSize)maxSize;

- (UIImage*) getCroppedImage;

@end

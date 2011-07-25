//
//  BJImageCropper.h
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE 0.0f
#define IMAGE_CROPPER_INSIDE_STILL_EDGE 20.0f

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
@property (nonatomic, readonly) UIImageView* imageView;

+ (UIView*) initialCropView;

- (id)initWithImage:(UIImage*)newImage;
- (id)initWithImage:(UIImage*)newImage andMaxSize:(CGSize)maxSize;

- (UIImage*) getCroppedImage;

@end

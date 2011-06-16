//
//  BJImageCropper.h
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJImageCropper : UIImageView {
    UIView *cropView;
    
    UIView *topView;
    UIView *bottomView;
    UIView *leftView;
    UIView *rightView;

    UIView *topLeftView;
    UIView *topRightView;
    UIView *bottomLeftView;
    UIView *bottomRightView;

    BOOL isPanning;
    
    CGPoint panTouch;
    
    CGFloat scaleDistance;
    
    UIView *currentDragView;
}

@property (assign) CGRect crop;

@end

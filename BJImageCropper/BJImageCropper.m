//
//  BJImageCropper.m
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BJImageCropper.h"
#import <QuartzCore/QuartzCore.h>

#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif

@implementation BJImageCropper
@dynamic crop;
@dynamic image;
@dynamic unscaledCrop;
@synthesize imageView;

- (UIImage*)image {
    return imageView.image;
}

- (void)setImage:(UIImage *)image {
    imageView.image = image;
}

- (void)constrainCropToImage {
    CGRect frame = cropView.frame;
    
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    
    BOOL change = NO;
    
    do {
        change = NO;
        
        if (CGOriginX(frame) < 0) {
            frame.origin.x = 0;
            change = YES;
        }
        
        if (CGWidth(frame) > CGWidth(cropView.superview.frame)) {
            frame.size.width = CGWidth(cropView.superview.frame);
            change = YES;
        }
        
        if (CGWidth(frame) < 20) {
            frame.size.width = 20;
            change = YES;
        }
        
        if (CGOriginX(frame) + CGWidth(frame) > CGWidth(cropView.superview.frame)) {
            frame.origin.x = CGWidth(cropView.superview.frame) - CGWidth(frame);
            change = YES;
        }
        
        if (CGOriginY(frame) < 0) {
            frame.origin.y = 0;
            change = YES;
        }
        
        if (CGHeight(frame) > CGHeight(cropView.superview.frame)) {
            frame.size.height = CGHeight(cropView.superview.frame);
            change = YES;
        }
        
        if (CGHeight(frame) < 20) {
            frame.size.height = 20;
            change = YES;
        }
        
        if (CGOriginY(frame) + CGHeight(frame) > CGHeight(cropView.superview.frame)) {
            frame.origin.y = CGHeight(cropView.superview.frame) - CGHeight(frame);
            change = YES;
        }
    } while (change);
        
    cropView.frame = frame;
}

- (void)updateBounds {
    [self constrainCropToImage];
    
    CGRect frame = cropView.frame;
    CGFloat x = CGOriginX(frame);
    CGFloat y = CGOriginY(frame);
    CGFloat width = CGWidth(frame);
    CGFloat height = CGHeight(frame);
    
    CGFloat selfWidth = CGWidth(self.imageView.frame);
    CGFloat selfHeight = CGHeight(self.imageView.frame);
    
    topView.frame = CGRectMake(x, -1, width + 1, y);
    bottomView.frame = CGRectMake(x, y + height, width, selfHeight - y - height);
    leftView.frame = CGRectMake(-1, y, x + 1, height);
    rightView.frame = CGRectMake(x + width, y, selfWidth - x - width, height);
    
    topLeftView.frame = CGRectMake(-1, -1, x + 1, y + 1);
    topRightView.frame = CGRectMake(x + width, -1, selfWidth - x - width, y + 1);
    bottomLeftView.frame = CGRectMake(-1, y + height, x + 1, selfHeight - y - height);
    bottomRightView.frame = CGRectMake(x + width, y + height, selfWidth - x - width, selfHeight - y - height);
    
    [self didChangeValueForKey:@"crop"];    
}

- (CGRect)crop {
    CGRect frame = cropView.frame;
    
    if (frame.origin.x <= 0)
        frame.origin.x = 0;

    if (frame.origin.y <= 0)
        frame.origin.y = 0;

    
    return CGRectMake(frame.origin.x / imageScale, frame.origin.y / imageScale, frame.size.width / imageScale, frame.size.height / imageScale);;
}

- (void)setCrop:(CGRect)crop {
    cropView.frame = CGRectMake(crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale);
    [self updateBounds];
}

- (CGRect)unscaledCrop {
    CGRect crop = self.crop;
    return CGRectMake(crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale);
}

- (UIView*)newEdgeView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    
    [self.imageView addSubview:view];
    
    return view;
}

- (UIView*)newCornerView {
    UIView *view = [self newEdgeView];
    view.alpha = 0.75;
    
    return view;
}

+ (UIView *)initialCropViewForImageView:(UIImageView*)imageView {
    // 3/4 the size, centered
    
    CGRect max = imageView.bounds;

    CGFloat width  = CGWidth(max) / 4 * 3;
    CGFloat height = CGHeight(max) / 4 * 3;
    CGFloat x      = (CGWidth(max) - width) / 2;
    CGFloat y      = (CGHeight(max) - height) / 2;
    
    UIView* cropView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    cropView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cropView.layer.borderWidth = 2.0;
    cropView.backgroundColor = [UIColor clearColor];
    cropView.alpha = 0.4;   
    
#ifdef ARC
    return cropView;
#else
    return [cropView autorelease];
#endif
}

- (void)setup {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    cropView = [BJImageCropper initialCropViewForImageView:imageView];
    [self.imageView addSubview:cropView];
    
    topView = [self newEdgeView];
    bottomView = [self newEdgeView];
    leftView = [self newEdgeView];
    rightView = [self newEdgeView];
    topLeftView = [self newCornerView];
    topRightView = [self newCornerView];
    bottomLeftView = [self newCornerView];
    bottomRightView = [self newCornerView];
   
#ifndef ARC
    [cropView retain];
#endif
    
    [self updateBounds];
}

- (CGRect)calcFrameWithImage:(UIImage*)image andMaxSize:(CGSize)maxSize {
    CGFloat increase = IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE * 2;
    
    // if it already fits, return that
    CGRect noScale = CGRectMake(0.0, 0.0, image.size.width + increase, image.size.height + increase);
    if (CGWidth(noScale) <= maxSize.width && CGHeight(noScale) <= maxSize.height) {
        imageScale = 1.0;
        return noScale;
    }
    
    CGRect scaled;
    
    // first, try scaling the height to fit
    imageScale = (maxSize.height - increase) / image.size.height;
    scaled = CGRectMake(0.0, 0.0, image.size.width * imageScale + increase, image.size.height * imageScale + increase);
    if (CGWidth(scaled) <= maxSize.width && CGHeight(scaled) <= maxSize.height) {
        return scaled;
    }
    
    // scale with width if that failed
    imageScale = (maxSize.width - increase) / image.size.width;
    scaled = CGRectMake(0.0, 0.0, image.size.width * imageScale + increase, image.size.height * imageScale + increase);
    return scaled;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithImage:(UIImage*)newImage {
    self = [super init];
    if (self) {
        imageScale = 1.0;
        imageView = [[UIImageView alloc] initWithImage:newImage];
        self.frame = CGRectInset(imageView.frame, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, -IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE);
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)initWithImage:(UIImage*)newImage andMaxSize:(CGSize)maxSize {
    self = [super init];
    if (self) {
        self.frame = [self calcFrameWithImage:newImage andMaxSize:maxSize];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE, IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE)];
        imageView.image = newImage;
        [self addSubview:imageView];
        [self setup];
    }
    
    return self;   
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: {            
            currentTouches = 1;
            isPanning = NO;
            CGFloat insetAmount = IMAGE_CROPPER_INSIDE_STILL_EDGE;
            
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];
            if (CGRectContainsPoint(CGRectInset(cropView.frame, insetAmount, insetAmount), touch)) {
                isPanning = YES;
                panTouch = touch;
                return;
            }
            
            CGRect frame = cropView.frame;
            CGFloat x = touch.x;
            CGFloat y = touch.y;
            
            currentDragView = nil;
            
            // We start dragging if we're within the rect + the inset amount
            // If we're definitively in the rect we actually start moving right to the point
         
            if (CGRectContainsPoint(CGRectInset(topLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topLeftView;
                
                if (CGRectContainsPoint(topLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = topRightView;
                
                if (CGRectContainsPoint(topRightView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomLeftView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomLeftView;
                
                if (CGRectContainsPoint(bottomLeftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomRightView.frame, -insetAmount, -insetAmount), touch)) {
                currentDragView = bottomRightView;
                
                if (CGRectContainsPoint(bottomRightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topView.frame, 0, -insetAmount), touch)) {
                currentDragView = topView;
                
                if (CGRectContainsPoint(topView.frame, touch)) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomView.frame, 0, -insetAmount), touch)) {
                currentDragView = bottomView;
                
                if (CGRectContainsPoint(bottomView.frame, touch)) {
                    frame.size.height = y - CGOriginY(frame);
                }
            }
            else if (CGRectContainsPoint(CGRectInset(leftView.frame, -insetAmount, 0), touch)) {
                currentDragView = leftView;
                
                if (CGRectContainsPoint(leftView.frame, touch)) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(rightView.frame, -insetAmount, 0), touch)) {
                currentDragView = rightView;
                
                if (CGRectContainsPoint(rightView.frame, touch)) {
                    frame.size.width = x - CGOriginX(frame);
                }
            }
            
            cropView.frame = frame;
            
            [self updateBounds];
            
            break;
        }
        case 2: {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];

            if (currentTouches == 0 && CGRectContainsPoint(cropView.frame, touch1) && CGRectContainsPoint(cropView.frame, touch2)) {
                isPanning = YES;
            }
            
            currentTouches = [allTouches count];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"crop"];
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];

            if (isPanning) {
                CGPoint touchCurrent = [[allTouches anyObject] locationInView:self.imageView];
                CGFloat x = touchCurrent.x - panTouch.x;
                CGFloat y = touchCurrent.y - panTouch.y;
                
                cropView.center = CGPointMake(cropView.center.x + x, cropView.center.y + y);
                                
                panTouch = touchCurrent;
            }
            else if ((CGRectContainsPoint(self.bounds, touch))) {
                CGRect frame = cropView.frame;
                CGFloat x = touch.x;
                CGFloat y = touch.y;
                
                if (x > self.imageView.frame.size.width)
                    x = self.imageView.frame.size.width;

                if (y > self.imageView.frame.size.height)
                    y = self.imageView.frame.size.height;

                
                if (currentDragView == topView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                }
                else if (currentDragView == bottomView) {
                    //currentDragView = bottomView;
                    frame.size.height = y - CGOriginY(frame);
                }
                else if (currentDragView == leftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.origin.x = x;
                }
                else if (currentDragView == rightView) {
                    //currentDragView = rightView;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == topLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin = touch;
                }
                else if (currentDragView == topRightView) {
                    frame.size.height += CGOriginY(frame) - y;
                    frame.origin.y = y;
                    frame.size.width = x - CGOriginX(frame);
                }
                else if (currentDragView == bottomLeftView) {
                    frame.size.width += CGOriginX(frame) - x;
                    frame.size.height = y - CGOriginY(frame);
                    frame.origin.x =x;
                }
                else if ( currentDragView == bottomRightView) {
                    frame.size.width = x - CGOriginX(frame);
                    frame.size.height = y - CGOriginY(frame);
                }
                
                cropView.frame = frame;                
            }
        } break;
        case 2: {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
            
            if (isPanning) {
                CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];
                
                if (scaleDistance != 0) {
                    CGFloat scale = 1.0f + ((distance-scaleDistance)/scaleDistance);
                    
                    CGPoint originalCenter = cropView.center;
                    CGSize originalSize = cropView.frame.size;
                    
                    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);

                    if (newSize.width >= 50 && newSize.height >= 50 && newSize.width <= CGWidth(cropView.superview.frame) && newSize.height <= CGHeight(cropView.superview.frame)) {
                        cropView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
                        cropView.center = originalCenter;
                    }
                }
                
                scaleDistance = distance;
            }
            else if (
                     currentDragView == topLeftView ||
                     currentDragView == topRightView ||
                     currentDragView == bottomLeftView ||
                     currentDragView == bottomRightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat y = MIN(touch1.y, touch2.y);
                
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                cropView.frame = CGRectMake(x, y, width, height);
            }
            else if (
                     currentDragView == topView ||
                     currentDragView == bottomView
                     ) {
                CGFloat y = MIN(touch1.y, touch2.y);
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                // sometimes the multi touch gets in the way and registers one finger as two quickly
                // this ensures the crop only shrinks a reasonable amount all at once
                if (height > 30 || cropView.frame.size.height < 45)
                {
                    cropView.frame = CGRectMake(CGOriginX(cropView.frame), y, CGWidth(cropView.frame), height);
                }
            }
            else if (
                     currentDragView == leftView ||
                     currentDragView == rightView
                     ) {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                
                // sometimes the multi touch gets in the way and registers one finger as two quickly
                // this ensures the crop only shrinks a reasonable amount all at once
                if (width > 30 || cropView.frame.size.width < 45)
                {                cropView.frame = CGRectMake(x, CGOriginY(cropView.frame), width, CGHeight(cropView.frame));
                }
            }
        } break;
    }
    
    [self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    scaleDistance = 0;
    currentTouches = [[event allTouches] count];
}

- (UIImage*) getCroppedImage {
    CGRect rect = self.crop;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image 
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.image.size.width, self.image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [self.image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

#ifndef ARC

- (void)dealloc {
    [imageView release];
    
    [cropView release];
    
    [topView release];
    [bottomView release];
    [leftView release];
    [rightView release];
    
    [topLeftView release];
    [topRightView release];
    [bottomLeftView release];
    [bottomRightView release];
    
    [super dealloc];
}
#endif
@end

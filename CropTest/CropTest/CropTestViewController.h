//
//  CropTestViewController.h
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJImageCropper.h"

@interface CropTestViewController : UIViewController {
    BJImageCropper *imageCropper;
    
    UILabel *boundsText;
}

@property (nonatomic, strong) IBOutlet UILabel *boundsText;
@property (nonatomic, strong) BJImageCropper *imageCropper;

@property (nonatomic, strong) UIImageView *preview;

@end

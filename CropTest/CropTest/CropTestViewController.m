//
//  CropTestViewController.m
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// preview slows down frame rate (it's generating a new UIImage very frequently)
#define SHOW_PREVIEW NO

#import "CropTestViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CropTestViewController
@synthesize boundsText;
@synthesize imageCropper;
@synthesize preview;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateDisplay {
    self.boundsText.text = [NSString stringWithFormat:@"(%f, %f) (%f, %f)", CGOriginX(self.imageCropper.crop), CGOriginY(self.imageCropper.crop), CGWidth(self.imageCropper.crop), CGHeight(self.imageCropper.crop)];

    if (SHOW_PREVIEW) {
        self.preview.image = [self.imageCropper getCroppedImage];
        self.preview.frame = CGRectMake(10,10,self.imageCropper.crop.size.width * 0.1, self.imageCropper.crop.size.height * 0.1);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.imageCropper] && [keyPath isEqualToString:@"crop"]) {
        [self updateDisplay];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tactile_noise.png"]];
    
    self.imageCropper = [[BJImageCropper alloc] initWithImage:[UIImage imageNamed:@"gavandme.jpg"] andMaxSize:CGSizeMake(1024, 600)];
    [self.view addSubview:self.imageCropper];
    self.imageCropper.center = self.view.center;
    self.imageCropper.imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.imageCropper.imageView.layer.shadowRadius = 3.0f;
    self.imageCropper.imageView.layer.shadowOpacity = 0.8f;
    self.imageCropper.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    
    [self.imageCropper addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:nil];
    
    if (SHOW_PREVIEW) {
        self.preview = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,self.imageCropper.crop.size.width * 0.1, self.imageCropper.crop.size.height * 0.1)];
        self.preview.image = [self.imageCropper getCroppedImage];
        self.preview.clipsToBounds = YES;
        self.preview.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.preview.layer.borderWidth = 2.0;
        [self.view addSubview:self.preview];
    }
}


- (void)viewDidUnload
{
    [self setImageCropper:nil];
    [self setBoundsText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

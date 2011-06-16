//
//  CropTestViewController.m
//  CropTest
//
//  Created by Barrett Jacobsen on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CropTestViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CropTestViewController
@synthesize boundsText;
@synthesize image;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self.image] && [keyPath isEqualToString:@"crop"]) {
        self.boundsText.text = [NSString stringWithFormat:@"(%f, %f) (%f, %f)", CGOriginX(self.image.crop), CGOriginY(self.image.crop), CGWidth(self.image.crop), CGHeight(self.image.crop)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tactile_noise.png"]];
    self.image.center = self.view.center;
    self.image.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.image.layer.shadowRadius = 3.0f;
    self.image.layer.shadowOpacity = 0.8f;
    self.image.layer.shadowOffset = CGSizeMake(1, 1);
    
    [self.image addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)viewDidUnload
{
    [self setImage:nil];
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

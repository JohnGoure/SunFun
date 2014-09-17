//
//  ViewController.m
//  Cloud Run
//
//  Created by John Goure on 6/21/14.
//  Copyright (c) 2014 John Goure. All rights reserved.
//

#import "ViewController.h"
#import "MenuScene.h"
#import <iAd/iAd.h>

@interface ViewController () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *banner;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.banner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.showsPhysics = NO;
    
    
    
    // Create and configure the scene.
    SKScene * scene = [MenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    self.banner.delegate = self;
    [self.banner sizeToFit];
    self.canDisplayBannerAds = YES;
    
    // Present the scene.
    [skView presentScene:scene];
    
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (banner.isBannerLoaded) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    if (!banner.isBannerLoaded) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
    }
}



@end

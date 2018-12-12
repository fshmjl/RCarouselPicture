//
//  ViewController.m
//  RCarouselPicture
//
//  Created by RPK on 2018/11/23.
//  Copyright © 2018 RPK. All rights reserved.
//

#import "ViewController.h"

#import "RPKCrouselPicture.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RPKCrouselPicture *crousePicture = [[RPKCrouselPicture alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 300) localImageName:@[@"http://221.228.226.5/15/t/s/h/v/tshvhsxwkbjlipfohhamjkraxuknsc/sh.yinyuetai.com/88DC015DB03C829C2126EEBBB5A887CB.mp4", @"1.jpg", @"2.jpg", @"3.jpg"]];
    crousePicture.firstIsVideo = YES;
    [self.view addSubview:crousePicture];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

@end

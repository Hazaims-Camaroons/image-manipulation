//
//  ViewController.m
//  g
//
//  Created by Brian C Adams on 7/23/14.
//  Copyright (c) 2014 Brian C Adams. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)Cancel:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
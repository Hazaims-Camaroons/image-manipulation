//
//  ViewController.h
//  Image Manipulator
//
//  Created by Philip A Petrosino on 7/16/14.
//  Copyright (c) 2014 Hazems-Camaroons. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ManipulaterViewController.h"

@interface ViewController : UIViewController
- (IBAction)selectAPhoto:(id)sender;
-(IBAction)Cancel:(UIStoryboardSegue*)segue;
@end

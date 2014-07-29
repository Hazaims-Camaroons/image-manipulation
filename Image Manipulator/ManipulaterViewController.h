//
//  ManipulaterViewController.h
//  Image Manipulator
//
//  Created by Cody A Wisniewski on 7/23/14.
//  Copyright (c) 2014 Hazems-Camaroons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManipulaterViewController : UIViewController
{
    NSArray* types;
}
@property (weak, nonatomic) IBOutlet UIPickerView *ImageManipulatorPicker;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)Save:(UIBarButtonItem *)sender;
@end

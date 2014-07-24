//
//  ManipulaterViewController.m
//  Image Manipulator
//
//  Created by Cody A Wisniewski on 7/23/14.
//  Copyright (c) 2014 Hazems-Camaroons. All rights reserved.
//

#import "ManipulaterViewController.h"

@interface ManipulaterViewController ()

@end

@implementation ManipulaterViewController
@synthesize ImageManipulatorPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSBundle* mainAppBundle = [NSBundle mainBundle];
    // 2. get path to the units.plist file
    NSString* filePath = [mainAppBundle pathForResource:@"ManipulatorTypes" ofType:@"plist"];
    // 2.5 log the file path
    NSLog(@"%@", filePath);

    types=[NSArray arrayWithContentsOfFile:filePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [types count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [types objectAtIndex:row];
}

-(void)getManipulationType
{
    NSInteger selectedIndexType = [ImageManipulatorPicker selectedRowInComponent:0];
    NSString* selectedType = [types objectAtIndex:selectedIndexType];
    if ([selectedType isEqualToString:@"Black & White"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Flip X"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Flip Y"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Flip X"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Pixelate"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Negate"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Negate Bands"])
    {
        
    }
    else if ([selectedType isEqualToString:@"Blur Box"])
    {
                  
    }
}

@end

//
//  ManipulaterViewController.m
//  Image Manipulator
//
//  Created by Cody A Wisniewski on 7/23/14.
//  Copyright (c) 2014 Hazems-Camaroons. All rights reserved.
//

#import "ManipulaterViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ManipulaterViewController (){
    bool hasPresentedPhotoOptions;
}
@end

@implementation ManipulaterViewController
@synthesize ImageManipulatorPicker, imageView, originalImage;

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
- (void)viewDidAppear:(BOOL)animated{
    
    if (!hasPresentedPhotoOptions) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = @[(NSString*) kUTTypeImage];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
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

-(void)getManipulationType :(UInt8*)pixelBuf :(int)length :(int)width
{
    NSInteger selectedIndexType = [ImageManipulatorPicker selectedRowInComponent:0];
    NSString* selectedType = [types objectAtIndex:selectedIndexType];
    if ([selectedType isEqualToString:@"Black & White"])
    {
        NSLog(@"Grey");
        for (int i=0;i < length; i+=4){
            [self filterGreyScale:pixelBuf :i];
        }
    }
    else if ([selectedType isEqualToString:@"Flip X"])
    {
        NSLog(@"X");
        for (int i=0; i < length; i+=4){
            [self filterFlipX:pixelBuf :length :i :width];
        }
        
    }
    else if ([selectedType isEqualToString:@"Flip Y"])
    {
        NSLog(@"Y");
        for (int i=0; i < ceil(length*1.0 / 2); i +=4){
            [self filterFlipY:pixelBuf :length :i :width];
        }
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

-(void)pickerView :(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self manipulation];
}

-(void) manipulation
{
    UIImage* img = [imageView image];
    CGImageRef inImage = img.CGImage;
    CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    
    int length =  CFDataGetLength(m_DataRef);
    int width = (int)CGImageGetWidth(inImage) * 4;
    
    
    [self getManipulationType:m_PixelBuf :length :width];
    
    //Create Context
    CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             CGImageGetBitmapInfo(inImage)
                                             );
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(m_DataRef);
    
    [originalImage setImage:finalImage];
}

- (void) filterGreyScale :(UInt8 *)pixelBuf :(int)offset
{
    
    int r = offset;
    int g = offset+1;
    int b = offset+2;
    
    int red = pixelBuf[r];
    int green = pixelBuf[g];
    int blue = pixelBuf[b];
    
    uint32_t gray = 0.3 * red + 0.59 * green + 0.11 * blue;
    
    pixelBuf[r] = gray;
    pixelBuf[g] = gray;
    pixelBuf[b] = gray;
    
}

-(void) filterFlipY :(UInt8 *)pixelBuf :(NSInteger)length :(NSInteger) offset :(NSInteger) width{
    int row = ceil(offset * 1.0  / (width));
    
    if (row == 0) {
        row = 1;
    }
    
    int temp1 =pixelBuf[offset];
    int temp2 = pixelBuf[offset+1];
    int temp3 = pixelBuf[offset + 2];
    
    pixelBuf[offset] = pixelBuf[length - (width*row) + (offset % width)];
    pixelBuf[offset+1] = pixelBuf[length - (width*row) + (offset % width) + 1];
    pixelBuf[offset +2 ] = pixelBuf[length - (width*row) + (offset % width) + 2];
    
    pixelBuf[length - (width*row) + (offset % width)] = temp1;
    pixelBuf[length - (width*row) + (offset % width) + 1] = temp2;
    pixelBuf[length - (width*row) + (offset % width) + 2] = temp3;
}

-(void) filterFlipX :(UInt8 *)pixelBuf :(NSInteger)length : (NSInteger)offset :(NSInteger)width{
    int pivot = width / 2;
    if ((offset + 4) % width > pivot) {
        return;
    }
    int row = ceil(offset * 1.0 / (width -1));
    if (row == 0){
        row = 1;
    }
    
    int temp1 = pixelBuf[offset];
    int temp2 = pixelBuf[offset+1];
    int temp3 = pixelBuf[offset+2];
    
    pixelBuf[offset] = pixelBuf[(width*row) - 4 - (offset % width)];
    pixelBuf[offset + 1] = pixelBuf[(width*row) - 3 - (offset % width)];
    pixelBuf[offset + 2] = pixelBuf[(width*row) - 2 - (offset % width)];
    
    pixelBuf[(width*row) - 4 - (offset % width)] = temp1;
    pixelBuf[(width*row) - 3 - (offset % width)] = temp2;
    pixelBuf[(width*row) - 2 - (offset % width)] = temp3;
}


- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        imageView.image = image;
        hasPresentedPhotoOptions = true;
    }
}

- (IBAction)Save:(UIBarButtonItem *)sender {
    UIImage *image = imageView.image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIAlertView* savedAlert = [[UIAlertView alloc]initWithTitle:@"Your image has been saved." message:nil delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:Nil, nil];
    [savedAlert show];
}

@end

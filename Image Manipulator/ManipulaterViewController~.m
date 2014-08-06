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
    // boolean that prevents the photo options from continuously showing the photo selector
    bool hasPresentedPhotoOptions;
}
@end

@implementation ManipulaterViewController
@synthesize ImageManipulatorPicker, imageView, originalImage;
int BAND_WIDTH = 10;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get the app bundle
    NSBundle* mainAppBundle = [NSBundle mainBundle];
    // get path to the units.plist file
    NSString* filePath = [mainAppBundle pathForResource:@"ManipulatorTypes" ofType:@"plist"];
    NSLog(@"%@", filePath);

    types=[NSArray arrayWithContentsOfFile:filePath];
}


- (void)viewDidAppear:(BOOL)animated{
    
    // check if the user has already been presented with photo options
    if (!hasPresentedPhotoOptions) {
        // check to make sure the imagepickercontroller has a source of photo lybrary
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            // create the image picker
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            // only allow images, no photos, and no editing
            imagePicker.mediaTypes = @[(NSString*) kUTTypeImage];
            imagePicker.allowsEditing = NO;
            
            // show the image picker
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:true completion:nil];
    hasPresentedPhotoOptions = true;
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

// getManipulationType finds what the selected manipulation is and calls the proper function in the proper way
-(void)getManipulationType :(UInt8*)pixelBuf :(int)length :(int)width
{
    // get the type
    NSInteger selectedIndexType = [ImageManipulatorPicker selectedRowInComponent:0];
    NSString* selectedType = [types objectAtIndex:selectedIndexType];
    if ([selectedType isEqualToString:@"Grey Scale"])
    {
        // greyscale
        NSLog(@"Grey");
        for (int i=0;i < length; i+=4){
            [self filterGreyScale:pixelBuf :i];
        }
    }
    else if ([selectedType isEqualToString:@"Flip X"])
    {
        // flip x
        NSLog(@"X");
        for (int i=0; i < length; i+=4){
            [self filterFlipX:pixelBuf :length :i :width];
        }
        
    }
    else if ([selectedType isEqualToString:@"Flip Y"])
    {
        // flip y
        NSLog(@"Y");
        
        // important! only use half of the length, as if we flipped the image over the x axis twice, it would be the original image
        for (int i=0; i < ceil(length*1.0 / 2); i +=4){
            [self filterFlipY:pixelBuf :length :i :width];
        }
    }
    else if ([selectedType isEqualToString:@"Negate"])
    {
        // negation
        NSLog(@"Negate");
        for (int i=0; i < length; i+=4) {
            [self filterNegate:pixelBuf :i];
        }
    }
    else if ([selectedType isEqualToString:@"Negate Bands"])
    {
        // negate bands
        NSLog(@"Negate Bands");
        
        // split the image into BAND_WIDTH bands
        int bandwidth = (ceil)(width * 1.0 / BAND_WIDTH);
        for (int i=0; i < length; i+=4){
            [self filterNegateBands:pixelBuf :bandwidth :i :width];
        }
    }
}

-(void)pickerView :(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self manipulation];
}

// base manipulation function that originally gets called
-(void) manipulation
{
    // get the image and pixel data for the image
    UIImage* img = [originalImage image];
    CGImageRef inImage = img.CGImage;
    CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    
    // get length and width of image, in the form of 1 pixel = [red, green, blue, alpha] values
    int length =  CFDataGetLength(m_DataRef);
    int width = (int)CGImageGetWidth(inImage) * 4;
    
    // run the manipulation
    [self getManipulationType:m_PixelBuf :length :width];
    
    // since the "drawing" will only accept bitmaps, we must create one via the pixel data
    
    // create the context for the drawing destination
    CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             CGImageGetBitmapInfo(inImage)
                                             );
    
    // create an image reference using the context that was created
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    
    // must release the context as we created it
    CGContextRelease(ctx);
    
    // take the new image, release the reference that was created before, and set the imageview to be the new image
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(m_DataRef);
    
    [imageView setImage:finalImage];
}

// changes the image to all black/white/grey
- (void) filterGreyScale :(UInt8 *)pixelBuffer :(int)offset
{
    // locations for red, green, blue pixels
    int r = offset;
    int g = offset+1;
    int b = offset+2;
    
    // actual values of rgb pixels
    int red = pixelBuffer[r];
    int green = pixelBuffer[g];
    int blue = pixelBuffer[b];
    
    // gray is made by multiplying red by 0.3, green by 0.59, and blue by 0.11.
    int gray = 0.3 * red + 0.59 * green + 0.11 * blue;
    
    // set the new rgb values
    pixelBuffer[r] = gray;
    pixelBuffer[g] = gray;
    pixelBuffer[b] = gray;
    
}

// gets the negative of every pixel
- (void)filterNegate :(UInt8*)pixelBuffer :(int)offset
{
    int r = offset;
    int g = offset + 1;
    int b = offset + 2;
    
    int red = pixelBuffer[r];
    int green = pixelBuffer[g];
    int blue = pixelBuffer[b];
    
    // negate by taking max value (255) - actual value
    pixelBuffer[r] = 255 - red;
    pixelBuffer[g] = 255 - green;
    pixelBuffer[b] = 255 - blue;
}

// flips the image over the x axis
-(void) filterFlipY :(UInt8 *)pixelBuffer :(NSInteger)length :(NSInteger) offset :(NSInteger) width{
    // get the current row of the image
    int row = ceil(offset * 1.0  / width);
    
    // special case, if row is 0 then it is actually the first row, to prevent out of index later
    if (row == 0) {
        row = 1;
    }
    
    // temporarily store the original values, to be swapped with the mirror value
    int temp1 = pixelBuffer[offset];
    int temp2 = pixelBuffer[offset+1];
    int temp3 = pixelBuffer[offset + 2];
    
    // set the original values = to the mirror value
    // take the length, subtract width*row (which finds the row of the mirror), and then add the offset mod width (which finds the position)
    pixelBuffer[offset] = pixelBuffer[length - (width*row) + (offset % width)];
    pixelBuffer[offset+1] = pixelBuffer[length - (width*row) + (offset % width) + 1];
    pixelBuffer[offset +2 ] = pixelBuffer[length - (width*row) + (offset % width) + 2];
    
    // swap
    pixelBuffer[length - (width*row) + (offset % width)] = temp1;
    pixelBuffer[length - (width*row) + (offset % width) + 1] = temp2;
    pixelBuffer[length - (width*row) + (offset % width) + 2] = temp3;
}

// flips the image over the x axis
-(void) filterFlipX :(UInt8 *)pixelBuffer :(NSInteger)length : (NSInteger)offset :(NSInteger)width{
    // get the middle of the row, the pivot
    int pivot = width / 2;
    
    // check to make sure the pixel isn't past the pivot
    if ((offset + 4) % width > pivot) {
        return;
    }
    
    // get the current row
    int row = ceil(offset * 1.0 / (width -1));
    
    // special case where row 0 is actually row 1, to prevent overflow later
    if (row == 0){
        row = 1;
    }
    
    // temporarily store values
    int temp1 = pixelBuffer[offset];
    int temp2 = pixelBuffer[offset+1];
    int temp3 = pixelBuffer[offset+2];
    
    // set the original values to the value of the mirror
    
    // take the width*row (which finds the index of the last pixel in the row), subtract 4/3/2 to get to the r/g/b values,
    // then subtract the offset mod width (which finds the current index)
    pixelBuffer[offset] = pixelBuffer[(width*row) - 4 - (offset % width)];
    pixelBuffer[offset + 1] = pixelBuffer[(width*row) - 3 - (offset % width)];
    pixelBuffer[offset + 2] = pixelBuffer[(width*row) - 2 - (offset % width)];
    
    // swap
    pixelBuffer[(width*row) - 4 - (offset % width)] = temp1;
    pixelBuffer[(width*row) - 3 - (offset % width)] = temp2;
    pixelBuffer[(width*row) - 2 - (offset % width)] = temp3;
}

// creates vertical negative bands across the image
-(void) filterNegateBands :(UInt8 *)pixelBuf :(NSInteger)bandwidth :(NSInteger)offset :(NSInteger)width{
    // get the row of the image, and subtract one since it is zero indexed
    int row = ceil(offset*1.0 / width) - 1;
    
    // we have 5 bands, so we need if statements to handle all possible cases
    for (int i=1; i <= BAND_WIDTH; i++){
        // make sure the offset is in a negative band range
        // make sure that i mod 2 isn't 0, as that means it's an even band, so non-negative
        if (offset <= (bandwidth*i)+(width*row) && i % 2 != 0){
            pixelBuf[offset] = 255 - pixelBuf[offset];
            pixelBuf[offset+1] = 255 - pixelBuf[offset+1];
            pixelBuf[offset+2] = 255 - pixelBuf[offset+2];
        }else if(offset <= (bandwidth*(i+1))+(width*row) && offset <= (bandwidth*i)+(width*row)) {
            // check to see if it won't fit in the next band, and if it does, break the loop as nothing should be done
            break;
            
        }
    }
}


- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    // make sure nothing will go wrong
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // display only image types
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    // don't allow editing
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
    
    // ensure the photo is of type image
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        // set the image view's image
        originalImage.image = image;
        hasPresentedPhotoOptions = true;
    } 
}

// saves the manipulated image in the photo library
- (IBAction)Save:(UIBarButtonItem *)sender {
    // get the image and write it to the album
    UIImage *image = imageView.image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // alert the user
    UIAlertView* savedAlert = [[UIAlertView alloc]initWithTitle:@"Your image has been saved." message:nil delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:Nil, nil];
    [savedAlert show];
}

@end

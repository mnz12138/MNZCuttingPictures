//
//  ViewController.m
//  裁切图片
//
//  Created by jianluo on 17/1/10.
//  Copyright © 2017年 jianluo. All rights reserved.
//

#import "ViewController.h"
#import "CuttingViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CuttingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)chooseBtnAction {
    UIImagePickerController *pickerVc = [[UIImagePickerController alloc] init];
    pickerVc.delegate = self;
    pickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CuttingViewController *cuttingVc = [[CuttingViewController alloc] init];
    cuttingVc.image = image;
    cuttingVc.delegate = self;
    [picker pushViewController:cuttingVc animated:YES];
}

#pragma mark - CuttingViewControllerDelegate
- (void)cuttingViewControllerDidCancel:(CuttingViewController *)cuttingViewController {
    [cuttingViewController.navigationController popViewControllerAnimated:YES];
}

- (void)cuttingViewController:(CuttingViewController *)cuttingViewController didFinishImage:(UIImage *)image {
    self.imageView.image = image;
    [cuttingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end

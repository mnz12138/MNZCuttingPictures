//
//  CuttingViewController.m
//  裁切图片
//
//  Created by jianluo on 17/1/10.
//  Copyright © 2017年 jianluo. All rights reserved.
//

#import "CuttingViewController.h"

@interface CuttingViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightCons;

@end

@implementation CuttingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    _scrollView.layer.borderWidth = 1;
    _scrollView.layer.borderColor = [UIColor greenColor].CGColor;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = self.image;
    [_scrollView addSubview:imageView];
    self.imageView = imageView;
}
/**
 点击取消
 */
- (IBAction)cancelAction {
    if ([self.delegate respondsToSelector:@selector(cuttingViewControllerDidCancel:)]) {
        [self.delegate cuttingViewControllerDidCancel:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/**
 点击完成
 */
- (IBAction)finishedAction {
    if ([self.delegate respondsToSelector:@selector(cuttingViewController:didFinishImage:)]) {
        UIImage *image = [self imageFromView:self.imageView atFrame:CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) zoomScale:self.scrollView.zoomScale];
        [self.delegate cuttingViewController:self didFinishImage:image];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
//获得某个范围内的屏幕图像
- (UIImage *)imageFromView:(UIView *)theView atFrame:(CGRect)frame zoomScale:(CGFloat)zoomScale {
    CGSize viewSize = theView.bounds.size;
    if (zoomScale!=1.0) {
        viewSize.width = viewSize.width*zoomScale;
        viewSize.height = viewSize.height*zoomScale;
    }
    UIGraphicsBeginImageContext(viewSize);
    CGContextRef firstContext = UIGraphicsGetCurrentContext();
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(zoomScale, zoomScale);
    CGContextConcatCTM(firstContext, scaleTransform);
    CGPoint origin = CGPointMake(frame.origin.x, frame.origin.y);
    CGSize size = frame.size;
    if (zoomScale!=1.0) {
        origin.x = origin.x/zoomScale;
        origin.y = origin.y/zoomScale;
        size.width = size.width/zoomScale;
        size.height = size.height/zoomScale;
    }
    CGContextSaveGState(firstContext);
    UIRectClip(CGRectMake(origin.x, origin.y, size.width, size.height));
    [theView.layer renderInContext:firstContext];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //重画正方形图片
    UIGraphicsBeginImageContext(frame.size);
    [theImage drawAtPoint:CGPointMake(-frame.origin.x, -frame.origin.y)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self beginLayoutSubviews];
}

/**
 开始布局
 */
- (void)beginLayoutSubviews {
    CGSize size = self.view.bounds.size;
    _scrollViewHeightCons.constant = size.width;
    CGPoint origin = CGPointZero;
    CGSize imageSize = self.image.size;
    if (imageSize.width>size.width&&imageSize.height>size.width) {
        if (imageSize.width<imageSize.height) {
            imageSize.height = size.width/imageSize.width*imageSize.height;
            imageSize.width = size.width;
        }else{
            imageSize.width = size.width/imageSize.height*imageSize.width;
            imageSize.height = size.width;
        }
    }else{
        if (imageSize.width<size.width) {
            imageSize.height = size.width/imageSize.width*imageSize.height;
            imageSize.width = size.width;
        }
        if (imageSize.height<size.width) {
            imageSize.width = size.width/imageSize.height*imageSize.width;
            imageSize.height = size.width;
        }
    }
    if (imageSize.width!=imageSize.height) {
        if (imageSize.width<imageSize.height) {
            origin.x = 0;
            origin.y = (imageSize.height-imageSize.width)*0.5;
        }else{
            origin.x = (imageSize.width-imageSize.height)*0.5;
            origin.y = 0;
        }
    }
    self.imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _scrollView.contentOffset = origin;
    _scrollView.contentSize = self.imageView.bounds.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end

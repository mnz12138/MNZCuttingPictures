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
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation CuttingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.maximumZoomScale<=0) {
        self.maximumZoomScale = 2.0;
    }
    if (self.minimumZoomScale<=0) {
        self.minimumZoomScale = 1.0;
    }
    if (self.ratio<=0) {
        self.ratio = 1.0;
    }
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self addSubviews];
    [self beginLayoutSubviews];
}
- (void)addSubviews {
    // 工具栏按钮高度
    CGFloat bottomViewH = 50;
    CGSize size = self.view.bounds.size;
    CGFloat scrollViewWH = size.width/self.ratio;
    if (scrollViewWH>=(size.height-2*bottomViewH)) {
        scrollViewWH = size.height-2*bottomViewH;
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWH, scrollViewWH)];
    _scrollView.center = self.view.center;
    _scrollView.clipsToBounds = NO;
    _scrollView.maximumZoomScale = self.maximumZoomScale;
    _scrollView.minimumZoomScale = self.minimumZoomScale;
    _scrollView.delegate = self;
    _scrollView.layer.borderWidth = 1;
    _scrollView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:_scrollView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height-bottomViewH, size.width, bottomViewH)];
    bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:bottomView];
    
    CGFloat btnW = 60;
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, bottomViewH)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottomView.frame)-btnW, 0, btnW, bottomViewH)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBtn addTarget:self action:@selector(finishedAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sureBtn];
    
    // 遮罩视图
    UIView *topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, CGRectGetMinY(_scrollView.frame))];
    topMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:topMaskView];
    CGFloat bottomMaskViewY = CGRectGetMaxY(_scrollView.frame);
    UIView *bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomMaskViewY, size.width, CGRectGetMinY(bottomView.frame)-bottomMaskViewY)];
    bottomMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:bottomMaskView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = self.image;
    [_scrollView addSubview:imageView];
    self.imageView = imageView;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
/**
 点击取消
 */
- (void)cancelAction {
    if ([self.delegate respondsToSelector:@selector(cuttingViewControllerDidCancel:)]) {
        [self.delegate cuttingViewControllerDidCancel:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/**
 点击完成
 */
- (void)finishedAction {
    if ([self.delegate respondsToSelector:@selector(cuttingViewController:didFinishImage:)]) {
        UIImage *image = nil;
        if (self.image!=nil) {
            image = [self imageFromView:self.imageView atFrame:CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) zoomScale:self.scrollView.zoomScale];
        }
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
/**
 开始布局
 */
- (void)beginLayoutSubviews {
    if (self.image==nil) {
        return;
    }
    CGSize size = self.view.bounds.size;
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

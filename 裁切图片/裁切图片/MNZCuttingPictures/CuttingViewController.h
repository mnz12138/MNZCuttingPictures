//
//  CuttingViewController.h
//  裁切图片
//
//  Created by jianluo on 17/1/10.
//  Copyright © 2017年 jianluo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CuttingViewController;

@protocol CuttingViewControllerDelegate <NSObject>

@optional
- (void)cuttingViewControllerDidCancel:(CuttingViewController *)cuttingViewController;
- (void)cuttingViewController:(CuttingViewController *)cuttingViewController didFinishImage:(UIImage *)image;

@end

@interface CuttingViewController : UIViewController

/**最小缩放比例 默认1.0*/
@property (nonatomic, assign) CGFloat minimumZoomScale;
/**最大缩放比例 默认2.0*/
@property (nonatomic, assign) CGFloat maximumZoomScale;
/**宽高比 默认1.0*/
@property (nonatomic, assign) CGFloat ratio;
/**需要裁切的图片*/
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, weak) id<CuttingViewControllerDelegate> delegate;

@end

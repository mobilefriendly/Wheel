//
//  ViewController.h
//  Wheel
//
//  Created by Sankalp Varma on 06/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface ViewController : UIViewController
{
    UIImageView *mShipWheel;
    
    BOOL touchesMoved;

    
    CGPoint lastPoint;
    NSTimeInterval lastTouchTimeStamp;

    double currentAngle;
    double angularSpeed;
    CATransform3D currentTransform;
    NSInteger turnDirection;    
    
}

@property (nonatomic,retain)  IBOutlet UIImageView *mShipWheel;

//Math Functions//
-(double)DistanceBetweenTwoPoints:(CGPoint)point1:(CGPoint) point2;
-(double)angleBetweenThreePoints:(CGPoint)x :(CGPoint)y :(CGPoint)z;
-(double)crossProduct:(CGPoint)p1 :(CGPoint)p2 :(CGPoint)p3;
-(void)spin:(double)delta;

//Spinning Animation//
- (void)runSpinAnimation;

@end

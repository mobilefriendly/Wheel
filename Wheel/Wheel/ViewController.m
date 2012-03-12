//
//  ViewController.m
//  Wheel
//
//  Created by Sankalp Varma on 06/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize mShipWheel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    self.mShipWheel = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)dealloc
{
    self.mShipWheel = nil;
}


#pragma mark - math functions

-(double)DistanceBetweenTwoPoints:(CGPoint)point1:(CGPoint) point2
{
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	return sqrt(dx*dx + dy*dy );
}


-(double)angleBetweenThreePoints:(CGPoint)x :(CGPoint)y :(CGPoint)z
{
	double a,b,c;
	
	b = [self DistanceBetweenTwoPoints:x :y];
	a = [self DistanceBetweenTwoPoints:y :z];
	c = [self DistanceBetweenTwoPoints:z :x];
	
	
	double value = (a*a +b*b - c*c)/(2*a*b);
	
	
	return acos(value);
}

-(double)crossProduct:(CGPoint)p1 :(CGPoint)p2 :(CGPoint)p3
{			
	CGFloat a1 = p1.x - p2.x;
	CGFloat b1 = p1.y - p2.y;
	
	CGFloat a2 = p3.x - p2.x;	
	CGFloat b2 = p3.y - p2.y;
	
	CGFloat slope = a1*b2 - a2*b1;
	
	if (slope < 0)
	{
		return -1;
	}
	else if (slope > 0)
    {
		return 1;
	}
    else
    {
        return 0;
    }
    
}

-(void)spin:(double)delta
{		
	currentAngle = currentAngle + delta;
    
	CATransform3D transform = CATransform3DMakeRotation(currentAngle, 0, 0, 1);
	
	[mShipWheel.layer setTransform:transform];
}


#pragma mark - UITouch delegate methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{		
	touchesMoved = FALSE;
	
    //when the wheel is manually stopped
	
    if ([mShipWheel.layer animationForKey:@"transform.rotation.z"]) 
        {
            CALayer *presentation = (CALayer*)[mShipWheel.layer presentationLayer];	
            
            currentTransform = [presentation transform];
            
            double angle = [[presentation valueForKeyPath:@"transform.rotation.z"] doubleValue];
            
            currentAngle = angle;
            
            [mShipWheel.layer removeAnimationForKey:@"transform.rotation.z"];			
                        
            [mShipWheel.layer setTransform:currentTransform];

        }
        
    UITouch *touch = [[event allTouches] anyObject];
    
    lastPoint = [touch locationInView:self.view];
	    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
    touchesMoved = TRUE;

    UITouch *touch = [[event allTouches] anyObject];

    // get the touch location
    CGPoint currentPoint = [touch locationInView:self.view];

    double theta = [self angleBetweenThreePoints: currentPoint :CGPointMake(160,230):lastPoint];

    double sign = [self crossProduct:currentPoint:lastPoint: CGPointMake(160,230)]; 

    
    NSTimeInterval deltaTime = event.timestamp - lastTouchTimeStamp;
    
    angularSpeed = DEGREES_TO_RADIANS(theta)/deltaTime;
    
    turnDirection = sign;

    [self spin:sign*theta];		
        
    // update the last point

    lastPoint = currentPoint;	
	
    lastTouchTimeStamp = event.timestamp;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{		
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint currentPoint = [touch locationInView:self.view];

    
	if (touchesMoved)
	{	
         double deltaAngle = [self angleBetweenThreePoints:currentPoint:CGPointMake(160,230) :lastPoint];
        
        [self spin:deltaAngle];
        
        turnDirection = [self crossProduct:currentPoint:lastPoint: CGPointMake(160,230) ]; 
        
        if (angularSpeed > 0.01)
        {
            [self runSpinAnimation];

        }
        
	}


}


#pragma mark - Spin Animation

- (void)runSpinAnimation
{	
	CAKeyframeAnimation* animation;
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	
    animation.duration = 5; //adjust accordingly

	animation.repeatCount = 1;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeBoth;
	
	animation.calculationMode = kCAAnimationLinear;
    
    NSMutableArray *keyFrameValues = [[NSMutableArray alloc] init];
    
    // Start the animation with the current angle of the wheel

    double angleAtTheInstant = currentAngle;
    
    double angleTravelled = DEGREES_TO_RADIANS(720)*angularSpeed; // Angle travelled in 1st second 
   
    for (int i = 0; i < 10; i ++)
    {
        [keyFrameValues addObject: [NSNumber numberWithDouble:angleAtTheInstant]];
        
        //updating the angle for the next frame
     
        angleAtTheInstant = angleAtTheInstant +angleTravelled*turnDirection;
        
        angleTravelled = angleTravelled*0.8;
        
    }

    animation.values = keyFrameValues;
    
    [keyFrameValues release];
    
	animation.keyTimes = [NSArray arrayWithObjects:
						   [NSNumber numberWithFloat:0],
						   [NSNumber numberWithFloat:0.1],
						   [NSNumber numberWithFloat:0.2],
						   [NSNumber numberWithFloat:0.3],						   
						   [NSNumber numberWithFloat:0.4],
						   [NSNumber numberWithFloat:0.5],
						   [NSNumber numberWithFloat:0.6],
                           [NSNumber numberWithFloat:0.7],
                           [NSNumber numberWithFloat:0.8],
						   [NSNumber numberWithFloat:1.0], nil];
    

	
	animation.delegate = self;
	
     [mShipWheel.layer addAnimation:animation forKey:@"transform.rotation.z"];
	
}

#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{

    if (theAnimation == [mShipWheel.layer animationForKey:@"transform.rotation.z"]) 
		{
			CALayer *presentation = (CALayer*)[mShipWheel.layer presentationLayer];	
            
			double angle = [[presentation valueForKeyPath:@"transform.rotation.z"] doubleValue];
            
			currentAngle =  angle;
			
            
            CATransform3D transform = CATransform3DMakeRotation(currentAngle, 0, 0, 1);
            
            [mShipWheel.layer setTransform:transform];
            
			[mShipWheel.layer removeAnimationForKey:@"transform.rotation.z"];	

		}

}

@end

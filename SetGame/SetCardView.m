//
//  ViewX.m
//  ViewTest
//
//  Created by Bilal Ahmad on 11/4/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "SetCardView.h"

@interface SetCardView()
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic) int i;
@end

@implementation SetCardView

#define CORNER_FONT_STANDARD_HEIGHT 180.0;
#define CORNER_RADUIS 18.0

- (CGFloat) cornerScaleFactor {return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat) cornerRadius { return CORNER_RADUIS * [self cornerScaleFactor]; }
- (CGFloat) cornerOffset { return  [self cornerRadius] / 3.0; }


- (void) setbgColor:(UIColor *)color {
    self.bgColor = color;
    [self setNeedsDisplay];
}

- (UIColor*) getbgColor {
    if(!_bgColor) {
        return [UIColor whiteColor];
    } else {
        return _bgColor;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //NSLog(@"drawing rect");
    UIBezierPath * roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds  cornerRadius:[self cornerRadius]];
    [roundedRect addClip];
    [[self getbgColor] setFill];
    UIRectFill(self.bounds);
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    if([self.shape isEqualToString:@"diamond"]) {
        [self drawDiamondWithColor:self.color count:self.count];
        
    }else if ([self.shape isEqualToString:@"oval"]) {
        [self drawOvalWithColor:self.color count:self.count];
        
    }else if ([self.shape isEqualToString:@"curve"]) {
        [self drawCurveWithColor:self.color count:self.count];
        
    }
}

- (void) setChosen:(BOOL)chosen {
    if(chosen) {
        [self setbgColor:[UIColor yellowColor]];}
    else {
        [self setbgColor:[UIColor whiteColor]];
    }
    
}

#define LEFT_PADDING                         (self.frame.size.width)/4.5
#define TOP_PADDING                          (self.frame.size.height)/5
#define TOP_PADDING_FOR_CURVE_SHAPE          TOP_PADDING
#define VERTICAL_SPACING_BETWEEN_SHAPES      TOP_PADDING/5
#define VERTICAL_SPACING_BETWEEN_CURVE_SHAPE TOP_PADDING/10

- (CGFloat) getDiamondHeight {
    CGFloat height = (self.frame.size.height - (2*TOP_PADDING) - (2*VERTICAL_SPACING_BETWEEN_SHAPES))/3;
    return height;
}

- (CGFloat) getDiamondWidth {
    CGFloat width = self.frame.size.width - (2*LEFT_PADDING);
    return width;
}

- (CGFloat) getOvalHeight {
    CGFloat height = (self.frame.size.height - (2*TOP_PADDING) - (2*VERTICAL_SPACING_BETWEEN_SHAPES))/3;
    return height;
}

- (CGFloat) getOvalWidth {
    CGFloat width = self.frame.size.width - (2*LEFT_PADDING);
    return width;
}

- (CGFloat) getCurveHeight {
    CGFloat height = (self.frame.size.height - (2*TOP_PADDING_FOR_CURVE_SHAPE) - (2*VERTICAL_SPACING_BETWEEN_CURVE_SHAPE))/3 * 1.4; //*1.2 some extra height
    return height;
}

- (CGFloat) getCurveWidth {
    CGFloat width = self.frame.size.width - (2*LEFT_PADDING);
    return width;
}

- (void) drawCurveWithColor:(UIColor *) color count:(int) count{
    
    CGFloat x = LEFT_PADDING;
    if (count == 3) {
        CGFloat y = TOP_PADDING_FOR_CURVE_SHAPE;
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getCurveHeight] + VERTICAL_SPACING_BETWEEN_CURVE_SHAPE;
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getCurveHeight] + VERTICAL_SPACING_BETWEEN_CURVE_SHAPE;
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 2) {
        CGFloat y = self.frame.size.height/2 - VERTICAL_SPACING_BETWEEN_CURVE_SHAPE/2 - [self getCurveHeight]/2;//TODO is 2 a magic number ?
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_CURVE_SHAPE;
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 1) {
        CGFloat y = self.frame.size.height/2 - [self getCurveHeight]/7; //TODO is 7 reliable always ?
        [self drawCurveWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
    }
}

- (void) drawCurveWithOrigin:(CGPoint) origin usingColor:(UIColor *)color andShading:(NSString*)shading{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    CGPoint p2 = CGPointMake(LEFT_PADDING + [self getCurveWidth], origin.y);
    
    UIBezierPath *aPath = [UIBezierPath  bezierPath];
    [aPath moveToPoint:origin];
    //[aPath addQuadCurveToPoint:p2 controlPoint:CGPointMake(origin.x+[self getCurveWidth]/2, origin.y-[self getCurveHeight]-15)];
    CGPoint cp1 = CGPointMake(origin.x + [self getCurveWidth], origin.y - [self getCurveHeight]);
    CGPoint cp2 = CGPointMake(origin.x + [self getCurveWidth]*3/4, origin.y + [self getCurveHeight]);
    [aPath addCurveToPoint:p2 controlPoint1:cp1 controlPoint2:cp2];
    [aPath addCurveToPoint:origin controlPoint1:cp1 controlPoint2:cp2];
    
    if([shading isEqualToString:@"filled"]) {
        [aPath fill];
    }else {
        [aPath stroke];
        if([shading isEqualToString:@"lines"]) {
            CGContextSaveGState(context);
            [aPath addClip];
            [self addLineShadingWithColor:color];
            CGContextRestoreGState(context);
        }
    }
}


- (void) drawOvalWithColor:(UIColor *) color count:(int) count{
    
    CGFloat x = LEFT_PADDING;
    if (count == 3) {
        CGFloat y = TOP_PADDING;
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 2) {
        CGFloat y = self.frame.size.height/2 - VERTICAL_SPACING_BETWEEN_SHAPES/2 - [self getDiamondHeight];
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 1) {
        CGFloat y = self.frame.size.height/2 - [self getDiamondHeight]/2;
        [self drawOvalWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
    }
}



- (void) drawOvalWithOrigin:(CGPoint) origin usingColor:(UIColor *)color andShading:(NSString*)shading{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    CGRect rect = CGRectMake(origin.x, origin.y, [self getOvalWidth], [self getOvalHeight]);
    UIBezierPath *aPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12.00];
    
    if([shading isEqualToString:@"filled"]) {
        [aPath fill];
    }else {
        [aPath stroke];
        if([shading isEqualToString:@"lines"]) {
            CGContextSaveGState(context);
            [aPath addClip];
            [self addLineShadingWithColor:color];
            CGContextRestoreGState(context);
        }
    }
}


- (void) drawDiamondWithColor:(UIColor *) color count:(int) count{
    
    CGFloat x = LEFT_PADDING + [self getDiamondWidth]/2;
    if (count == 3) {
        CGFloat y = TOP_PADDING;
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 2) {
        CGFloat y = self.frame.size.height/2 - VERTICAL_SPACING_BETWEEN_SHAPES/2 - [self getDiamondHeight];
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
        y += [self getDiamondHeight] + VERTICAL_SPACING_BETWEEN_SHAPES;
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
        
    } else if (count == 1) {
        CGFloat y = self.frame.size.height/2 - [self getDiamondHeight]/2;
        [self drawDiamondWithOrigin:CGPointMake(x, y) usingColor:color andShading:self.shading];
    }
}

- (void) drawDiamondWithOrigin:(CGPoint) origin usingColor:(UIColor *)color andShading:(NSString*)shading{
    CGFloat diamond_height = [self getDiamondHeight];
    CGFloat diamond_width = [self getDiamondWidth];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    //CGContextBeginPath(context);
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:CGPointMake(origin.x, origin.y)];
    [aPath addLineToPoint:CGPointMake(origin.x - [self getDiamondWidth]/2, origin.y + diamond_height/2)];
    [aPath addLineToPoint:CGPointMake(origin.x, origin.y + diamond_height)];
    [aPath addLineToPoint:CGPointMake(origin.x + diamond_width/2, origin.y + diamond_height/2)];
    [aPath closePath];
    
    if([shading isEqualToString:@"filled"]) {
        [aPath fill];
    }else {
        [aPath stroke];
        if([shading isEqualToString:@"lines"]) {
            CGContextSaveGState(context);
            [aPath addClip];
            [self addLineShadingWithColor:color];
            CGContextRestoreGState(context);
        }
    }
}

// Add line shading to the whole view
- (void) addLineShadingWithColor:(UIColor *) color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    int y = 0;
    for (int x =0; x<200; x+=5) {
        [aPath moveToPoint:CGPointMake(x, 0)];
        [aPath addLineToPoint:CGPointMake(0, y)];
        y += 5;
    }
    [aPath stroke];
}

- (void) setup {
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void) awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    self.i = 0;
    return self;
}

@end

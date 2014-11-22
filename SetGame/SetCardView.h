//
//  ViewX.h
//  ViewTest
//
//  Created by Bilal Ahmad on 11/4/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetCardView : UIView

@property (nonatomic) BOOL chosen;
@property (nonatomic) BOOL matched;

@property (nonatomic, strong) NSString * shape;
@property (nonatomic, strong) NSString * shading;
@property (nonatomic) int count;
@property (nonatomic, strong) UIColor * color;

@end

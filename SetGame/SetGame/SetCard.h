//
//  UNOCard.h
//  MemoryMatch
//
//  Created by Bilal Ahmad on 10/25/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface SetCard : Card

@property (nonatomic, strong) NSString * shape;
@property (nonatomic, strong) NSString * shade;
@property (nonatomic, strong) UIColor * color;
@property (nonatomic) int count;

+ (NSArray *) validShapes;
+ (int) maxCount;
+ (NSArray *) validColors;
+ (NSArray *) validShades;

@end

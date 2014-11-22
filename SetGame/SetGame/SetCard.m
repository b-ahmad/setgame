//
//  UNOCard.m
//  MemoryMatch
//
//  Created by Bilal Ahmad on 10/25/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

+ (NSArray *) validShapes {
    return @[@"diamond", @"oval", @"curve"];
}

+ (NSArray *) validShades {
    return @[@"filled", @"lines", @"empty"];
}

+ (int) maxCount {
    return 3;
}

+ (NSArray *) validColors {
    return @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
}

@end

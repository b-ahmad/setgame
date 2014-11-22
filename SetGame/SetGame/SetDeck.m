//
//  UNOCardDeck.m
//  MemoryMatch
//
//  Created by Bilal Ahmad on 10/25/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "SetDeck.h"
#import "SetCard.h"

@interface  SetDeck()
//@property (nonatomic, strong) NSMutableArray * cards;

@end


@implementation SetDeck


- (instancetype)init {
    self = [super init];
    
    if(self) {
        for (NSString * shape in [SetCard validShapes]) {
            for (NSString * shade in [SetCard validShades]) {
                for (UIColor * color in [SetCard validColors]) {
                    for (int i = 1; i < [SetCard maxCount] + 1; i++) {
                        SetCard * card = [[SetCard alloc] init];
                        card.count = i;
                        card.shape = shape;
                        card.color = color;
                        card.shade = shade;
                        //NSLog(@"SetDeck: Adding card to deck");
                        [self addCard:card];
                    }
                }
            }
        }
    }
    return self;
}

@end

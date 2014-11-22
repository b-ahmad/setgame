//
//  CardDeck.m
//  MemoryMatch
//
//  Created by Bilal Ahmad on 10/25/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "CardDeck.h"
#import "Card.h"

@interface CardDeck()
@property (nonatomic, strong) NSMutableArray * cards;//Array of cards

@end


@implementation CardDeck


- (NSMutableArray *)cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
    
}

- (void) addCard:(Card *)card {
    //NSLog(@"CardDeck: Adding card");
    [self.cards addObject:card];//no gaurding against invalid cards for now
}

- (Card *) drawRandomCard {
    if([self.cards count] == 0) {
        return nil;
    }
    int index = arc4random() % [self.cards count];//whats the range of random numbers ?
    
    Card * randomCard = [self.cards objectAtIndex:index];
    [self.cards removeObjectAtIndex:index];
    return randomCard;
}

@end

//
//  CardDeck.h
//  MemoryMatch
//
//  Created by Bilal Ahmad on 10/25/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface CardDeck : NSObject

- (Card *) drawRandomCard;
- (void) addCard:(Card *) card;

@end

//
//  SetGame.h
//  SetGame
//
//  Created by Bilal Ahmad on 11/18/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SetDeck.h"
#import "SetCard.h"

@interface SetGame : NSObject

- (instancetype) initSetGamewithCardCount:(int) count usingDeck:(SetDeck *) deck;

- (void) chooseCardAtIndex:(int) index;
- (void) removeSetCardAtIndex:(int) index;

- (NSMutableArray *) getSetCardsInGame;
- (NSMutableArray *) addSetCardsUsingDeck:(SetDeck *) deck cardCount:(int) count;
- (NSString *) getStatusMessage;
- (NSMutableArray *)getMismatchedCards;
- (NSMutableArray *) getMatchingSetCards;
- (void) clearMisMatchedCards;
- (NSMutableArray *)getHintedCards;
- (SetCard *) hint;

@end

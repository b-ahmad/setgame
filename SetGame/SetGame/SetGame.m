//
//  SetGame.m
//  SetGame
//
//  Created by Bilal Ahmad on 11/18/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "SetCard.h"
#import "SetDeck.h"
#import "CardDeck.h"
#import "SetGame.h"

@interface SetGame()

@property (nonatomic, strong) NSMutableArray * cards; // array of setCards which are in the game right now (on display)
@property (nonatomic, strong) NSMutableArray * mismatchedCards;
@property (nonatomic, strong) NSString * statusMsg;

@end


@implementation SetGame

- (void) clearMisMatchedCards {
    [self.mismatchedCards removeAllObjects];
}

- (instancetype) initSetGamewithCardCount:(int)count usingDeck:(SetDeck *)deck {
    
    self = [super init];
    NSLog(@"SetGame: Initializer");
    if(self ) {
        for (int i = 0; i < count; i++) {
            Card * card = [deck drawRandomCard];
            if(card) {
                [self.cards addObject:card];
            } else { break; }
        }
    }
    //NSLog(@"SetGame: size of cards : %d", [self.cards count]);//no status update in the beginning of the game
    return self;
}

- (NSMutableArray *) addSetCardsUsingDeck:(SetDeck *)deck cardCount:(int)count {
    self.statusMsg = @"";
    NSMutableArray * newCards = [[NSMutableArray alloc] init];
    if([[self getMatchingSetCards] count] == 3) {
        
        return newCards;
    }
    for (int i = 0; i < count; i++) {
        Card * card = [deck drawRandomCard];
        if(card) {
            [self.cards addObject:card];
            [newCards addObject:card];
        } else {
            break; }
    }
    if([newCards count] == 0) {
        self.statusMsg = @"No more cards in the deck";
        NSLog(@"No more cards in the deck");
    }
    return newCards;
}

- (NSMutableArray *) getMatchingSetCards {
    NSMutableArray * set = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.cards count]; i++) {
        [set removeAllObjects];
        [set addObject:[self.cards objectAtIndex:i]];
        for (int j=i+1; j<[self.cards count]; j++) {
            [set addObject:[self.cards objectAtIndex:j]];
            for (int k=j+1; k<[self.cards count]; k++) {
                [set addObject:[self.cards objectAtIndex:k]];
                if([self isThisASet:set]) {
                    return set;
                } else {
                    [set removeLastObject];
                }
            }
            [set removeLastObject];
        }
    }
    return set;
}



- (void) chooseCardAtIndex:(int)index {
    [self.mismatchedCards removeAllObjects];
    SetCard * card = [self.cards objectAtIndex:index];
    self.statusMsg = @"";
    if (!card.matched) {
        if(!card.chosen ) {
            card.chosen = TRUE;
            
            NSMutableArray * chosenCards = [self getChosenCards];
            if([chosenCards count] == 3) {
                //NSLog(@"Now is the time to do some processing");
                SetCard * card1 = [chosenCards objectAtIndex:0];
                SetCard * card2 = [chosenCards objectAtIndex:1];
                SetCard * card3 = [chosenCards objectAtIndex:2];
                
                if([self isThisASet:chosenCards]) {
                    card1.matched = TRUE;
                    card2.matched = TRUE;
                    card3.matched = TRUE;
                    self.statusMsg = @"MATCH !!";
                    return;
                }
                //cards did not match, unchose them
                card1.chosen = FALSE;
                card2.chosen = FALSE;
                card3.chosen = FALSE;
                
                [self.mismatchedCards addObject:card1];
                [self.mismatchedCards addObject:card2];
                [self.mismatchedCards addObject:card3];
                //NSLog(@"added three cards, %d", [self.mismatchedCards count]);
            }
        } else {
            card.chosen = FALSE;
        }
    }
}

- (BOOL) isThisASet:(NSMutableArray *) cards {
    if([cards count] != 3) {
        return FALSE;
    }
    SetCard * card1 = [cards objectAtIndex:0];
    SetCard * card2 = [cards objectAtIndex:1];
    SetCard * card3 = [cards objectAtIndex:2];
    
    self.statusMsg = @"Count mismatch";    
    if ((card1.count == card2.count && card2.count == card3.count) ||
        (card1.count != card2.count && card2.count != card3.count && card3.count != card1.count)) {
        
        
        self.statusMsg = @"Shading mismatch";
        if (([card1.shade isEqualToString:card2.shade] && [card2.shade isEqualToString:card3.shade]) ||
            (![card1.shade isEqualToString:card2.shade] && ![card2.shade isEqualToString:card3.shade] && ![card3.shade isEqualToString:card1.shade])) {
            
            self.statusMsg = @"Shapes mismatch";
            if (([card1.shape isEqualToString:card2.shape] && [card2.shape isEqualToString:card3.shape]) ||
                (![card1.shape isEqualToString:card2.shape] && ![card2.shape isEqualToString:card3.shape] && ![card3.shape isEqualToString:card1.shape])) {
                
                self.statusMsg = @"Colors mismatch";
                if (([card1.color isEqual:card2.color] && [card2.color isEqual:card3.color]) ||
                    (![card1.color isEqual:card2.color] && ![card2.color isEqual:card3.color] && ![card3.color isEqual:card1.color])) {
                    return TRUE;
                    
                }
            }
        }
        
    }
    return FALSE;
}



- (SetCard *) hint {
    
}


//--- private methods below ----

- (NSString *) getStatusMessage {
    return _statusMsg;
}

- (NSMutableArray *) getMismatchedCards {
    if(!_mismatchedCards) _mismatchedCards = [[NSMutableArray alloc] init];
    return _mismatchedCards;
}


- (NSMutableArray *) getChosenCards {
    NSMutableArray * chosenCards = [[NSMutableArray alloc] init];
    for (SetCard * card in self.cards) {
        if(card.chosen && !card.matched) {
            [chosenCards addObject:card];
        }
    }
    return chosenCards;
}

- (void) removeSetCardAtIndex:(int)index {
    [self.cards removeObjectAtIndex:index];
}

- (NSMutableArray *) cards {
    if(!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}


- (NSMutableArray *) getSetCardsInGame {
    return _cards;
}


@end

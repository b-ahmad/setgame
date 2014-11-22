//
//  ViewController.m
//  ViewTest
//
//  Created by Bilal Ahmad on 11/4/14.
//  Copyright (c) 2014 Bilal Ahmad. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardView.h"
#import "SetDeck.h"
#import "SetCard.h"
#import "SetGame.h"
#import "CardsDisplayArea.h"
#import <QuartzCore/QuartzCore.h>


@interface SetGameViewController ()


@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *addMoreCards;

@property (nonatomic, strong) SetGame * game; //our model
@property (nonatomic, strong) SetDeck * deck;//deck of cards to use
@property (nonatomic, strong) NSMutableArray * cardViews; //array of SuperCardViews
@property (strong, nonatomic) CardsDisplayArea * gameView;
@property (weak, nonatomic) IBOutlet UIView *displayArea;

@property (nonatomic) int cardOrigin_xaxis;
@property (nonatomic) int cardOrigin_yaxis;
@property (nonatomic) int screenWidthRemaining;
@property (nonatomic) int screenHeightRemaining;

@property (nonatomic) int cardWidth;
@property (nonatomic) int cardHeight;
@property (nonatomic) int numberOfCardsInRow;
@property (nonatomic) int numberOfCardsInCol;
@property (nonatomic) double scale;

@end

@implementation SetGameViewController

# define GAP_BETWEEN_CARDS_X 5
# define GAP_BETWEEN_CARDS_Y 5
# define LEFT_PADDING 0
# define TOP_PADDING 0

- (void)viewDidLoad {
    [super viewDidLoad];
    // from here : http://stackoverflow.com/questions/13446920/how-can-i-get-a-views-current-width-and-height-when-using-autolayout-constraint
    [self.displayArea setNeedsLayout];
    [self.displayArea layoutIfNeeded];
    
    [self initializeGlobalVariables];
    
    for (SetCard * card in [self.game getSetCardsInGame]) {
        [self addCardToCardsViewArray:card];
    }
    
    self.statusLabel.text = @"Let the game begin !";
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"Yippie !!, screen width:%d",self.screenWidthRemaining);
    [self reDisplayAllCards];
}

- (void) initializeGlobalVariables {
    self.cardWidth = 70;
    self.cardHeight = 90;
    self.cardOrigin_xaxis = LEFT_PADDING;
    self.cardOrigin_yaxis = TOP_PADDING;
    self.screenWidthRemaining = self.displayArea.frame.size.width;
    self.screenHeightRemaining = self.displayArea.frame.size.height;
    self.numberOfCardsInRow = 1;
    self.numberOfCardsInCol = 1;
    self.scale = 1.0;
    //self.addMoreCards.enabled = FALSE;
    NSLog(@"display width : %d",self.screenWidthRemaining);
}

- (void) getCardsFromModel:(int) count usingDeck:(SetDeck *) deck {
    NSMutableArray * newCards = [self.game addSetCardsUsingDeck:deck cardCount:count];
    for (SetCard * card in newCards) {
        [self addCardToCardsViewArray:card];
    }
    [self updateUI];
}

- (IBAction)addMoreCards:(id)sender {
    if([self canPlaceCards:3 withSize:CGSizeMake(self.cardWidth, self.cardHeight) horizontalSpacing:GAP_BETWEEN_CARDS_X verticalSpacing:GAP_BETWEEN_CARDS_Y enableFullScreen:FALSE]) {
        [self getCardsFromModel:3 usingDeck:self.deck];
    } else {
        if(self.cardWidth == 70) {
            if([self canPlaceCards:[[self cardViews] count]+3 withSize:CGSizeMake(self.cardWidth*0.8, self.cardHeight*0.8) horizontalSpacing:GAP_BETWEEN_CARDS_X verticalSpacing:GAP_BETWEEN_CARDS_Y enableFullScreen:TRUE]) {
                [self getCardsFromModel:3 usingDeck:self.deck];
                self.scale = 0.8;
                [self reSizeAllCardViews];
            } else {
                NSLog(@"Card fit in that many cards even if card size is small");
            }
        } else {
            NSLog(@"Card size is already small, cant add new cards");
        }
    }
}
- (void) reSizeAllCardViews {
    for (SetCardView * view in self.cardViews) {
        view.transform = CGAffineTransformMakeScale(self.scale, self.scale);
        self.cardWidth = view.frame.size.width;
        self.cardHeight = view.frame.size.height;
        NSLog(@"resizing, card width %d, card height %d", self.cardWidth, self.cardHeight);
    }
    
    [self reDisplayAllCards];
}

- (void) addCardToCardsViewArray:(SetCard *) setCard {
    [self updateCoordinatesForCardWithSize:CGSizeMake(self.cardWidth, self.cardHeight) horizontalSpacing:GAP_BETWEEN_CARDS_X verticalSpacing:GAP_BETWEEN_CARDS_Y];
    //NSLog(@"--addCArdstoCardsArray, x%d, y%d", self.cardOrigin_xaxis, self.cardOrigin_yaxis);
    CGRect cardRect = CGRectMake(self.cardOrigin_xaxis, self.cardOrigin_yaxis, 70, 90);
    //[self updateCoordinatesForNextCard];

    
    SetCardView * card = [[SetCardView alloc] initWithFrame:cardRect];
    card.shape = setCard.shape;
    card.shading = setCard.shade;
    card.color = setCard.color;
    card.count = setCard.count;
    
    
    card.transform = CGAffineTransformMakeScale(self.scale,self.scale);
    card.center = CGPointMake(self.cardOrigin_xaxis + card.frame.size.width / 2, self.cardOrigin_yaxis + card.frame.size.height / 2);
    /*
    
    CGPoint center = card.center;
    card.transform = CGAffineTransformMakeScale(2, 2);
    card.center = center;
    */
    self.cardWidth = card.frame.size.width;
    self.cardHeight = card.frame.size.height;
    
    
    UITapGestureRecognizer *fingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [card addGestureRecognizer:fingerTap];
    
    [self.cardViews addObject:card];
    [self.displayArea  addSubview:card];
}





- (void) updateCoordinatesForCardWithSize:(CGSize)cardSize horizontalSpacing:(int) xGap verticalSpacing:(int)yGap {
    if(self.screenWidthRemaining == self.displayArea.frame.size.width && self.screenHeightRemaining == self.displayArea.frame.size.height) {
        self.screenHeightRemaining -= (cardSize.height + yGap);
        self.screenWidthRemaining -= (cardSize.width + xGap);
    } else if (self.screenWidthRemaining >= (cardSize.width + xGap)) {
        self.cardOrigin_xaxis += cardSize.width + xGap;
        self.screenWidthRemaining -= (cardSize.width + xGap);
        if(self.numberOfCardsInCol == 1) {self.numberOfCardsInRow++;}
    } else {
        self.cardOrigin_xaxis = LEFT_PADDING;
        self.cardOrigin_yaxis += cardSize.height + yGap;
        self.screenWidthRemaining = self.displayArea.frame.size.width - cardSize.width - xGap;
        self.screenHeightRemaining -= (cardSize.height + yGap);
        self.numberOfCardsInCol++;
    }
    //NSLog(@"width remaining : %d", self.screenWidthRemaining);
}

- (void) reDisplaySingleCard:(SetCardView *)cardView {
    [self updateCoordinatesForCardWithSize:CGSizeMake(self.cardWidth, self.cardHeight) horizontalSpacing:GAP_BETWEEN_CARDS_X verticalSpacing:GAP_BETWEEN_CARDS_Y];
    NSLog(@"--card size, x %d, y %d", self.cardWidth, self.cardHeight);
    //NSLog(@"update cordinates result x %d, y%d", self.cardOrigin_xaxis, self.cardOrigin_yaxis);
    CGPoint origin = CGPointMake(self.cardOrigin_xaxis, self.cardOrigin_yaxis);
    [UIView animateWithDuration:0.5f animations:^{
        cardView.center = CGPointMake(origin.x + cardView.frame.size.width / 2, origin.y + cardView.frame.size.height / 2);
    }];
}

- (void) resetGlobalVals {
    self.cardOrigin_xaxis = LEFT_PADDING;
    self.cardOrigin_yaxis = TOP_PADDING;
    self.screenWidthRemaining = self.displayArea.frame.size.width;
    self.screenHeightRemaining = self.displayArea.frame.size.height;
    self.numberOfCardsInRow = 1;
    self.numberOfCardsInCol = 1;
}

- (void) reDisplayAllCards {
    [self resetGlobalVals];
    
    for (SetCardView * view in self.cardViews) {
        [self reDisplaySingleCard:view];
    }
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"handleTAp : x %d, y %d", self.cardWidth, self.cardHeight);
    
    int column = [self cardIsInColumn:location.x];
    int row = [self cardIsInRow:location.y];
    [self updateNumberofCardRows];
    NSLog(@"no of cards in row %d, col %d", self.numberOfCardsInRow, self.numberOfCardsInCol);
    int cardIndex = ((row) * self.numberOfCardsInRow) + column;
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
}

//remove the passed in cards from both game (setCards array) and this controller(SuperCardViews array)
- (void) removeCardsAtIndexes:(NSMutableArray *) indexList {
    // we need to remove the higher indexes first
    NSMutableArray* reversedArray = [[NSMutableArray alloc] initWithArray:[[[[NSArray alloc] initWithArray: indexList] reverseObjectEnumerator] allObjects]];
    
    for (NSNumber * index in reversedArray) {
        SetCardView * cardView = [self.cardViews objectAtIndex:[index integerValue]];
        // add animation so that cards movement is smooth
        [UIView animateWithDuration:0.5f animations:^{
            [cardView removeFromSuperview];
        }];
        
        [self.cardViews removeObjectAtIndex:[index integerValue]];
        [self.game removeSetCardAtIndex:[index integerValue]]; //remove this card from the model/game as well
    }
    
}

- (void) updateNumberofCardRows {
    int width_remaining = self.screenWidthRemaining;
    int height_remaining = self.screenHeightRemaining;
    int cardOrigin_x = self.cardOrigin_xaxis;
    int cardOrigin_y = self.cardOrigin_yaxis;
    [self resetGlobalVals];
    self.screenWidthRemaining = self.displayArea.frame.size.width;
    self.screenHeightRemaining = self.displayArea.frame.size.height;
    self.cardOrigin_xaxis = LEFT_PADDING;
    self.cardOrigin_yaxis = TOP_PADDING;
    
    NSLog(@"update row : card x %d, y%d", self.cardWidth, self.cardHeight);
    for (int i=0; i<100; i++) {
        [self updateCoordinatesForCardWithSize:CGSizeMake(self.cardWidth, self.cardHeight) horizontalSpacing:GAP_BETWEEN_CARDS_X verticalSpacing:GAP_BETWEEN_CARDS_Y];
        if (self.numberOfCardsInCol ==2) {
            break;
        }
    }
    
    self.screenWidthRemaining = width_remaining;
    self.screenHeightRemaining = height_remaining;
    self.cardOrigin_xaxis = cardOrigin_x;
    self.cardOrigin_yaxis =cardOrigin_y;
}

- (void) updateUI {
    NSMutableArray * cards = [self.game getSetCardsInGame];
    NSMutableArray * indexesOfMatchedCards = [[NSMutableArray alloc] init];
    
    NSMutableArray * mismatchedCards = [self.game getMismatchedCards];
    NSMutableArray * viewsToShake = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.cardViews count]; i++) {
        // setCards list in model and SuperCardViews in controller is always synced
        SetCard * card = [cards objectAtIndex:i];
        SetCardView * cardView = [self.cardViews objectAtIndex:i];
        
        if([mismatchedCards containsObject:card]) {
            [viewsToShake addObject:cardView];
        }
        
        cardView.chosen = card.chosen;
        
        if(card.matched) {
            [indexesOfMatchedCards addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    if ([viewsToShake count] > 0) {
        for (SetCardView * cardView in viewsToShake) {
            //[self shakeView:cardView];//TODO: put back shake after figuring out the solution
        }
    } else if ([indexesOfMatchedCards count] > 0) {
        [self removeCardsAtIndexes:indexesOfMatchedCards];
        [self reDisplayAllCards];
    }
}

//---- ----- ---- ----- ----- ------ -----
//---- ----- ---- ----- ----- ------ -----
//---- ----- ---- ----- ----- ------ -----
//---- ----- ---- ----- ----- ------ -----
//---- ----- ---- ----- ----- ------ -----

- (BOOL) canPlaceCards:(int) count withSize:(CGSize)cardSize horizontalSpacing:(int) xGap verticalSpacing:(int)yGap enableFullScreen:(BOOL) fullScreen{
    int width_remaining = self.screenWidthRemaining;
    int height_remaining = self.screenHeightRemaining;
    int cardOrigin_x = self.cardOrigin_xaxis;
    int cardOrigin_y = self.cardOrigin_yaxis;
    
    if (fullScreen) {
        self.screenWidthRemaining = self.displayArea.frame.size.width;
        self.screenHeightRemaining = self.displayArea.frame.size.height;
        self.cardOrigin_xaxis = LEFT_PADDING;
        self.cardOrigin_yaxis = TOP_PADDING;
    }
    
    for (int i = 0; i < count; i++) {
        if ([self canPlaceCardWithSize:cardSize horizontalSpacing:xGap verticalSpacing:yGap]) {
            [self updateCoordinatesForCardWithSize:cardSize horizontalSpacing:xGap verticalSpacing:yGap];
        } else {
            NSLog(@"Unable to place %d cards, failed on %d card", count, i);
            return FALSE;
        }
    }
    
    self.screenWidthRemaining = width_remaining;
    self.screenHeightRemaining = height_remaining;
    self.cardOrigin_xaxis = cardOrigin_x;
    self.cardOrigin_yaxis =cardOrigin_y;
    //NSLog(@"Can place %d cards", count);
    return TRUE;
}

- (BOOL) canPlaceCardWithSize:(CGSize)cardSize horizontalSpacing:(int) xGap verticalSpacing:(int)yGap {
    if (self.screenWidthRemaining >= (cardSize.width)) {
        return TRUE;
    } else if (self.screenHeightRemaining >= (cardSize.height)) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (int) cardIsInColumn:(CGFloat) x {
    x -= LEFT_PADDING;
    for (int col =0; col<10; col++) {//TODO: remove magic number 10 (its an arbitrary high no)
        x -= (self.cardWidth + GAP_BETWEEN_CARDS_X);
        if (x < 0) {
            return col;
        }
    }
    return -1;
}

- (int) cardIsInRow:(CGFloat) y {
    y -= TOP_PADDING;
    for (int row =0; row<10; row++) {//TODO: remove magic number 10 (its an arbitrary high no)
        y -= (self.cardHeight + GAP_BETWEEN_CARDS_Y);
        if (y < 0) {
            return row;
        }
    }
    return -1;
}

- (SetDeck *) deck {
    if (!_deck) _deck = [[SetDeck alloc] init];
    return _deck;
}

- (NSMutableArray *) cardViews {
    if (!_cardViews) _cardViews = [[NSMutableArray alloc] init];
    return _cardViews;
}

- (SetGame *) game {
    if (!_game) _game = [[SetGame alloc] initSetGamewithCardCount:9 usingDeck:self.deck];
    return _game;
}

@end

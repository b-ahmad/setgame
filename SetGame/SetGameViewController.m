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
//# define CARDS_DISPLAY_AREA_WIDTH self.view.frame.size.width
//# define CARDS_DISPLAY_AREA_HEIGHT 300

- (void)viewDidLoad {
    [super viewDidLoad];
    // from here : http://stackoverflow.com/questions/13446920/how-can-i-get-a-views-current-width-and-height-when-using-autolayout-constraint
    [self.displayArea setNeedsLayout];
    [self.displayArea layoutIfNeeded];
    NSLog(@"display width : %f",self.displayArea.window.screen.bounds.size.width);

    [self initializeGlobalVariables];
    
    for (SetCard * card in [self.game getSetCardsInGame]) {
        [self addCardToCardsViewArray:card];
    }
    
    //self.addMoreCards.enabled = ([[self.game getMatchingSetCards] count] == 0) ? YES : NO;
    self.statusLabel.text = @"Let the game begin !";
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"Yippie !!");
    [self reDisplayAllCards];
}

- (void) initializeGlobalVariables {
    self.cardWidth = 70;
    self.cardHeight = 90;
    self.cardOrigin_xaxis = LEFT_PADDING;
    self.cardOrigin_yaxis = TOP_PADDING;
    self.screenWidthRemaining = self.displayArea.frame.size.width;
    self.screenHeightRemaining = self.displayArea.frame.size.height - self.cardHeight;
    self.numberOfCardsInRow = 1;
    self.numberOfCardsInCol = 1;
    self.scale = 1.0;
    //self.addMoreCards.enabled = FALSE;
    NSLog(@"display width : %d",self.screenWidthRemaining);
}

- (BOOL) canDisplayOneCard {
   // int width = self.displayArea.frame.size.width;
    //int height = self.displayArea.frame.size.height;
    [self updateCoordinatesForNextCard];
    NSLog(@"height remianig : %d", self.screenHeightRemaining);
    BOOL result = (self.screenHeightRemaining > 0);
    
    //self.screenHeightRemaining = height;
    //self.screenWidthRemaining = width;
    return result;
}

- (IBAction)addMoreCards:(id)sender {
    BOOL r = FALSE;
    
    int width = self.screenWidthRemaining;
    int height = self.screenHeightRemaining;
    int x = self.cardOrigin_xaxis;
    int y = self.cardOrigin_yaxis;
    
    //self.screenWidthRemaining = self.displayArea.frame.size.width;
    //self.screenHeightRemaining = self.displayArea.frame.size.height;
    
    for (int i=0; i<3; i++) {
        r = [self canDisplayOneCard];
    }
    
    self.screenHeightRemaining = height;
    self.screenWidthRemaining = width;
    self.cardOrigin_xaxis = x;
    self.cardOrigin_yaxis = y;

    
    if(self.cardWidth != 70) {
    
        if(!r) {
            NSLog(@"No space to place card");

            return;
        }
    }

    
    //NSLog(@"BUT PRESSED");
    NSMutableArray * newCards = [self.game addSetCardsUsingDeck:self.deck cardCount:3];
    if([newCards count] == 0) {
        //self.addMoreCards.enabled = NO;
    }
    for (SetCard * card in newCards) {
        [self addCardToCardsViewArray:card];
    }
    if([self cardViewsNeedReSize]) {
        [self reSizeCardViews];
    }
    [self updateUI];
}

- (void) addCardToCardsViewArray:(SetCard *) setCard {
    /*if(![self canDisplayAnotherCardView]) {
        NSLog(@"No space to display new cards");
        self.statusLabel.text = @"out of space";
        if([self cardViewsNeedReSize]) {
            [self reSizeCardViews];
        }
        if(![self canDisplayAnotherCardView]) {
            return;
        }
    }*/
    CGRect cardRect = CGRectMake(self.cardOrigin_xaxis, self.cardOrigin_yaxis, self.cardWidth, self.cardHeight);
    [self updateCoordinatesForNextCard];
    
    SetCardView * card = [[SetCardView alloc] initWithFrame:cardRect];
    card.shape = setCard.shape;
    card.shading = setCard.shade;
    card.color = setCard.color;
    card.count = setCard.count;
    
    UITapGestureRecognizer *fingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [card addGestureRecognizer:fingerTap];
    
    [self.cardViews addObject:card];
    [self.displayArea  addSubview:card];
}



- (void) updateCoordinatesForNextCard {
    self.screenWidthRemaining -= self.cardWidth + GAP_BETWEEN_CARDS_X;
    if (self.screenWidthRemaining > (self.cardWidth + GAP_BETWEEN_CARDS_X)) {
        self.cardOrigin_xaxis += (self.cardWidth + GAP_BETWEEN_CARDS_X);
        
        if(self.numberOfCardsInCol == 1) {
            //NSLog(@"incrementing rows: %d", self.numberOfCardsInRow);
            self.numberOfCardsInRow++;}
    } else {
        self.screenWidthRemaining = self.displayArea.frame.size.width;
        self.screenHeightRemaining -= (self.cardHeight + GAP_BETWEEN_CARDS_Y);
        self.numberOfCardsInCol++;
        
        self.cardOrigin_xaxis = LEFT_PADDING;
        self.cardOrigin_yaxis += (self.cardHeight + GAP_BETWEEN_CARDS_Y);
    }
}

- (BOOL) cardViewsNeedReSize {
    //NSLog(@"screen hight : %d", self.screenHeightRemaining);
    if(self.screenHeightRemaining < 0 && self.scale == 1) {
        self.scale = 0.8;
        return TRUE;
    }
    return FALSE;
}

- (BOOL) cardViewsNeedSizeIncrease {
    if(self.cardWidth == 70) {
        return FALSE;
    }
    [self.displayArea setNeedsLayout];
    [self.displayArea layoutIfNeeded];
    
    int displayWidth_backup = self.screenWidthRemaining;
    int displayHeight_backup = self.screenHeightRemaining;
    int cardWidth_backup = self.cardWidth;
    int cardHeight_backup = self.cardHeight;
        
    self.screenWidthRemaining = self.displayArea.frame.size.width;
    self.screenHeightRemaining = self.displayArea.frame.size.height;
    self.cardWidth = 70;
    self.cardHeight = 90;
    
    for (SetCardView * view in self.cardViews) {
        [self updateCoordinatesForNextCard];
    }
    
    NSLog(@"Screen width ::::: >> %d", self.screenWidthRemaining);
    NSLog(@"Screen height ::::: >> %d", self.screenHeightRemaining);
    BOOL result = (self.screenHeightRemaining > 0);
    
    self.screenWidthRemaining =   displayWidth_backup;
    self.screenHeightRemaining =  displayHeight_backup;
    self.cardWidth = cardWidth_backup;
    self.cardHeight = cardHeight_backup;

    return result;
}

- (BOOL) canDisplayAnotherCardView:(SetCardView *) view {
    
    int displayWidth = self.screenWidthRemaining - self.cardWidth - GAP_BETWEEN_CARDS_X;
    int displayHeight = self.screenHeightRemaining - self.cardHeight - GAP_BETWEEN_CARDS_Y;
    return (displayWidth > 0 && displayHeight > 0);
}

- (void) reDisplaySingleCard:(SetCardView *)cardView {
    CGPoint origin = CGPointMake(self.cardOrigin_xaxis, self.cardOrigin_yaxis);
    [UIView animateWithDuration:0.5f animations:^{
        cardView.center = CGPointMake(origin.x + cardView.frame.size.width / 2, origin.y + cardView.frame.size.height / 2);
    }];
    
    [self updateCoordinatesForNextCard];
}


- (void) reDisplayAllCards {
    self.screenWidthRemaining = [self.displayArea bounds].size.width;
    self.screenHeightRemaining = [self.displayArea bounds].size.height - self.cardHeight;
    self.cardOrigin_xaxis = LEFT_PADDING;
    self.cardOrigin_yaxis = TOP_PADDING;
    self.numberOfCardsInRow = 1;
    self.numberOfCardsInCol = 1;
    
    for (int i=0; i<[self.cardViews count]; i++) {
        [self reDisplaySingleCard:[self.cardViews objectAtIndex:i]];
    }
}

// assumption it'll only be required when adding 3 more cards
- (void) reSizeCardViews {
    for (SetCardView * view in self.cardViews) {
        view.transform = CGAffineTransformMakeScale(self.scale, self.scale);
        self.cardWidth = view.frame.size.width;
        self.cardHeight = view.frame.size.height;
    }

    [self reDisplayAllCards];
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    int column = [self cardIsInColumn:location.x];
    int row = [self cardIsInRow:location.y];
    NSLog(@"no of cards in row %d, col %d", self.numberOfCardsInRow, self.numberOfCardsInCol);
    int cardIndex = ((row) * self.numberOfCardsInRow) + column;
    
    [self.game chooseCardAtIndex:cardIndex];
    
    [self updateUI];
    //SetCardView * v = [self.cardViews objectAtIndex:cardIndex];
    //NSLog(@"card size, width : %f", v.frame.size.width);
    //NSLog(@"tapped row : %d, col : %d, cardNo : %d", row, column, cardIndex);
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
    
    //check if cardview size can be increased
    if ([self cardViewsNeedSizeIncrease]) {
        NSLog(@"Card size can be increased");
        [self increaseScale];
    } else {
        NSLog(@"Card size can NOT increased");
    }
    
}

- (void) increaseScale {
    self.scale = 1;
    [self reSizeCardViews];
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
    
    int match = [[self.game getMatchingSetCards] count];
    //NSLog(@"..... %d", match);
    //self.addMoreCards.enabled = (match != 3) ? YES : NO;
    [self.statusLabel setText:[self.game getStatusMessage]];
}

// this from here : http://stackoverflow.com/questions/1632364/shake-visual-effect-on-iphone-not-shaking-the-device
- (void)shakeView:(UIView *)viewToShake
{
    CGFloat t = 2.0;
    //CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    //CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    
    //TODO should not use scale here
    
    CGAffineTransform translateRight  = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.scale, self.scale), t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformMakeScale(self.scale, self.scale), -t, 0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:7.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                //viewToShake.transform = CGAffineTransformIdentity;//ORIGINAL LINE
                viewToShake.transform = CGAffineTransformMakeScale(self.scale, self.scale);
            } completion:NULL];
        }
    }];
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
    if (!_game) _game = [[SetGame alloc] initSetGamewithCardCount:6 usingDeck:self.deck];
    return _game;
}




@end

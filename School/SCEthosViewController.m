//
//  SCEthosViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCEthosViewController.h"

@interface SCEthosViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation SCEthosViewController

- (void)viewDidLoad
{
    [self.navigationItem setTitle:@"Our Ethos"];
    
    [self setTextView:[[UITextView alloc] initWithFrame:[self.view frame]]];
    [self.textView setEditable:NO];
    [self.textView setShowsHorizontalScrollIndicator:NO];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"University College School has always prized the twin principles of freedom of intellect and respect for individuality since the earliest days of its foundation as part of University College, London in 1830.\n\nWe select students with no regard to race or creed, each member of the School family fosters in them a sense of community, alongside a tolerance of and respect for others.\n\nThe absence of bells, the insistence on rules that develop rather than restrict, the mix of faiths, the mix of backgrounds, the breadth of subjects, and the range of opportunities at the School all show the unique intellectual and social liberalism that underpins UCS’s reputation.\n\nBy offering the fullest range of opportunities for personal and group endeavour, the School teaches the value of commitment and the joy of achievement. UCS is thus not only a place of study, but also of self-discovery and self-expression; a school that places equal value on learning with others, as much as on learning from others.\n\nThe School, described by Old Gower Stephen Spender as “that most gentlest of schools,” has been a formative part in the development of each and every one of its pupils.\n\nWell known OGs include Walter Sickert (artist), Sir Roger Penrose (mathematician), Dirk Bogarde (actor), Thom Gunn (poet), Julian Lloyd-Webber (musician) and Sir Roger Bannister (athlete and neurologist)." attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f]}];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0f]} range:NSMakeRange(0, 25)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13.0f]} range:[[attributedString string] rangeOfString:@"no regard to race or creed"]];
    [self.textView setAttributedText:attributedString];
    [self.view addSubview:self.textView];
    [super viewDidLoad];
}

@end

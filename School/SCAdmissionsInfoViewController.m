//
//  SCAdmissionsInfoViewController.m
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import "SCAdmissionsInfoViewController.h"

@interface SCAdmissionsInfoViewController ()

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation SCAdmissionsInfoViewController

- (id) initWithAdmissionType:(SCAdmissionType)type {
    if (self = [super initWithNibName:NSStringFromClass([SCAdmissionsInfoViewController class]) bundle:nil]) {
        _admissionType = type;
    }
    return self;
}

- (NSInteger) indexFromAdmissionType:(SCAdmissionType) type {
    switch (type) {
        case SCAdmissionTypePhoenix:
            return 0;
            break;
        case SCAdmissionTypeJunior:
            return 1;
            break;
        case SCAdmissionTypeSenior:
            return 2;
            break;
    }
}

- (NSString *) titleFromAdmissionType:(SCAdmissionType) type {
    return self.datasource[[self indexFromAdmissionType:type]][@"title"];
}

- (NSString *) informationForAdmissionType:(SCAdmissionType) type {
    return self.datasource[[self indexFromAdmissionType:type]][@"description"];
}

- (void) viewDidLoad {
    self.datasource = @[
        @{
            @"title" : @"The Phoenix",
            @"description" : @"The Phoenix School is a selective school. The number of pupils registered will normally well exceed the number of available places. The main entry point to the School is at Nursery (age 3+).\n\nOccasional places may become available in other year groups. Children are eligible for admission to the Nursery when they are three years old. Their third birthday will have fallen before 31st August in the academic year before they hope to join the School.\n\nTo register to be considered for a place in the Nursery, both parents must complete and sign the School’s Registration Form, and pay a small registration fee. Forms can be found on the School website, within the school prospectus or can be requested from the School Office.\n\nRegistrations are accepted from 1st January until mid-May in the year preceding the year of entry (the closing deadline will be published each year and will normally be the second Friday in May).\n\nFor example, registrations to join the Nursery in September 2014 open on 1st January 2013, and close on Friday 10th May 2013."
            },
        @{
            @"title" : @"Junior School",
            @"description" : @"Approximately sixty boys aged 7 will be admitted (into three classes) each year. A confidential report is requested from each candidate’s current school and this plays an important part in the selection procedure. The entrance assessment in January will consist of English, Maths and Non-Verbal Reasoning tests.\n\nTests will be administered in classrooms by two teachers who will also observe social interaction and behaviour. The boys will have the opportunity to play, and will be given light refreshments, during the three hour period they attend the school.\n\nFamilies who are not successful in obtaining a place for their son at 7, may put his name on a waitlist should a place become available\n\nOpen Evenings (4.30 - 6.00 pm) are held each year and parents are advised to bring their sons to one of them. Visitors will have the opportunity to tour the School with a present pupil, talk to staff and meet the Headmaster.  To register, or for any other information, please contact the Junior Branch Headmaster’s Secretary at 020 7435 3068.\n\nThe registration deadline for entry in 2015 is Friday 31st October 2014.\n\nFees are paid per-term and include lunch and personal accident insurance at £5,285."
            },
        @{
            @"title" : @"Senior School",
            @"description" : @"11+ Entry\n\nSixty boys will transfer from the Junior Branch to the Senior School. They will not be required to sit a further qualifying examination. Twenty eight boys aged 11 will be admitted from other schools.\n\nA confidential report is requested from each candidate’s current school and plays an important part in the assessment procedure.\n\nThe examination, held in January, will involve three papers devoted to Mathematics (calculations and problems), reasoning (verbal and non-verbal), and English (a passage for comprehension and an essay).\n\n13+ Entry\n\nTwenty seven boys aged 13 will be admitted each year. They will be required to sit Common Entrance, but will have been selected following our Preliminary Assessment two years prior.\n\nNeeds-based financial assistance with fees is available, as well as scholarship support.\n\nPlease contact the Senior School Admissions Officer with questions or to obtain a registration form at 020 7433 2117 or ssadmissions@ucs.org.uk."
            }
    ];
    
    [self.navigationItem setTitle:[self titleFromAdmissionType:self.admissionType]];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[self informationForAdmissionType:self.admissionType] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f]}];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0f] range:[string.string rangeOfString:@"11+ Entry"]];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0f] range:[string.string rangeOfString:@"13+ Entry"]];
    [self.infoTextView setAttributedText:string];
    [super viewDidLoad];
}

@end

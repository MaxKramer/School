//
//  SCAdmissionsInfoViewController.h
//  School
//
//  Created by Max Kramer on 07/11/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCAdmissionType) {
    SCAdmissionTypePhoenix = 1 << 0,
    SCAdmissionTypeJunior = 1 << 1,
    SCAdmissionTypeSenior= 1 << 2
};

@interface SCAdmissionsInfoViewController : UIViewController

- (id) initWithAdmissionType:(SCAdmissionType) type;

@property (nonatomic, assign, readonly) SCAdmissionType admissionType;
@property (nonatomic, strong) IBOutlet UITextView *infoTextView;

@end

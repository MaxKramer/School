//
//  UIPlaceholderTextView.h
//  School
//
//  Created by Max Kramer on 29/10/2013.
//  Copyright (c) 2013 Max Kramer. All rights reserved.
//

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
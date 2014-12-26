//
//  PFAppointment.h
//  MyPets
//
//  Created by Henrique Morbin on 26/12/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import <Parse/Parse.h>

@class PFAnimal;

@interface PFAppointment : PFObject<PFSubclassing>

@property (retain) PFUser *owner;
@property (retain) NSString *identifier;
@property (retain) NSDate *dateAndTime;
@property (retain) NSString *appointmentId;
@property (assign) int reminder;
@property (retain) NSString *notes;

@property (retain) PFAnimal *animal;

+ (NSString *)parseClassName;

@end

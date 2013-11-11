//
//  MPCoreDataService.h
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#define MTPSNotificationPets @"br.com.alltouch.mypets.notification.pets"



#import <Foundation/Foundation.h>

@interface MPCoreDataService : NSObject

@property (nonatomic, strong) NSMutableArray *arrayPets;
@property (nonatomic, strong) NSManagedObjectContext * context;

+ (id)shared;
- (void)loadAllPets;

@end

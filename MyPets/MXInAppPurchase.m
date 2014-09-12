//
//  MXInAppPurchase.m
//  PickUpSticks
//
//  Created by Henrique Morbin on 24/08/14.
//  Copyright (c) 2014 Henrique Morbin. All rights reserved.
//

#import "MXInAppPurchase.h"
#import "Lockbox.h"
#import "MXGoogleAnalytics.h"

@interface MXInAppPurchase ()

@property (nonatomic, assign) BOOL removeAdsPurchased;

@end

@implementation MXInAppPurchase

+ (instancetype)shared
{
    static MXInAppPurchase *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MXInAppPurchase new];
        
        manager.removeAdsPurchased = FALSE;
        
        [manager tryLoadKeychain];
    });
    return manager;
}

- (void)tryLoadKeychain
{    
    NSDate *date = [Lockbox dateForKey:kIDENTIFIER_INAPP_REMOVEADS];
    if (date) {
        self.removeAdsPurchased = YES;
    }
}

- (void)saveRemoveAdsPurchased
{
    [MXGoogleAnalytics ga_trackEventWith:@"Ads" action:@"Ads Removed"];
    
    self.removeAdsPurchased = YES;
    [Lockbox setDate:[NSDate date] forKey:kIDENTIFIER_INAPP_REMOVEADS];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIDENTIFIER_INAPP_REMOVEADS object:nil];
}

- (BOOL)checkRemoveAdsPurchased
{
    return self.removeAdsPurchased;
}
@end

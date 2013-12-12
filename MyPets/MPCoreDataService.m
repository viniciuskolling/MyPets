//
//  MPCoreDataService.m
//  MyPets
//
//  Created by Henrique Morbin on 11/11/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPCoreDataService.h"
#import "MPAppDelegate.h"
#import "Animal.h"

@implementation MPCoreDataService

+ (id)shared
{
    static MPCoreDataService *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MPCoreDataService new];
        manager.arrayPets = [NSMutableArray new];
        manager.context = [(MPAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    });
    
    return manager;
}

- (void)loadAllPets
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Animal" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *arrayResult = [self.context executeFetchRequest:request error:&error];
    if (arrayResult) {
        [self.arrayPets removeAllObjects];
        for (int i = 0; i < 7; i++) {
            for (Animal *animal in arrayResult) {
                [self.arrayPets addObject:animal];
            }
        }
    }
    
    NSLog(@"MPCoreDataService:buscarPets:%d - Completed", self.arrayPets.count);
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationPets object:nil userInfo:error ? [NSDictionary dictionaryWithObjectsAndKeys:error,@"error", nil] : nil];
}

- (Animal *)newAnimal
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Animal" inManagedObjectContext:self.context];
    
    Animal *newAnimal = [[Animal alloc] initWithEntity:entityDesc insertIntoManagedObjectContext:self.context];
    
    newAnimal.cNome    = NSLS(@"Pet");
    newAnimal.cEspecie = @"";
    newAnimal.cRaca    = @"";
    newAnimal.cSexo    = NSLS(@"Macho");
    newAnimal.cDataNascimento = [NSDate date];
    newAnimal.cObs            = @"";
    newAnimal.cFoto           = UIImageJPEGRepresentation([UIImage imageNamed:@"fotoDefault.png"], 1.0);
    newAnimal.cNeedUpdate     = [NSNumber numberWithBool:NO];
    
    NSError *error = nil;
    [self.context save:&error];
    
    [self loadAllPets];
    
    if (!error) {
        return newAnimal;
    }else{
        SHOW_ERROR(error.description);
        return nil;
    }
}
@end

//
//  CoreDataDefaultOperation.m
//  ObjectiveDump
//
//  Created by Anthony Mittaz on 2/07/09.
//  Copyright 2009 Anthony Mittaz. All rights reserved.
//

#import "CoreDataDefaultOperation.h"


@implementation CoreDataDefaultOperation

@synthesize persistentStoreCoordinator;
@synthesize managedObjectID=_managedObjectID;

- (void)main {
	if ([self isCancelled]) {
		[self failOperationWithErrorString:OperationCanceledError];
		return;  // user cancelled this operation
	}
	
	[self startOperation];
	
	NSData *responseData = [self downloadUrl];
	
	if (self.timedOut) {
		[self failOperationWithErrorString:TimeoutContentParserError];
	} else if ([responseData length] != 0)  {
		if (![self isCancelled]) {
            [self handleResponse:responseData];
			
			if (self.hadFoundAtLeastOneItem) {
				[self finishOperationWithObject:nil];
			} else {
				[self failOperationWithErrorString:EmptyContentParserError];
			}
			
			[self saveContextAndHandleErrors];
		}
	} else {
		[self failOperationWithErrorString:EmptyContentParserError];
	}
}



#pragma mark -
#pragma mark Core Data Helper

- (NSManagedObject *)object
{
	if (!_object) {
		_object = nil;
		if (self.managedObjectID) {
			_object = [self.managedObjectContext existingObjectWithID:self.managedObjectID error:nil];
		}
	}
	return _object;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
		managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    }
    return managedObjectContext;
}

- (BOOL)saveContextAndHandleErrors 
{
	BOOL success = YES;
	
	if ([self.managedObjectContext hasChanges]) {
		for (id object in [self.managedObjectContext updatedObjects]) {
			if (![[object changedValues] count]) {
				[self.managedObjectContext refreshObject: object
					   mergeChanges: NO];
			}
		}
		
		NSError* error = nil;
		if(![self.managedObjectContext save:&error]) {
			success = NO;
			DLog(@"Failed to save to data store: %@", [error localizedDescription]);
			NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
			if(detailedErrors != nil && [detailedErrors count] > 0) {
				for(NSError* detailedError in detailedErrors) {
					DLog(@"  DetailedError: %@", [detailedError userInfo]);
				}
			}
			else {
				DLog(@"  %@", [error userInfo]);
			}
		} 
	}
	
	return success;  
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	[_managedObjectID release];
	[_databaseName release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];

	[super dealloc];
}


@end

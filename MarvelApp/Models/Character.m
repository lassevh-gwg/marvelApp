//
//  Character.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "Character.h"

@implementation Character

@dynamic name;
@dynamic charID;
@dynamic innerID;
@dynamic charDescription;
@dynamic thumbnailImageData;
@dynamic thumbnailURLString;

#pragma mark - Class Methods

// Gets count for all saved CoreData "Character" objects.
+ (NSInteger)allCharsCountWithContext:(NSManagedObjectContext *)managedObjectContext
{
	NSUInteger retVal;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSError *err;
	retVal = [managedObjectContext countForFetchRequest:request error:&err];

	if (err)
		NSLog(@"Error: %@", [err localizedDescription]);

	return retVal;
}

// Returns a "Character" CoreData object for specified innerID attribute.
+ (Character *)charWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)charInnerID
{
	Character *retVal = nil;

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Character" inManagedObjectContext:context];
	[request setEntity:entity];
	NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"innerID = %d", charInnerID];
	[request setPredicate:searchFilter];

	NSError *err;
	NSArray *results = [context executeFetchRequest:request error:&err];
	if (results.count > 0)
		retVal = [results objectAtIndex:0];

	if (err)
		NSLog(@"Error: %@", [err localizedDescription]);

	return retVal;
}

#pragma mark - Getters & Setters

- (void)setThumbnailDictionary:(NSDictionary *)dict
{
	if (!dict)
		return;

	_thumbnailDictionary = dict;
    NSString *urlString = [NSString stringWithFormat:@"%@.%@", _thumbnailDictionary[@"path"], _thumbnailDictionary[@"extension"]];
    //change it to https to comply with ATS
    urlString = [urlString stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
    self.thumbnailURLString = urlString;
}

- (NSDictionary *)thumbnailDictionary
{
	return _thumbnailDictionary;
}

@end

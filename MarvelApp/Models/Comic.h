//
//  Comic.h
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Comic : NSManagedObject
{
	NSDictionary *_thumbnailDictionary;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *comicID;
@property (nonatomic, retain) NSNumber *innerID;
@property (nonatomic, retain) NSString *comicDescription;
@property (nonatomic, retain) NSData *thumbnailImageData;
@property (nonatomic, retain) NSString *thumbnailURLString;

@property NSDictionary *thumbnailDictionary;

+ (NSInteger)allComicsCountWithContext:(NSManagedObjectContext *)managedObjectContext;
+ (Comic *)comicWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)comicInnerID;

@end

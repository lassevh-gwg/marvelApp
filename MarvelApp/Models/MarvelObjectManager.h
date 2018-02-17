//
//  MarvelObjectManager.h
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MarvelObjectManager : NSObject

- (NSManagedObjectContext *)managedObjectContext;

- (void)getMarvelObjectsAtPath:(NSString *)path
                    parameters:(NSDictionary *)params
                       success:(void (^) (RKObjectRequestOperation * operation, RKMappingResult * mappingResult)) success
                       failure:(void (^) (RKObjectRequestOperation * operation, NSError * error))failure;

- (void)addMappingForEntityForName:(NSString *)entityName
andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
       andIdentificationAttributes:(NSArray *)ids
                    andPathPattern:(NSString *)pathPattern;

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;
+ (MarvelObjectManager *)manager;

- (void)saveToStore;

@end

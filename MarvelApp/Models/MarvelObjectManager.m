//
//  MarvelObjectManager.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "MarvelObjectManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MarvelObjectManager
{
    RKObjectManager *objectManager;
    RKManagedObjectStore *managedObjectStore;
}

#pragma mark - Public Methods

- (NSManagedObjectContext *)managedObjectContext
{
    return managedObjectStore.mainQueueManagedObjectContext;
}

- (void)getMarvelObjectsAtPath:(NSString *)path
                    parameters:(NSDictionary *)params
                       success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeStampString = [formatter stringFromDate:[NSDate date]];
    NSString *hash = [NSString stringWithFormat:@"%@%@%@", timeStampString, MARVEL_PRIVATE_KEY, MARVEL_PUBLIC_KEY];
    hash = [self MD5StringFromString:hash];
    
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithDictionary:@{@"apikey" : MARVEL_PUBLIC_KEY,
                                                                                       @"ts" : timeStampString,
                                                                                       @"hash" : hash}];
    if (params)
    [queryParams addEntriesFromDictionary:params];
    
    // Starts RKObjectRequestOperation with certain parameters.
    [objectManager getObjectsAtPath:[NSString stringWithFormat:@"%@%@", MARVEL_API_PATH_PATTERN, path]
                         parameters:queryParams
                            success:success
                            failure:failure];
}

- (void)addMappingForEntityForName:(NSString *)entityName
andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
       andIdentificationAttributes:(NSArray *)ids
                    andPathPattern:(NSString *)pathPattern
{
    if (!managedObjectStore)
    return;
    
    // Create mapping for the particular entity.
    RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:entityName
                                                         inManagedObjectStore:managedObjectStore];
    [objectMapping addAttributeMappingsFromDictionary:attributeMappings];
    objectMapping.identificationAttributes = ids;
    
    
    // Register mappings with the provider using a response descriptor.
    RKResponseDescriptor *characterResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:objectMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:[NSString stringWithFormat:@"%@%@", MARVEL_API_PATH_PATTERN, pathPattern]
                                                keyPath:@"data.results"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:characterResponseDescriptor];
}

- (void)configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    NSAssert(managedObjectModel, @"managedObjectModel can't be nil");
    
    // Initialize CoreData store & contexts.
    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    if (!RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error))
    NSLog(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RKMarvel.sqlite"];
    if (![managedObjectStore addSQLitePersistentStoreAtPath:path
                                     fromSeedDatabaseAtPath:nil
                                          withConfiguration:nil options:nil error:&error])
    NSLog(@"Failed adding persistent store at path '%@': %@", path, error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Link RestKit the generated object store with RestKit's object manager.
    objectManager.managedObjectStore = managedObjectStore;
}

#pragma mark - Singleton Accessor

+ (MarvelObjectManager *)manager
{
    static MarvelObjectManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[MarvelObjectManager alloc] init];
    });
    return manager;
}

#pragma mark - NSObject-derived

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialize AFNetworking HTTPClient.
        NSURL *baseURL = [NSURL URLWithString:MARVEL_API_BASEPOINT];
        AFRKHTTPClient *client = [[AFRKHTTPClient alloc] initWithBaseURL:baseURL];
        
        // Initialize RestKit's object manager.
        objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    }
    
    return self;
}

#pragma mark - MD5 creation
- (NSString *)MD5StringFromString: (NSString*)stringToConvert
{
    const char *str = [stringToConvert UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *retVal = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [retVal appendFormat:@"%02x", result[i]];
    
    return retVal;
}

@end

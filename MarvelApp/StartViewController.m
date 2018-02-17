//
//  StartViewController.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "StartViewController.h"
#import "MarvelObjectManager.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure CoreData managed object model.
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MarvelApp" withExtension:@"momd"];
    [[MarvelObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    // Add mapping between the "Character" CoreData entity and the "Character" class. Specify the mapping between entity attributes and class properties.
    [[MarvelObjectManager manager] addMappingForEntityForName:@"Character"
                               andAttributeMappingsFromDictionary:@{
                                                                    @"name" : @"name",
                                                                    @"id" : @"charID",
                                                                    @"thumbnail" : @"thumbnailDictionary",
                                                                    @"description" : @"charDescription"
                                                                    }
                                      andIdentificationAttributes:@[@"charID"]
                                                   andPathPattern:MARVEL_API_CHARACTERS_PATH_PATTERN];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

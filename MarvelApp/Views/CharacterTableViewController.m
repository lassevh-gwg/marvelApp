//
//  CharacterTableViewController.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "CharacterTableViewController.h"
#import "Character.h"
#import "MarvelObjectManager.h"
#import "CharacterDetailViewController.h"

@interface CharacterTableViewController ()
{
    NSInteger _numberOfCharacters;
}

@end

@implementation CharacterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreCharacters
{
    _numberOfCharacters = [Character allCharsCountWithContext:[[MarvelObjectManager manager] managedObjectContext]];
    
    // Get an array of remote "character" objects. Specify the offset.
    [[MarvelObjectManager manager] getMarvelObjectsAtPath:MARVEL_API_CHARACTERS_PATH_PATTERN
                                                   parameters:@{@"offset" : @(_numberOfCharacters)}
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          // Characters loaded successfully.
                                                          
                                                          NSInteger newInnerID = _numberOfCharacters;
                                                          
                                                          for (Character * curCharacter in mappingResult.array)
                                                          {
                                                              if ([curCharacter isKindOfClass:[Character class]])
                                                              {
                                                                  curCharacter.innerID = @(newInnerID);
                                                                  newInnerID++;
                                                              }
                                                          }
                                                          
                                                          //persist
                                                          [[MarvelObjectManager manager] saveToStore];
                                                          
                                                          _numberOfCharacters = newInnerID;
                                                          [self.tableView reloadData];
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          // Failed to load characters.
                                                          NSLog(@"fetching characters failed: %@", operation.error.localizedDescription);
                                                      }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfCharacters;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuableCharacterCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}




#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Create the next view controller.
    CharacterDetailViewController *detailViewController = [[CharacterDetailViewController alloc] initWithNibName:@"CharacterDetailViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    Character *curCharacter = [Character charWithManagedObjectContext:[[MarvelObjectManager manager] managedObjectContext]
                                                           andInnerID:indexPath.row];
    [detailViewController setCharacter:curCharacter];
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

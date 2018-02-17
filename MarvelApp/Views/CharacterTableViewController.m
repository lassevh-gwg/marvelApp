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
    BOOL _noMoreCharacters;
    BOOL _isLoading;
    NSMutableSet *_indexpathsLoading;
}

@end

@implementation CharacterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _numberOfCharacters = [Character allCharsCountWithContext:[[MarvelObjectManager manager] managedObjectContext]];
    
    if(_numberOfCharacters == 0){
        [self loadMoreCharacters];
    }
    
    _indexpathsLoading = [NSMutableSet new];
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
    if(_noMoreCharacters)
        return;
    
    // Get an array of remote "character" objects. Specify the offset.
    [[MarvelObjectManager manager] getMarvelObjectsAtPath:MARVEL_API_CHARACTERS_PATH_PATTERN
                                                   parameters:@{@"offset" : @(_numberOfCharacters),
                                                                @"limit" : @(40),
                                                                }
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          // Characters loaded successfully.
                                                          
                                                          if(mappingResult.array.count == 0){
                                                              //no more characters to load
                                                              _noMoreCharacters = YES;
                                                              return;
                                                          }
                                                          
                                                          NSInteger newInnerID = _numberOfCharacters;
                                                          NSMutableArray *indexPathsToInsert = [NSMutableArray new];
                                                          
                                                          for (Character * curCharacter in mappingResult.array)
                                                          {
                                                              if ([curCharacter isKindOfClass:[Character class]])
                                                              {
                                                                  curCharacter.innerID = @(newInnerID);
                                                                  [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:newInnerID inSection:0]];
                                                                  newInnerID++;
                                                              }
                                                          }
                                                          
                                                          //persist
                                                          [[MarvelObjectManager manager] saveToStore];
                                                          
                                                          _numberOfCharacters = newInnerID;
                                                          [self.tableView beginUpdates];
                                                          [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationRight];
                                                          [self.tableView endUpdates];
                                                          
                                                          _isLoading = NO;
                                                          
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          // Failed to load characters.
                                                          NSLog(@"fetching characters failed: %@", operation.error.localizedDescription);
                                                      }];
}

- (void)loadThumbnailAtIndexPath:(NSIndexPath*)indexPath fromURLString:(NSString *)urlString forCharacter:(Character *)character
{
    // Download image for selected character.
    AFRKHTTPRequestOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [operation setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        // Image downloaded successfully.
        character.thumbnailImageData = responseObject;
        [[MarvelObjectManager manager] saveToStore];
       
        if([self.tableView.indexPathsForVisibleRows containsObject:indexPath] ){
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }

    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        // Image download failure.
        NSLog(@"image download failed: %@", [error localizedDescription]);
    }];
    [operation start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfCharacters;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuableCharacterCell"];
    UIImageView *imageView = [cell viewWithTag:100];
    UILabel *nameLabel = [cell viewWithTag:200];
    
    //clear content
    imageView.image = nil;
    nameLabel.text = @"";
    
    //load more characters if it's the last cell
    if(indexPath.row == _numberOfCharacters-1 && !_isLoading && !_noMoreCharacters){
        _isLoading = YES;
        [self loadMoreCharacters];
    }
    
    Character *character = [Character charWithManagedObjectContext:[[MarvelObjectManager manager] managedObjectContext]
                                                           andInnerID:indexPath.row];

    if (character.thumbnailImageData)
        [imageView setImage:[UIImage imageWithData:character.thumbnailImageData]];
    else if (![_indexpathsLoading containsObject:indexPath]){
        [_indexpathsLoading addObject:indexPath];
        [self loadThumbnailAtIndexPath:indexPath fromURLString:character.thumbnailURLString forCharacter:character];
    }
    
    nameLabel.text = character.name;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Create the next view controller.
    CharacterDetailViewController *detailViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    Character *curCharacter = [Character charWithManagedObjectContext:[[MarvelObjectManager manager] managedObjectContext]
                                                           andInnerID:self.tableView.indexPathForSelectedRow.row];
    [detailViewController setCharacter:curCharacter];
    
//    // Push the view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end

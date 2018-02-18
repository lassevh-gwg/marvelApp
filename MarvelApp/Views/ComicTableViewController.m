//
//  ComicTableViewController.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "ComicTableViewController.h"
#import "Comic.h"
#import "MarvelObjectManager.h"
#import "ComicDetailViewController.h"

@interface ComicTableViewController ()
{
    NSInteger _numberOfComics;
    BOOL _noMoreComics;
    BOOL _isLoading;
    NSMutableSet *_indexpathsLoading;
}

@end

@implementation ComicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _numberOfComics = [Comic allComicsCountWithContext:[[MarvelObjectManager manager] managedObjectContext]];
    
    if(_numberOfComics == 0){
        [self loadMoreComics];
    }
    
    _indexpathsLoading = [NSMutableSet new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMoreComics
{
    if(_noMoreComics)
        return;
    
    _isLoading = YES;
    
    // Get an array of remote "comic" objects. Specify the offset.
    [[MarvelObjectManager manager] getMarvelObjectsAtPath:MARVEL_API_COMICS_PATH_PATTERN
                                                   parameters:@{@"offset" : @(_numberOfComics),
                                                                @"limit" : @(20),
                                                                }
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          // Comics loaded successfully.
                                                          
                                                          if(mappingResult.array.count == 0){
                                                              //no more comics to load
                                                              _noMoreComics = YES;
                                                              return;
                                                          }
                                                          
                                                          NSInteger newInnerID = _numberOfComics;
                                                          NSMutableArray *indexPathsToInsert = [NSMutableArray new];
                                                          
                                                          for (Comic * curComic in mappingResult.array)
                                                          {
                                                              if ([curComic isKindOfClass:[Comic class]])
                                                              {
                                                                  curComic.innerID = @(newInnerID);
                                                                  [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:newInnerID inSection:0]];
                                                                  newInnerID++;
                                                              }
                                                          }
                                                          
                                                          //persist
                                                          [[MarvelObjectManager manager] saveToStore];
                                                          
                                                          _numberOfComics = newInnerID;
                                                          [self.tableView beginUpdates];
                                                          [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
                                                          [self.tableView endUpdates];
                                                          
                                                          _isLoading = NO;
                                                          
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          // Failed to load comics.
                                                          NSLog(@"fetching comics failed: %@", operation.error.localizedDescription);
                                                      }];
}

- (void)loadThumbnailAtIndexPath:(NSIndexPath*)indexPath fromURLString:(NSString *)urlString forComic:(Comic *)comic
{
    // Download image for selected comic.
    AFRKHTTPRequestOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [operation setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        // Image downloaded successfully.
        comic.thumbnailImageData = responseObject;
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
    return _numberOfComics;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseableComicCell"];
    UIImageView *imageView = [cell viewWithTag:100];
    UILabel *nameLabel = [cell viewWithTag:200];
    
    //clear content
    imageView.image = nil;
    nameLabel.text = @"";
    
    //load more comics if it's the last cell
    if(indexPath.row == _numberOfComics-1 && !_isLoading && !_noMoreComics){
        [self loadMoreComics];
    }
    
    Comic *comic = [Comic comicWithManagedObjectContext:[[MarvelObjectManager manager] managedObjectContext]
                                                           andInnerID:indexPath.row];

    if (comic.thumbnailImageData)
        [imageView setImage:[UIImage imageWithData:comic.thumbnailImageData]];
    else if (![_indexpathsLoading containsObject:indexPath]){
        [_indexpathsLoading addObject:indexPath];
        [self loadThumbnailAtIndexPath:indexPath fromURLString:comic.thumbnailURLString forComic:comic];
    }
    
    nameLabel.text = comic.title;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Create the next view controller.
    ComicDetailViewController *detailViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    Comic *curComic = [Comic comicWithManagedObjectContext:[[MarvelObjectManager manager] managedObjectContext]
                                                           andInnerID:self.tableView.indexPathForSelectedRow.row];
    [detailViewController setComic:curComic];
    
}


@end

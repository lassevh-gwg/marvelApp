//
//  ComicDetailViewController.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "ComicDetailViewController.h"

@interface ComicDetailViewController ()

@end

@implementation ComicDetailViewController


- (void)configureView {
    // Update the user interface for the detail item.
    if (self.comic) {
        [self.comicImageView setImage:[UIImage imageWithData:self.comic.thumbnailImageData]];
        if(self.comic.comicDescription.length >0)
            self.comicDescriptionTextView.text = self.comic.comicDescription;
        else{
            self.comicDescriptionTextView.text = NSLocalizedString(@"No description available", nil);
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setcomic:(Comic *)newcomic {
    if (_comic != newcomic) {
        _comic = newcomic;
        
        // Update the view.
        [self configureView];
    }
}
@end

//
//  CharacterDetailViewController.m
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import "CharacterDetailViewController.h"

@interface CharacterDetailViewController ()

@end

@implementation CharacterDetailViewController


- (void)configureView {
    // Update the user interface for the detail item.
    if (self.character) {
        [self.characterImageView setImage:[UIImage imageWithData:self.character.thumbnailImageData]];
        if(self.character.charDescription.length >0)
            self.characterDescriptionTextView.text = self.character.charDescription;
        else{
            self.characterDescriptionTextView.text = NSLocalizedString(@"No description available", nil);
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

- (void)setCharacter:(Character *)newCharacter {
    if (_character != newCharacter) {
        _character = newCharacter;
        
        // Update the view.
        [self configureView];
    }
}
@end

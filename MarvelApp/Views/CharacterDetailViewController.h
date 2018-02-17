//
//  CharacterDetailViewController.h
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Character.h"

@interface CharacterDetailViewController : UIViewController

@property (strong, nonatomic) Character *character;
@property (weak, nonatomic) IBOutlet UIImageView *characterImageView;
@property (weak, nonatomic) IBOutlet UITextView *characterDescriptionTextView;

@end

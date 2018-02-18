//
//  ComicDetailViewController.h
//  MarvelApp
//
//  Created by Lasse V. Hansen on 17/02/2018.
//  Copyright © 2018 Lasse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"

@interface ComicDetailViewController : UIViewController

@property (strong, nonatomic) Comic *comic;
@property (weak, nonatomic) IBOutlet UIImageView *comicImageView;
@property (weak, nonatomic) IBOutlet UITextView *comicDescriptionTextView;

@end

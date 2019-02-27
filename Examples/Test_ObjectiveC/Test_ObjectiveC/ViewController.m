//
//  ViewController.m
//  Test_ObjectiveC
//
//  Created by Antonio García on 29/01/2019.
//  Copyright © 2019 OpenRoad. All rights reserved.
//

#import "ViewController.h"
@import AppStoreRatings;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update AppStoreRatings status
    NSURL *url = [NSURL URLWithString:@"https://www.openroad.es/projects/appstoreratings/test/ratings_config.json"];
    [AppStoreRatings.shared updateRatingStatsWithConfigUrl:url completion:^(BOOL isDialogRequested, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"Finished: isDialogRequested %@", isDialogRequested ? @"yes":@"no");
        }
        else {
            NSLog(@"error %@", error.localizedDescription);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    // Debug internal status
#ifdef DEBUG
    NSLog(@"%@", [AppStoreRatings.shared currentStatusDescription]);
    
    [AppStoreRatings.shared debugCurrentStatusWithConfigURL:url completion:^(BOOL isDialogRequested, NSInteger launchCountsRemaining, double daysRemaining, BOOL wasPreviouslyRequested, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@", error.localizedDescription);
        }
        else {
            NSLog(@"isDialogRequested %@", isDialogRequested ? @"yes":@"no");
            NSLog(@"wasPreviouslyRequested %@", wasPreviouslyRequested ? @"yes":@"no");
            NSLog(@"launchCountsRemaining %ld",launchCountsRemaining);
            NSLog(@"daysRemaining %@", [NSString stringWithFormat:@"%.3f", daysRemaining] );
        }
    }];
    
#endif
}


@end

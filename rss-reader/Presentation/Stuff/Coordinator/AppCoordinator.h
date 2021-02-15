//
//  AppCoordinator.h
//  rss-reader
//
//  Created by Uladzislau Volchyk on 10.02.21.
//

#import <Foundation/Foundation.h>
#import "PresentationFactoryType.h"
#import "CoordinatorType.h"
#import "UVNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UVAppCoordinator : NSObject <CoordinatorType>

- (instancetype)initWithPresentationFactory:(id<PresentationFactoryType>)factory;

- (void)setRootNavigationController:(UVNavigationController *)controller;

@end

NS_ASSUME_NONNULL_END

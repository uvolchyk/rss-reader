//
//  AppDelegate.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "AppDelegate.h"
#import "FeedXMLParser.h"
#import "FeedPresenter.h"
#import "FeedViewController.h"
#import "UVSourceManager.h"
#import "UVSourceManager.h"
#import "UVDataRecognizer.h"
#import "UVSearchViewController.h"
#import "UVSourcesListViewController.h"
#import "UVSourcesListPresenter.h"
#import "KeyConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppearance];
    [NSNotificationCenter.defaultCenter addObserver:UVSourceManager.defaultManager
                                           selector:@selector(saveState:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    [NSUserDefaults.standardUserDefaults setObject:kSourcesFileNameValue forKey:kSourcesFileNameKey];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [NSNotificationCenter.defaultCenter removeObserver:UVSourceManager.defaultManager];
}

// MARK: -

- (void)setupAppearance {
    UVDataRecognizer *recognizer = [[UVDataRecognizer new] autorelease];
    FeedPresenter *presenter = [[FeedPresenter alloc] initWithRecognizer:recognizer
                                                           sourceManager:UVSourceManager.defaultManager];
    FeedViewController *controller = [[FeedViewController alloc] initWithPresenter:[presenter autorelease]];
    presenter.view = controller;
    
    [controller setupOnRighButtonClickAction:^{
        UVSourcesListPresenter *presenter = [[UVSourcesListPresenter alloc] initWithSource:UVSourceManager.defaultManager
                                                                                recognizer:recognizer];
        UVSourcesListViewController *presentedController = [[UVSourcesListViewController alloc] initWithPresenter:[presenter autorelease]];
        presenter.view = [presentedController autorelease];
        [controller.navigationController pushViewController:presentedController animated:YES];
    }];
    
    
    self.window.rootViewController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self.window makeKeyAndVisible];
    
    [controller release];
}

// MARK: Lazy

- (UIWindow *)window {
    if(!_window) {
        _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _window;
}

// MARK: -

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end

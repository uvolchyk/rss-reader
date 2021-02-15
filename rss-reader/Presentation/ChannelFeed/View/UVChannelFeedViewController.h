//
//  FeedViewController.h
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import <UIKit/UIKit.h>
#import "UVChannelFeedViewType.h"
#import "UVChannelFeedPresenterType.h"
#import "UVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UVChannelFeedViewController : UVBaseViewController <UVChannelFeedViewType>

@property (nonatomic, strong) id<UVChannelFeedPresenterType> presenter;

- (void)setupOnRighButtonClickAction:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END

//
//  UVSourcesListPresenter.h
//  rss-reader
//
//  Created by Uladzislau Volchyk on 20.12.20.
//

#import <UIKit/UIKit.h>
#import "UVBasePresenter.h"
#import "UVSourcesListPresenterType.h"
#import "UVSourcesListViewType.h"

NS_ASSUME_NONNULL_BEGIN

@interface UVSourcesListPresenter : UVBasePresenter <UVSourcesListPresenterType>

@property (nonatomic, assign) UIViewController<UVSourcesListViewType> *viewDelegate;

@end

NS_ASSUME_NONNULL_END

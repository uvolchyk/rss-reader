//
//  FeedViewController.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "UVFeedViewController.h"
#import "UVFeedTableViewCell.h"
#import "UVFeedChannelDisplayModel.h"

#import "UIViewController+ErrorPresenter.h"
#import "UVFeedItemWebViewController.h"

static CGFloat const kFadeAnimationDuration = 0.1;

@interface UVFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) UIViewController<UVFeedItemWebViewType> *webView;

@property (nonatomic, retain) id<UVFeedChannelDisplayModel> channel;

@end

@implementation UVFeedViewController

- (void)dealloc
{
    [_webView release];
    [_channel release];
    [_presenter release];
    [_tableView release];
    [_refreshControl release];
    [_activityIndicator release];
    [_refreshControl release];
    [super dealloc];
}

// MARK: -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
    [self.presenter updateFeed];
}

- (void)setupLayout {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.activityIndicator];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

// MARK: - Lazy Properties

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.refreshControl = self.refreshControl;
        _tableView.tableFooterView = [[UIView new] autorelease];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [_tableView registerClass:UVFeedTableViewCell.class forCellReuseIdentifier:UVFeedTableViewCell.cellIdentifier];
    }
    return _tableView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if(!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = self.view.center;
    }
    return _activityIndicator;
}

- (UIRefreshControl *)refreshControl {
    if(!_refreshControl) {
        _refreshControl = [UIRefreshControl new];
        [_refreshControl addTarget:self.presenter action:@selector(updateFeed) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (id<UVFeedItemWebViewType>)webView {
    if(!_webView) {
        _webView = [UVFeedItemWebViewController new];
    }
    return _webView;
}

// MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UVFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UVFeedTableViewCell.cellIdentifier forIndexPath:indexPath];
    [cell setupWithModel:self.channel.channelItems[indexPath.row] reloadCompletion:^ {
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        [tableView beginUpdates];
        if (!CGRectContainsRect(tableView.bounds, cellRect)) {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];
    cell.alpha = 0;
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        cell.alpha = 1;
    }];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channel.channelItems.count;
}

// MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.presenter openArticleAt:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.channel.channelItems[indexPath.row].frame.size.height;
}

// MARK: - FeedViewType

- (void)updatePresentationWithChannel:(id<UVFeedChannelDisplayModel>)channel {
    self.channel = channel;
    [self.tableView reloadData];
    self.navigationItem.title = [self.channel channelTitle];
    [self.refreshControl endRefreshing];
}

- (void)rotateActivityIndicator:(BOOL)show {
    if (show) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)presentError:(NSError *)error {
    [self showError:error];
}

- (void)presentWebPageOnURL:(NSURL *)url {
    [self.webView openURL:url];
    [self.navigationController pushViewController:self.webView animated:YES];
}

@end

//
//  FeedViewController.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "UVChannelFeedViewController.h"
#import "UVFeedTableViewCell.h"
#import "UVChannelFeedPresenterType.h"
#import "UVFeedItemWebViewController.h"

#import "UIViewController+Util.h"
#import "UIBarButtonItem+PrettiInitializable.h"

static CGFloat const FADE_ANIMATION_DURATION    = 0.1;
static NSInteger const REFRESH_ENDING_DELAY     = 1;

@interface UVChannelFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;
@property (nonatomic, strong) UIViewController<UVFeedItemWebViewType> *webView;

@property (nonatomic, copy) void(^rightButtonClickAction)(void);

@end

@implementation UVChannelFeedViewController

// MARK: -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.presenter updateFeed];
}

- (void)setupLayout {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.activityIndicator];
    
    self.navigationItem.rightBarButtonItem = self.settingsButton;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self.presenter updateFeed];
    }
}

// MARK: -

- (void)setupOnRighButtonClickAction:(void(^)(void))completion {
    self.rightButtonClickAction = completion;
}

// MARK: - Lazy Properties

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.refreshControl = self.refreshControl;
        _tableView.tableFooterView = [UIView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [_tableView registerClass:UVFeedTableViewCell.class forCellReuseIdentifier:UVFeedTableViewCell.cellIdentifier];
    }
    return _tableView;
}

- (UIBarButtonItem *)settingsButton {
    if(!_settingsButton) {
        _settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(settingsButtonClick)];
    }
    return _settingsButton;
}

- (void)settingsButtonClick {
    self.rightButtonClickAction();
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
        [_refreshControl addTarget:self.presenter action:@selector(updateFeed)
                  forControlEvents:UIControlEventValueChanged];
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
    [cell setupWithModel:self.presenter.channel.channelItems[indexPath.row] reloadCompletion:^ {
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        [tableView beginUpdates];
        if (!CGRectContainsRect(tableView.bounds, cellRect)) {
            [tableView scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:YES];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];
    
    cell.alpha = 0;
    [UIView animateWithDuration:FADE_ANIMATION_DURATION animations:^{
        cell.alpha = 1;
    }];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presenter.channel.channelItems.count;
}

// MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.presenter openArticleAt:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.presenter.channel.channelItems[indexPath.row].frame.size.height;
}

// MARK: - UVChannelFeedViewType

- (void)updatePresentation {
    [self hidePlaceholderMessage];
    [self.tableView reloadData];
    self.navigationItem.title = [self.presenter.channel channelTitle];
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
    if (self.refreshControl.isRefreshing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(REFRESH_ENDING_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }
    [self showError:error];
}

- (void)presentWebPageOnURL:(NSURL *)url {
    [self.webView openURL:url];
    [self.navigationController pushViewController:self.webView animated:YES];
}

- (void)clearState {
    [self showPlaceholderMessage:NSLocalizedString(NO_CONTENTS_MESSAGE, "")];
    self.navigationItem.title = nil;
    [self.tableView reloadData];
}

@end
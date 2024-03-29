//
//  UVSourceSearchViewController.m
//  rss-reader
//
//  Created by Uladzislau Volchyk on 18.12.20.
//

#import "UVSearchViewController.h"
#import "UIViewController+Util.h"
#import "LocalConstants.h"

@interface UVSearchViewController () <UISearchBarDelegate>

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation UVSearchViewController

- (void)dealloc
{
    [_searchBar release];
    [_tableView release];
    [super dealloc];
}

// MARK: - Lazy

- (UISearchBar *)searchBar {
    if(!_searchBar) {
        _searchBar = [UISearchBar new];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(SEARCH_RSS_SOURCE_PLACEHOLDER, "");
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

// MARK: -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}

// MARK: -

- (void)setupAppearance {
    [self layoutTableView];
    self.navigationItem.titleView = self.searchBar;
}

- (void)layoutTableView {
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

// MARK: - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.delegate searchAcceptedWithKey:searchBar.text];
}

@end

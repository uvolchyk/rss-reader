//
//  UVNetworkMock.h
//  rss-readerTests
//
//  Created by Uladzislau Volchyk on 2.01.21.
//

#import "UVNetwork.h"
#import "UVNetworkType.h"

NS_ASSUME_NONNULL_BEGIN

@interface UVNetworkMock : NSObject <UVNetworkType>

@property (nonatomic, assign) BOOL isCalled;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSError *validationError;
@property (nonatomic, retain) NSError *requestError;
@property (nonatomic, retain) NSURL *url;

@end

NS_ASSUME_NONNULL_END

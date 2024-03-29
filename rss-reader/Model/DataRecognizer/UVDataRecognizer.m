//
//  UVDataRecognizer.m
//  rss-reader
//
//  Created by Uladzislau Volchyk on 7.12.20.
//

#import "UVDataRecognizer.h"
#import "UVRSSLinkXMLParser.h"
#import "UVErrorDomain.h"

#import "NSString+Util.h"
#import "NSArray+Util.h"

#import "UVRSSLinkKeys.h"

static NSString *const LINK_TAG_PATTERN     = @"<link[^>]+type=\"application[/]rss[+]xml\".*>";
static NSString *const HREF_ATTR_PATTERN    = @"(?<=\\bhref=\")[^\"]*";
static NSString *const TITLE_ATTR_PATTERN   = @"(?<=\\btitle=\")[^\"]*";
static NSString *const RSS_TAG_PATTERN      = @"<rss.*version=\"\\d.\\d\"";
static NSString *const HTML_TAG_PATTERN     = @"<html.*";

static NSString *const EMPTY_STRING         = @"";

@interface UVDataRecognizer ()

@property (nonatomic, retain, readonly) id<UVRSSLinkXMLParserType> linkXMLParser;

@end

@implementation UVDataRecognizer

// MARK: - UVDataRecognizerType

- (void)discoverChannel:(NSData *)data
                 parser:(id<UVFeedParserType>)parser
             completion:(void (^)(NSDictionary *, NSError *))completion {
    if (!data || !parser) {
        if (completion) completion(nil, [self recognitionError]);
        return;
    }
    
    [parser retain];
    [parser parseData:data completion:^(NSDictionary *result, NSError *error) {
        if (completion) completion(result, error);
    }];
    [parser release];
}

- (void)discoverLinksFromHTML:(NSData *)data
                   completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (!data) {
        if (completion) completion(nil, [self recognitionError]);
        return;
    }
    
    NSString *content = [NSString htmlStringFromData:data];
    
    if (!content || !content.length || [content isEqualToString:EMPTY_STRING]) {
        if (completion) completion(nil, [self recognitionError]);
        return;
    }
    
    NSMutableArray<NSDictionary *> *links = [self findLinks:content];
    
    if (!links.count || !links) {
        if (completion) completion(nil, [self recognitionError]);
        return;
    }
    
    if (completion) completion([[links copy] autorelease], nil);
    return;
}

- (void)discoverLinksFromXML:(NSData *)data
                         url:(NSURL *)url
                  completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (!data || !url) {
        if (completion) completion(nil, [self recognitionError]);
        return;
    }
    
    [self.linkXMLParser parseData:data completion:^(NSDictionary *link, NSError *error) {
        if (link && !error) {
            NSMutableDictionary *mLink = [[link mutableCopy] autorelease];
            mLink[kRSSLinkURL] = url.absoluteString;
            if (completion) completion(@[[[mLink copy] autorelease]], nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)discoverContentType:(NSData *)data
                 completion:(void (^)(UVRawContentType, NSError *))completion {
    if (!data) {
        if (completion) completion(UVRawContentUndefined, [self recognitionError]);
        return;
    }
    
    NSString *content = [NSString htmlStringFromData:data];
    
    if (!content || !content.length || [content isEqualToString:EMPTY_STRING]) {
        if (completion) completion(UVRawContentUndefined, [self recognitionError]);
        return;
    }
    
    if ([self isRSS:content]) {
        if (completion) completion(UVRawContentXML, nil);
        return;
    }
    
    if ([self isHTML:content]) {
        if (completion) completion(UVRawContentHTML, nil);
        return;
    }
    
    if (completion) completion(UVRawContentUndefined, [self recognitionError]);
}

// MARK: - Private

- (BOOL)isRSS:(NSString *)string {
    return [string rangeOfString:RSS_TAG_PATTERN options:NSRegularExpressionSearch].location != NSNotFound;
}

- (BOOL)isHTML:(NSString *)string {
    return [string rangeOfString:HTML_TAG_PATTERN options:NSRegularExpressionSearch].location != NSNotFound;
}

- (NSMutableArray<NSDictionary *> *)findLinks:(NSString *)html {
    NSMutableArray<NSDictionary *> *results = [NSMutableArray array];
    
    [[self regExpWithPattern:LINK_TAG_PATTERN] enumerateMatchesInString:html
                                                                options:0
                                                                  range:NSMakeRange(0, html.length)
                                                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *linkString = [html substringWithRange:[result range]];
        
        NSRange hrefRange = [linkString rangeOfString:HREF_ATTR_PATTERN options:NSRegularExpressionSearch];
        NSRange titleRange = [linkString rangeOfString:TITLE_ATTR_PATTERN options:NSRegularExpressionSearch];
        
        [results addObject:@{
            kRSSLinkTitle : titleRange.location == NSNotFound ? EMPTY_STRING : [linkString substringWithRange:titleRange],
            kRSSLinkURL : hrefRange.location == NSNotFound ? EMPTY_STRING : [linkString substringWithRange:hrefRange]
        }];
    }];
    
    return results;
}

// MARK: - Private

- (NSError *)recognitionError {
    return [NSError errorWithDomain:UVNullDataErrorDomain code:1000 userInfo:nil];
}

- (NSRegularExpression *)regExpWithPattern:(NSString *)pattern {
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:NSRegularExpressionCaseInsensitive
                                                       error:nil];
}

// MARK: - Lazy

- (id<UVRSSLinkXMLParserType>)linkXMLParser {
    return [[UVRSSLinkXMLParser new] autorelease];
}

@end

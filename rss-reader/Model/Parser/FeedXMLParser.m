//
//  FeedXMLParser.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "FeedXMLParser.h"
#import "FeedChannel.h"
#import "MediaContent.h"
#import "NSXMLParser+DelegateInitializable.h"

@interface FeedXMLParser () <NSXMLParserDelegate>

@property (nonatomic, copy) ParseHandler completion;

// MARK: - Channel
@property (nonatomic, retain) FeedChannel *channel;
@property (nonatomic, retain) NSMutableDictionary *channelDictionary;
@property (nonatomic, retain) NSMutableArray<FeedItem *> *items;

// MARK: - Item
@property (nonatomic, retain) NSMutableDictionary *itemDictionary;
@property (nonatomic, retain) NSMutableString *parsingString;
@property (nonatomic, retain) NSMutableArray<MediaContent *> *mediaContent;

// MARK: - Util
@property (nonatomic, assign) BOOL isItem;
@property (nonatomic, retain) NSXMLParser *parser;

@end

@implementation FeedXMLParser

// MARK: -

- (void)parseFeed:(NSData *)data completion:(ParseHandler)completion {
    self.completion = completion;
    self.parser = [NSXMLParser parserWithData:data delegate:self];
    [self.parser parse];
}

// MARK: - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if(self.completion) {
        self.completion(nil, parseError);
    }
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    if ([elementName isEqualToString:kRSSItem]) {
        self.isItem = YES;
        self.itemDictionary = [NSMutableDictionary dictionary];
        self.mediaContent = [NSMutableArray array];
    }
    
    if([elementName isEqualToString:kRSSItemTitle] ||
       [elementName isEqualToString:kRSSItemLink] ||
       [elementName isEqualToString:kRSSItemCategory] ||
       [elementName isEqualToString:kRSSItemPubDate] ||
       
       [elementName isEqualToString:kRSSChannelTitle] ||
       [elementName isEqualToString:kRSSChannelLink] ||
       [elementName isEqualToString:kRSSChannelDescription]) {
        self.parsingString = [NSMutableString string];
    }
    
    if([elementName isEqualToString:kRSSItemSummary]) {
        self.parsingString = [NSMutableString stringWithFormat:@"%@", attributeDict[@"src"]];
    }
    
    if([elementName isEqualToString:kRSSMediaContent]) {
        MediaContent *content = [MediaContent objectWithDictionary:attributeDict];
        if(content) {
            [self.mediaContent addObject:content];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.parsingString appendString:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    if([elementName isEqualToString:kRSSChannel]) {
        [self.channelDictionary setValue:self.items forKey:kRSSChannelItems];
        FeedChannel *channel = [FeedChannel objectWithDictionary:self.channelDictionary];
        if(channel) {
            self.channel = channel;
        } else {
            [parser abortParsing];
        }
        
        [_channelDictionary release];
        _channelDictionary = nil;
    }
    
    if([elementName isEqualToString:kRSSItemTitle] ||
       [elementName isEqualToString:kRSSItemLink] ||
       [elementName isEqualToString:kRSSItemCategory] ||
       [elementName isEqualToString:kRSSItemPubDate] ||
       
       [elementName isEqualToString:kRSSChannelTitle] ||
       [elementName isEqualToString:kRSSChannelLink] ||
       [elementName isEqualToString:kRSSChannelDescription]) {
        
        if(self.isItem) {
            self.itemDictionary[elementName] = self.parsingString;
        } else {
            self.channelDictionary[elementName] = self.parsingString;
        }
        
        [_parsingString release];
        _parsingString = nil;
    }
    
    if([elementName isEqualToString:kRSSItem]) {
        [self.itemDictionary setValue:self.mediaContent forKey:kRSSMediaContent];
        FeedItem *item = [FeedItem objectWithDictionary:self.itemDictionary];
        if(item) {
            [self.items addObject:item];
        }
        self.isItem = NO;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if(self.completion) {
        self.completion(self.channel, nil);
        [_channel release];
    }
}

// MARK: - Lazy

- (NSMutableArray<FeedItem *> *)items {
    if(!_items) {
        _items = [NSMutableArray new];
    }
    return _items;
}

- (NSMutableDictionary *)channelDictionary {
    if(!_channelDictionary) {
        _channelDictionary = [NSMutableDictionary new];
    }
    return _channelDictionary;
}

- (void)dealloc
{    
    [_items release];
    _items = nil;
    [_parser release];
    _parser = nil;
    [_channel release];
    _channel = nil;
    [_completion release];
    _completion = nil;
    [_mediaContent release];
    _mediaContent = nil;
    [_parsingString release];
    _parsingString = nil;
    [_itemDictionary release];
    _itemDictionary = nil;
    [_channelDictionary release];
    _channelDictionary = nil;
    [super dealloc];
}

@end

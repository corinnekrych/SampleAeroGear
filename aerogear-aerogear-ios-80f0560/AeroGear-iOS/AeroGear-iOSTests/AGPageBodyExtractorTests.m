/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <SenTestingKit/SenTestingKit.h>

#import "AGPageBodyExtractor.h"

@interface AGPageBodyExtractorTests : SenTestCase

@end

static NSString *const NEXT_PAGE_IDENTIFIER     = @"next_page";
static NSString *const PREVIOUS_PAGE_IDENTIFIER = @"previous_page";

@implementation AGPageBodyExtractorTests {
    NSDictionary *_headers;
    NSDictionary *_response;
    
    AGPageBodyExtractor *_extractor;
}

-(void)setUp {
    [super setUp];
    
    // mock up response headers
    _headers = @{@"status"        : @"200 OK",
                 @"cache-control" : @"max-age=15, must-revalidate, max-age=300",
                 @"content-type"  : @"application/json;charset=utf-8"};
    
    
    // mock up 'body' paging response (extracted from twitter)
    _response = @{@"query"         : @"aerogear",
                  @"refresh_url"   : @"?since_id=323898917563543552&q=aerogear",
                  @"next_page"     : @"?page=3&max_id=323898917563543552&q=aerogear&rpp=1",
                  @"previous_page" : @"?page=1&max_id=323898917563543552&q=aerogear&rpp=1"
                  };
    
    // initialize the body extractor
    _extractor = [[AGPageBodyExtractor alloc] init];
}

-(void)tearDown {
    [super tearDown];
}

-(void) testParseQueryInformationWithNil {
    NSDictionary *parsedInfo = [_extractor parse:nil
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"nil passed in");
}

-(void) testParseQueryInformationWithArray {
    NSDictionary *parsedInfo = [_extractor parse:[NSArray array]
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"Array not supported");
}

-(void) testParseQueryInformationWithString {
    id stringVal = @"bogus";
    NSDictionary *parsedInfo = [_extractor parse:stringVal
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"String not supported");
}

-(void) testParseQueryInformationWithEmptyDictionary {
    NSDictionary *parsedInfo = [_extractor parse:[NSDictionary dictionary]
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 0, @"count should be 0");
}

-(void) testParseQueryInformationWithRealLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 2, @"should have previous and next values");
}

-(void) testParseQueryInformationWithBogusNextLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:@"bogus_next"
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 1, @"should have previous values only");
    
    // using internal next key:
    STAssertNil([parsedInfo valueForKey:NEXT_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

-(void) testParseQueryInformationWithBogusPrevLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:@"bogus_prev"];
    
    STAssertTrue(parsedInfo.count == 1, @"should have next values only");
    
    // using internal prev key:
    STAssertNil([parsedInfo valueForKey:PREVIOUS_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

-(void) testParseQueryInformationBogusNextPrevLinks {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:@"bogus_next"
                                            prev:@"bogus_prev"];
    STAssertTrue(parsedInfo.count == 0, @"should have no values");
    
    // using internal next-prev keys:
    STAssertNil([parsedInfo valueForKey:NEXT_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
    STAssertNil([parsedInfo valueForKey:PREVIOUS_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

@end

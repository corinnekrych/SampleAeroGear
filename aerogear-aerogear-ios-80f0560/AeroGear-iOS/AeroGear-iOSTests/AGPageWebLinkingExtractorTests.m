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

#import "AGPageWebLinkingExtractor.h"

@interface AGPageWebLinkingExtractorTests : SenTestCase

@end

static NSString *const NEXT_PAGE_IDENTIFIER     = @"next";
static NSString *const PREVIOUS_PAGE_IDENTIFIER = @"previous";

@implementation AGPageWebLinkingExtractorTests {
    NSDictionary *_headers;
    NSArray      *_response;
    
    AGPageWebLinkingExtractor *_extractor;
}

-(void)setUp {
    [super setUp];
    
    // mock up paging response headers ((extracted from AGController)
    _headers =@{
                @"Link" : @"<http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars?offset=1&color=red&limit=5>; rel=\"previous\",<http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars?offset=11&color=red&limit=5>; rel=\"next\""
                };
    
    // mock up response body
    _response = @[
                  @{@"id":@"1", @"color":@"red", @"type":@"bmv"},
                  @{@"id":@"2", @"color":@"red", @"type":@"seat"}
                  ];
    
    // initialize the body extractor
    _extractor = [[AGPageWebLinkingExtractor alloc] init];
}

-(void)tearDown {
    [super tearDown];
}


-(void) testParseWebLinkInformationWithRealLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 2, @"should have previous and next values");
}

-(void) testParseWebLinkInformationWithBogusPreviousLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:@"bogus_prev"];
    STAssertTrue(parsedInfo.count == 1, @"should have next values only");
}

-(void) testParseWebLinkInformationWithBogusNextLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:@"bogus_next"
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 1, @"should have previous values only");
}

-(void) testParseWebLinkInformationWithBogusNextPrevLinks {
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

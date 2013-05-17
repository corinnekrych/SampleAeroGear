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

#import "AGPageHeaderExtractor.h"

@interface AGPageHeaderExtractorTests : SenTestCase

@end

static NSString *const NEXT_PAGE_IDENTIFIER     = @"AG-Links-Next";
static NSString *const PREVIOUS_PAGE_IDENTIFIER = @"AG-Links-Previous";

@implementation AGPageHeaderExtractorTests {
    NSDictionary *_headers;
    NSArray      *_response;
    
    AGPageHeaderExtractor* _extractor;
}

-(void)setUp {
    [super setUp];
    
    // mock up paging response headers (extracted from AGController)
    _headers =@{
                @"AG-Links-Next" : @"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars-custom?offset=11&color=red&limit=5",
                @"AG-Links-Previous" : @"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo/cars-custom?offset=1&color=red&limit=5"
                };
    
    // mock up response body
    _response = @[
                  @{@"id":@"1", @"color":@"red", @"type":@"bmv"},
                  @{@"id":@"2", @"color":@"red", @"type":@"seat"}
                  ];
    
    // initialize the body extractor
    _extractor = [[AGPageHeaderExtractor alloc] init];
}

-(void)tearDown {
    [super tearDown];
}

-(void) testParseQueryInformationWithNil {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:nil
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"nil passed in");
}

-(void) testParseQueryInformationWithArray {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:[NSArray array]
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"Array not supported");
}

-(void) testParseQueryInformationWithString {
    id stringVal = @"bogus";
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:stringVal
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertNil(parsedInfo, @"String not supported");
}

-(void) testParseQueryInformationWithEmptyDictionary {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:[NSDictionary dictionary]
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
                                            next:@"AG-Bogus-Next"
                                            prev:PREVIOUS_PAGE_IDENTIFIER];
    STAssertTrue(parsedInfo.count == 1, @"should have previous values only");
    
    // using internal next key:
    STAssertNil([parsedInfo valueForKey:NEXT_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

-(void) testParseQueryInformationWithBogusPrevLink {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:NEXT_PAGE_IDENTIFIER
                                            prev:@"AG-Bogus-Previous"];
    
    STAssertTrue(parsedInfo.count == 1, @"should have next values only");
    
    // using internal prev key:
    STAssertNil([parsedInfo valueForKey:PREVIOUS_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

-(void) testParseQueryInformationBogusNextPrevLinks {
    NSDictionary *parsedInfo = [_extractor parse:_response
                                         headers:_headers
                                            next:@"AG-Bogus-Next"
                                            prev:@"AG-Bogus-Previous"];
    STAssertTrue(parsedInfo.count == 0, @"should have no values");
    
    // using internal next-prev keys:
    STAssertNil([parsedInfo valueForKey:NEXT_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
    STAssertNil([parsedInfo valueForKey:PREVIOUS_PAGE_IDENTIFIER], @"should not be found, since we are looking for a wrong key");
}

@end

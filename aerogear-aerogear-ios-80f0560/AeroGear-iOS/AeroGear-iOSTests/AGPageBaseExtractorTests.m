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

#import "OCMock.h"

#import "AGPageBaseExtractor.h"

/**
 * mocked impl to test AGPageBaseExtractor base class
 * concrete implementation methods.
 */
@interface AGMockedPageExtractor: AGPageBaseExtractor
@end

@implementation AGMockedPageExtractor
@end

@interface AGPageBaseExtractorTests : SenTestCase

@end

@implementation AGPageBaseExtractorTests {
    AGMockedPageExtractor *_extractor;
}

-(void)setUp {
    [super setUp];
    
    _extractor = [[AGMockedPageExtractor alloc] init];
}

-(void)tearDown {
    [super tearDown];
}

-(void) testTransformQueryStringWithNil {
    NSDictionary *parsedQuery = [_extractor transformQueryString:nil];
    STAssertTrue(parsedQuery.count==0, @"empty dictionary");
}

-(void) testTransformQueryStringWithTwoArgs {
    // like from NSURL.query
    NSDictionary *parsedQuery = [_extractor transformQueryString:@"foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"should be 2 elements");
}

-(void) testTransformQueryStringWithTwoArgsAndResource {
    // returned from the controller
    NSDictionary *parsedQuery = [_extractor transformQueryString:@"cars?foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"should be 2 elements");
}

-(void) testTransformQueryStringWithTwoArgsAndLeadingQuestionmark {
    // header parasms
    NSDictionary *parsedQuery = [_extractor transformQueryString:@"?foo=1&bar=2"];
    STAssertTrue(parsedQuery.count==2, @"should be 2 elements");
}

@end

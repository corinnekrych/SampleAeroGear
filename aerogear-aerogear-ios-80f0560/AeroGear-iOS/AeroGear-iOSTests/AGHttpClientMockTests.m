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
#import <OCMock/OCMock.h>
#import "AGHttpClient.h"


@interface AGHttpClientMockTests : SenTestCase

@end
@implementation AGHttpClientMockTests

-(void) testHttpMockMoreExpectiationsForSuccessBlock {
    
    id mockClient = [OCMockObject mockForClass:[AGHttpClient class]];
    
    // build the expectations:
    
    // we expect that the "getPath" is invoked once and we accept ANY argument.....
    [[[mockClient expect] andDo:^(NSInvocation *invocation) {

        // fake block for sccess:
        void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = nil;
        [invocation getArgument:&successBlock atIndex:4]; // the arguments for the method start with 2 (see NSInvocation doc)
        
        // now invoke the successBlock:
        successBlock(nil, [NSDictionary dictionaryWithObjectsAndKeys:@"Bom Dia", @"greetings", nil]);  // here we would pass in the "faked" JSON response!
        
    }] getPath:[OCMArg any] parameters:nil success:[OCMArg any] failure:[OCMArg any]] ;
    
    
    // now, run the actual test:
    [mockClient getPath:@"projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        STAssertEqualObjects(@"Bom Dia", [responseObject objectForKey:@"greetings"], @"Some faked JSON");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAIL");
    }];
    
    
    
}


@end

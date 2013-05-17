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
#import "AGHttpClient.h"

#import "AGPipeline.h"
#import "AGMockURLProtocol.h"

static NSString *const PROJECTS = @"[{\"id\":1,\"title\":\"First Project\",\"style\":\"project-161-58-58\",\"tasks\":[]},{\"id\":                 2,\"title\":\"Second Project\",\"style\":\"project-64-144-230\",\"tasks\":[]}]";

static NSString *const DUMMY_JSON_RESPONSE = @"{\"key\":\"value\"}";

@interface AGHttpClientTests : SenTestCase

@end

// access the timer of the operation for the purpose of testing
@interface AFHTTPRequestOperation (Testing)
@property (nonatomic, retain) NSTimer* timer;
@end

@implementation AGHttpClientTests{
    BOOL _finishedFlag;
   
    AGHttpClient* _restClient;
}

-(void)setUp {
    [super setUp];
    
    // register AGFakeURLProtocol to fake HTTP comm.
    [NSURLProtocol registerClass:[AGMockURLProtocol class]];

    // set correct content-type otherwise AFNetworking
    // will complain because it expects JSON response
    [AGMockURLProtocol setHeaders:[NSDictionary
                                   dictionaryWithObject:@"application/json; charset=utf-8" forKey:@"Content-Type"]];
    
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    
    // Note: we set the timeout to a low level so that
    // we can test the timeout methods with adjusting response delay
    _restClient = [AGHttpClient clientFor:baseURL timeout:1];
    _restClient.parameterEncoding = AFJSONParameterEncoding;
    
    _finishedFlag = NO;
}

-(void)tearDown {
    // reset http mock state so it is not propagated to other tests
    [AGMockURLProtocol setStatusCode:200];
	[AGMockURLProtocol setResponseData:nil];
	[AGMockURLProtocol setError:nil];
    [AGMockURLProtocol setResponseDelay:0];
    [AGMockURLProtocol setHeaders:nil];
    // finally, unregister it from the runtime
    [NSURLProtocol unregisterClass:[AGMockURLProtocol class]];
    
    _restClient = nil;
    
    [super tearDown];
}

-(void)testHttpClientCreation {
    STAssertNotNil(_restClient, @"client should not be nil");
}

-(void)testGetProjects {
    [AGMockURLProtocol setResponseData:[PROJECTS dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restClient getPath:@"projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _finishedFlag = YES;
        STFail(@"should not have failed");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPostSuccessAndTimeoutTimerNil {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
   [_restClient postPath:@"projects" parameters:project success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
       STAssertNil(operation.timer, @"timer should be nil");
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        STFail(@"should not have been called");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPostFailureWithTimeoutTimerNil {
    [AGMockURLProtocol setResponseData:nil];

    NSMutableDictionary* project = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                         @"project-161-58-58", @"style", nil];
    
    // simulate an http 404 error in response
    // so the failure will be called.
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]];

    [_restClient postPath:@"projects" parameters:project success:^(AFHTTPRequestOperation *operation, id responseObject) {

        STFail(@"should not have been called");
        _finishedFlag = YES;

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        STAssertNil(operation.timer, @"timer should be nil");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPutSuccessAndTimeoutTimerNil {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"0", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    [_restClient putPath:@"projects/0" parameters:project success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        STAssertNil(operation.timer, @"timer should be nil");
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        STFail(@"should not have been called");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPutFailureWithTimeoutTimerNil {
    [AGMockURLProtocol setResponseData:nil];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"0", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    // simulate an http 404 error in response
    // so the failure will be called.
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]];
    
    [_restClient putPath:@"projects/0" parameters:project success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        STFail(@"should not have been called");
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        STAssertNil(operation.timer, @"timer should be nil");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testMultiplePostWithTimeout {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* projectFirst = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                         @"project-161-58-58", @"style", nil];
    
    [_restClient postPath:@"projects" parameters:projectFirst success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");

        NSMutableDictionary* projectSecond = [NSMutableDictionary
                                              dictionaryWithObjectsAndKeys:@"Second Project", @"title",
                                              @"project-111-45-51", @"style", nil];
        
        // simulate delay in response
        [AGMockURLProtocol setResponseDelay:2];
        
        [_restClient postPath:@"projects" parameters:projectSecond success:^(AFHTTPRequestOperation *operation, id responseObject) {

            STFail(@"should not have been called");
            _finishedFlag = YES;

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            STAssertNil(operation.timer, @"timer should be nil");
            STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
            _finishedFlag = YES;
            
        } ];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        _finishedFlag = YES;
        STFail(@"should not have been called");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPutWithTimeout {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* project = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:@"0", @"id", @"First Project", @"title",
                                    @"project-161-58-58", @"style", nil];
    
    // simulate delay in response
    [AGMockURLProtocol setResponseDelay:2];
    
    [_restClient putPath:@"projects/0" parameters:project success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        STFail(@"should not have been called");
        _finishedFlag = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        STAssertNil(operation.timer, @"timer should be nil");
        STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testMultiplePutWithTimeout {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* projectFirst = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:@"0", @"id", @"First Project", @"title",
                                         @"project-161-58-58", @"style", nil];
    
    [_restClient putPath:@"projects/0" parameters:projectFirst success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        
        NSMutableDictionary* projectSecond = [NSMutableDictionary
                                              dictionaryWithObjectsAndKeys:@"1", @"id", @"Second Project", @"title",
                                              @"project-111-45-51", @"style", nil];
        
        // simulate delay in response
        [AGMockURLProtocol setResponseDelay:2];
        
        [_restClient putPath:@"projects/1" parameters:projectSecond success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            STFail(@"should not have been called");
            _finishedFlag = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            STAssertNil(operation.timer, @"timer should be nil");
            STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
            _finishedFlag = YES;
            
        } ];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
        _finishedFlag = YES;
        STFail(@"should not have been called");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPostThenPutWithTimeout {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* projectFirst = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:@"First Project", @"title",
                                         @"project-161-58-58", @"style", nil];
    
    [_restClient postPath:@"projects" parameters:projectFirst success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        
        NSMutableDictionary* projectSecond = [NSMutableDictionary
                                              dictionaryWithObjectsAndKeys:@"1", @"id", @"Second Project", @"title",
                                              @"project-111-45-51", @"style", nil];
        
        // simulate delay in response
        [AGMockURLProtocol setResponseDelay:2];
        
        [_restClient putPath:@"projects/1" parameters:projectSecond success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            STFail(@"should not have been called");
            _finishedFlag = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            STAssertNil(operation.timer, @"timer should be nil");
            STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
            _finishedFlag = YES;
            
        } ];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
        _finishedFlag = YES;
        STFail(@"should not have been called");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPutThenPostWithTimeout {
    [AGMockURLProtocol setResponseData:[DUMMY_JSON_RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* projectFirst = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:@"0", @"id", @"First Project", @"title",
                                         @"project-161-58-58", @"style", nil];
    
    [_restClient putPath:@"projects/0" parameters:projectFirst success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STAssertNotNil(responseObject, @"response should not be nil");
        
        NSMutableDictionary* projectSecond = [NSMutableDictionary
                                              dictionaryWithObjectsAndKeys:@"Second Project", @"title",
                                              @"project-111-45-51", @"style", nil];
        
        // simulate delay in response
        [AGMockURLProtocol setResponseDelay:2];
        
        [_restClient postPath:@"projects" parameters:projectSecond success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            STFail(@"should not have been called");
            _finishedFlag = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
            STAssertNil(operation.timer, @"timer should be nil");
            STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
            _finishedFlag = YES;
            
        } ];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        _finishedFlag = YES;
        STFail(@"should not have been called");
        
    } ];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
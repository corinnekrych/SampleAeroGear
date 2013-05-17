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
#import "AGRestAuthentication.h"
#import "AGAuthConfiguration.h"
#import "AGPipeline.h"

#import "AGMockURLProtocol.h"

static NSString *const PASSING_USERNAME = @"john";

static NSString *const FAILING_USERNAME = @"fail";
static NSString *const LOGIN_PASSWORD = @"passwd";
static NSString *const ENROLL_PASSWORD = @"passwd";

static NSString *const LOGIN_SUCCESS_RESPONSE =  @"{\"username\":\"%@\",\"roles\":[\"admin\"]}";

@interface AGRestAuthenticationTests : SenTestCase

@end

@implementation AGRestAuthenticationTests {
    BOOL _finishedFlag;

    id<AGPipe> _projects;
    
    AGRestAuthentication* _restAuthModule;
}

-(void)setUp {
    [super setUp];
    
    // register AGFakeURLProtocol to fake HTTP comm.
    [NSURLProtocol registerClass:[AGMockURLProtocol class]];

    // set correct content-type otherwise AFNetworking
    // will complain because it expects JSON response
    [AGMockURLProtocol setHeaders:[NSDictionary
                                   dictionaryWithObject:@"application/json; charset=utf-8" forKey:@"Content-Type"]];
    
    
    NSURL* baseURL = [NSURL URLWithString:@"https://server.com/context/"];
    
    // setup REST Authenticator
    AGAuthConfiguration* config = [[AGAuthConfiguration alloc] init];
    [config setBaseURL:baseURL];
    [config setEnrollEndpoint:@"auth/register"];
    [config setTimeout:1]; // this is just for testing of timeout methods

    _restAuthModule = [AGRestAuthentication moduleWithConfig:config];

    // setup Pipeline
    AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    _projects = [pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"projects"];
        [config setAuthModule:_restAuthModule];
    }];
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
    
    _projects = nil;
    _restAuthModule = nil;
    
    [super tearDown];
}

-(void)testRestAuthenticationCreation {
    STAssertNotNil(_restAuthModule, @"module should not be nil");
}

-(void) testLoginSuccess {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];

    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        STAssertEqualObjects(PASSING_USERNAME, [responseObject valueForKey:@"username"], @"should be equal");
        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should have login", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLoginWithTimeout {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    // simulate delay in response
    // Note that pipe has been default configured for a timeout in 1 sec
    // here we simulate a delay of 2 sec
    [AGMockURLProtocol setResponseDelay:2];
    
    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        STFail(@"%@", @"should NOT have been called");
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLoginFails {
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain
                                                    code:401 // Unauthorized
                                                userInfo:nil]];
    
    [_restAuthModule login:FAILING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        STFail(@"should not work");
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLogout {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id object) {
        
        [_restAuthModule logout:^{
            _finishedFlag = YES;

        } failure:^(NSError *error) {
            _finishedFlag = YES;
            STFail(@"wrong logout...");
        }];
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"wrong login");
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testLogoutWithTimeout {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id object) {

        // simulate delay in response
        // Note that pipe has been default configured for a timeout in 1 sec
        // here we simulate a delay of 2 sec
        [AGMockURLProtocol setResponseDelay:2];
        
        [_restAuthModule logout:^{
            STFail(@"%@", @"should NOT have been called");
            _finishedFlag = YES;
       
        } failure:^(NSError *error) {
            STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
            _finishedFlag = YES;
        }];
    } failure:^(NSError *error) {
        STFail(@"%@", @"should NOT have been called");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testEnrollSuccess {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:PASSING_USERNAME forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];

    [_restAuthModule enroll:registerPayload success:^(id responseObject) {
        STAssertEqualObjects(PASSING_USERNAME, [responseObject valueForKey:@"username"], @"should be equal");
        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
        STFail(@"should have enroll", error);
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testEnrollTimeout {
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:PASSING_USERNAME forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];
    
    
    // simulate delay in response
    // Note that pipe has been default configured for a timeout in 1 sec
    // here we simulate a delay of 2 sec
    [AGMockURLProtocol setResponseDelay:2];
    
    [_restAuthModule enroll:registerPayload success:^(id responseObject) {

        STFail(@"%@", @"should NOT have been called");
        _finishedFlag = YES;

    } failure:^(NSError *error) {

        STAssertEquals(-1001, [error code], @"should be equal to code -1001 [request time out]");
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testEnrollFails {
    [AGMockURLProtocol setError:[NSError errorWithDomain:NSURLErrorDomain
                                                    code:400 // Bad Request
                                                userInfo:nil]];

    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:PASSING_USERNAME forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"admin" forKey:@"role"];
    
    [_restAuthModule enroll:registerPayload success:^(id responseObject) {
        STFail(@"should not work");        
        _finishedFlag = YES;
    } failure:^(NSError *error) {
        _finishedFlag = YES;
    }];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testCancel {
    NSDate *startTime = [NSDate date];
    
    [AGMockURLProtocol setResponseData:[[NSString stringWithFormat:LOGIN_SUCCESS_RESPONSE, PASSING_USERNAME]
                                        dataUsingEncoding:NSUTF8StringEncoding]];
    
    // simulate delay in response
    [AGMockURLProtocol setResponseDelay:2];
    
    [_restAuthModule login:PASSING_USERNAME password:LOGIN_PASSWORD success:^(id responseObject) {
        
        STFail(@"login should not have been called");
        _finishedFlag = YES;

    } failure:^(NSError *error) {
        STFail(@"logout should not have been called");
        _finishedFlag = YES;
    }];
    
    // cancel the request
    // Note that no callbacks will be called after this
    [_restAuthModule cancel];
    
    // wait until either _finishedFlag is set to true (e.g. test failed)
    // or timeout expired (no need to wait for more than the timeout set on the pipe)
    while (!_finishedFlag && [startTime timeIntervalSinceNow] > -1)
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

@end

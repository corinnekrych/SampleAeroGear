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
//#import "AGPipeline.h"
#import "AeroGear.h"

@interface AGPipelineTests : SenTestCase

@end

@implementation AGPipelineTests {
    NSURL* _baseURL;
    AGPipeline* _pipeline;
}

-(void)setUp {
    [super setUp];
    
    // create Pipeline
    _baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    _pipeline = [AGPipeline pipelineWithBaseURL:_baseURL];
}

-(void)tearDown {
    [super tearDown];
    
    _pipeline = nil;
    _baseURL = nil;
}

-(void)testPipelineCreation {
    STAssertNotNil(_pipeline, @"pipeline should not be nil");
}

-(void)testPipelineCreationWithBaseURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://app.com/context/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:baseURL];

    STAssertNotNil(pipeline, @"pipeline should not be nil");
}

-(void)testAddPipeWithDefaultType {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects(@"REST", pipe.type, @"verifying the (default) type");
}

-(void)testAddPipeWithValidType {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setType:@"REST"];
    }];

    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects(@"REST", pipe.type, @"verifying the REST type");
    
    // TODO: more valid types here as they become available.
}

-(void)testAddPipeWithInvalidType {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setType:@"INVALID"];
    }];
    
    STAssertNil(pipe, @"pipe should be nil");
}

-(void)testAddPipeWithName {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects([NSURL URLWithString:@"http://server.com/context/tasks"], pipe.URL, @"verifying the given URL");
}

-(void)testAddPipeWithURL {
    NSURL* baseURL = [NSURL URLWithString:@"http://app.com/context/"];

    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setBaseURL:baseURL]; // this should override base URL of the pipeline
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects([NSURL URLWithString:@"http://app.com/context/tasks"], pipe.URL, @"verifying the given URL");
}

-(void)testAddPipeWithEndpoint {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"bad name"];
        [config setEndpoint: @"realm/status"]; //endpoint with no trailing slash
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects([NSURL URLWithString:@"http://server.com/context/realm/status"], pipe.URL, @"verifying the given URL");
}

-(void)testAddPipeWithURLAndEndpoint {
    NSURL* baseURL = [NSURL URLWithString:@"http://us.battle.net/api/wow/"];
    
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"status"];
        [config setBaseURL:baseURL];
        [config setEndpoint: @"realm/status"]; //endpoint with no trailing slash
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    STAssertEqualObjects([NSURL URLWithString:@"http://us.battle.net/api/wow/realm/status"], pipe.URL, @"verifying the given URL");
}

-(void)testAddPipes {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setBaseURL:_baseURL];
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    
    id<AGPipe> otherPipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"projects"];
        [config setBaseURL:_baseURL];
    }];
    
    STAssertNotNil(otherPipe, @"other pipe should not be nil");
    
    // look em up:
    STAssertNotNil([_pipeline pipeWithName:@"tasks"], @"pipe should not be nil");
    STAssertNotNil([_pipeline pipeWithName:@"projects"], @"pipe should not be nil");
}

-(void)testAddAndRemovePipe {
    id<AGPipe> pipe = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
//        [config setBaseURL:_baseURL];
        [config setBaseURL:_baseURL];        
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");

    // look it up:
    STAssertNotNil([_pipeline pipeWithName:@"tasks"], @"pipe should not be nil");
    
    // remove it
    [_pipeline remove:@"tasks"];
    // look it up:
    STAssertNil([_pipeline pipeWithName:@"tasks"], @"pipe was already removed");
}

-(void)testRemoveNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    id<AGPipe> pipe  = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setBaseURL:baseURL];
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    
    // remove non existing pipe
    id<AGPipe> fooPipe = [_pipeline remove:@"foo"];
    STAssertNil(fooPipe, @"pipe should be nil");
}

-(void)testGetNonExistingPipe {
    NSURL* baseURL = [NSURL URLWithString:@"http://server.com/context/"];
    id<AGPipe> pipe  = [_pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setBaseURL:baseURL];
    }];
    
    STAssertNotNil(pipe, @"pipe should not be nil");
    
    // look up a non existing pipe
    id<AGPipe> fooPipe = [_pipeline pipeWithName:@"FOO"];
    STAssertNil(fooPipe, @"pipe should be nil");
}
@end
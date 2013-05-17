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

#import <Kiwi/Kiwi.h>
#import "AGPipeline.h"
#import "AGPipe.h"

SPEC_BEGIN(AGPipelineSpec)

describe(@"AGPipeline", ^{
    context(@"when newly created", ^{
        
        //A pipeline object:
        __block id pipeline = nil;
        
        beforeEach(^{
            NSURL* baseURL = [NSURL URLWithString:@"http://server.com/"];
            pipeline = [AGPipeline pipeline];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tests"];
                [config setBaseURL:baseURL];
            }];
        });
        
        it(@"should not be nil", ^{
            [pipeline shouldNotBeNil];
        });
        
        it(@"should have a pipe", ^{
            id pipe = [pipeline pipeWithName:@"tests"];
            [[theValue(pipe) shouldNot] equal:nil];
        });
        
    });
    context(@"adding new pipes", ^{
        
        //A pipeline object:
        __block id pipeline = nil;
        __block NSURL* baseURL;
        
        beforeEach(^{
            baseURL = [NSURL URLWithString:@"http://server.com/"];
        });
        
        it(@"with name and baseURL", ^{
            pipeline = [AGPipeline pipeline];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tests"];
                [config setBaseURL:baseURL];
            }];
            [pipeline shouldNotBeNil];
            
            id<AGPipe> pipe = [pipeline pipeWithName:@"tests"];
            [[pipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tests"]];
        });
        
        it(@"with name and baseURL and endpoint", ^{
            pipeline = [AGPipeline pipeline];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"some bad name"];
                [config setBaseURL:baseURL];
                [config setEndpoint:@"tests"];
            }];

            [pipeline shouldNotBeNil];
            
            id<AGPipe> pipe = [pipeline pipeWithName:@"some bad name"];
            [[pipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tests"]];
        });
        
        it(@"with name and baseURL and endpoint and (known) type", ^{
            pipeline = [AGPipeline pipeline];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"some bad name"];
                [config setBaseURL:baseURL];
                [config setEndpoint:@"tests"];
                [config setType:@"REST"];
            }];
            [pipeline shouldNotBeNil];
            
            id<AGPipe> pipe = [pipeline pipeWithName:@"some bad name"];
            [[pipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tests"]];
        });
        
        it(@"with name and baseURL and (known) type", ^{
            pipeline = [AGPipeline pipeline];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tests"];
                [config setBaseURL:baseURL];
                [config setType:@"REST"];
            }];
            [pipeline shouldNotBeNil];
            
            id<AGPipe> pipe = [pipeline pipeWithName:@"tests"];
            [[pipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tests"]];
        });
        
    });
});

SPEC_END
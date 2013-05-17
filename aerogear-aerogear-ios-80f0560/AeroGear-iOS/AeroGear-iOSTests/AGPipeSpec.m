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

SPEC_BEGIN(AGPipeSpec)

describe(@"AGPipe", ^{
    context(@"when newly created", ^{
        
        //A pipeline object:
        __block id pipeline = nil;
        
        
        beforeEach(^{
            NSURL* baseURL = [NSURL URLWithString:@"http://server.com/"];
            //pipeline = [AGPipeline pipeline];
            pipeline = [AGPipeline pipelineWithBaseURL:baseURL];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tests"];
                [config setBaseURL:baseURL];
            }];

        });

        it(@"AGPipe should have an expected URL", ^{
            
            id<AGPipe> pipe = [pipeline pipeWithName:@"tests"];
            [[theValue(pipe.URL) shouldNot] equal:nil];
            // does it match ?
            [[pipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tests"]];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object", ^{
            
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            NSLog(@"%@", newPipe);
            NSLog(@"%@", newPipe.URL);
            
            
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tasks"]];
        });

        it(@"AGPipeline should allow add a new AGPipe object with an endpoint ", ^{
            
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setEndpoint:@"mytasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/mytasks"]];
        });

        it(@"AGPipeline should allow add a new AGPipe object with an endpoint and a (known) type", ^{
            
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setType:@"REST"];
                [config setEndpoint:@"mytasks"];
            }];

            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/mytasks"]];
        });

        it(@"AGPipeline should allow add a new AGPipe object with a (known) type", ^{
            
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setType:@"REST"];
            }];

            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tasks"]];
        });

        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setBaseURL:newBaseURL];
            }];
            
            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/tasks"]];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and an endpoint", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setBaseURL:newBaseURL];
                [config setEndpoint:@"myTasks"];
            }];

            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/myTasks"]];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and an endpoint and a (known) type", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setBaseURL:newBaseURL];
                [config setEndpoint:@"myTasks"];
                [config setType:@"REST"];
            }];
            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/myTasks"]];
        });
        
        it(@"AGPipeline should allow add a new AGPipe object with a different baseURL and a (known) type", ^{
            
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setBaseURL:newBaseURL];
                [config setType:@"REST"];
            }];
            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/tasks"]];
        });

        it(@"AGPipeline should allow to add multiple AGPipe objects with different baseURLs", ^{
            
            // vanilla
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
            }];
            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tasks"]];
            
            
            // new pipe, with different baseURL:
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"projects"];
                [config setBaseURL:newBaseURL];
            }];

            
            id<AGPipe> otherPipe = [pipeline pipeWithName:@"projects"];
            [[theValue(otherPipe.URL) shouldNot] equal:nil];
            [[otherPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/projects"]];
            
            
            // yet another new pipe, with another different baseURL:
            NSURL* secondBaseURL = [NSURL URLWithString:@"http://blah.com/somecontext"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tags"];
                [config setBaseURL:secondBaseURL];
            }];
            
            id<AGPipe> newestPipe = [pipeline pipeWithName:@"tags"];
            [[theValue(newestPipe.URL) shouldNot] equal:nil];
            [[newestPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/somecontext/tags"]];
            
        });
        
        it(@"AGPipeline should allow to add multiple AGPipe objects with different baseURLs and replace previous ones", ^{
            
            // vanilla
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
            }];
            
            
            id<AGPipe> newPipe = [pipeline pipeWithName:@"tasks"];
            [[theValue(newPipe.URL) shouldNot] equal:nil];
            
            [[newPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/tasks"]];
            
            
            // new pipe, with different baseURL:
            NSURL* newBaseURL = [NSURL URLWithString:@"http://blah.com/context"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"projects"];
                [config setBaseURL:newBaseURL];
            }];

            
            id<AGPipe> otherPipe = [pipeline pipeWithName:@"projects"];
            [[theValue(otherPipe.URL) shouldNot] equal:nil];
            [[otherPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/context/projects"]];
            
            
            // yet another new pipe, but replace the 'tasks' pipe (even it has a different URL):
            NSURL* secondBaseURL = [NSURL URLWithString:@"http://blah.com/somecontext"];
            [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"tasks"];
                [config setBaseURL:secondBaseURL];
                [config setEndpoint:@"tags"];
            }];

            
            id<AGPipe> newestPipe = [pipeline pipeWithName  :@"tasks"];
            [[theValue(newestPipe.URL) shouldNot] equal:nil];
            [[newestPipe.URL should] equal:[NSURL URLWithString:@"http://blah.com/somecontext/tags"]];
            
        });
        
    });
});

SPEC_END
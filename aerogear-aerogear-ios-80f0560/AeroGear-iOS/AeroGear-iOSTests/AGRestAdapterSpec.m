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
#import "AGRESTPipe.h"

SPEC_BEGIN(AGRestAdapterSpec)

describe(@"AGRestAdapter", ^{
    context(@"when newly created", ^{
        
        //A 'RESTful' pipe object:
        __block AGRESTPipe* restPipe = nil;
        
        
        beforeEach(^{
            NSURL* baseURL = [NSURL URLWithString:@"http://server.com"];
            
            AGPipeConfiguration* config = [[AGPipeConfiguration alloc] init];
            [config setBaseURL:baseURL];
            [config setName:@"projects"];
            
            restPipe = [AGRESTPipe pipeWithConfig:config];
        });
        
        
        it(@"should not be nil", ^{
            [restPipe shouldNotBeNil];
        });
        
        it(@"should have an expected url", ^{
            [[restPipe.URL should] equal:[NSURL URLWithString:@"http://server.com/projects"]];
        });
        
    });
});

SPEC_END
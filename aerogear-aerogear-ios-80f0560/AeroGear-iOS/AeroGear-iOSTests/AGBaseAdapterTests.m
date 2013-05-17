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

#import "AGBaseAdapter.h"

@interface AGBaseAdapterTests : SenTestCase

@end

@implementation AGBaseAdapterTests

-(void)testAbstractClass {
    id adapter;
    @try {
        adapter = [[AGBaseAdapter alloc] init];
        STFail(@"should not get here...");
    }
    @catch (NSException *exception) {
        // expected...
    }
    @finally {
        // nope..

    }
}

-(void)testAbstractMethod {
    @try {
        [AGBaseAdapter accepts:@"FOO"];
        STFail(@"should not get here...");
    }
    @catch (NSException *exception) {
        // expected...
    }
    @finally {
        // nope..
    }
}

@end

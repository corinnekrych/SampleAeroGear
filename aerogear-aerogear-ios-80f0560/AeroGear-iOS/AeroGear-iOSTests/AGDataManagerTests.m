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
#import "AGStore.h"
#import "AGDataManager.h"

@interface AGDataManagerTests : SenTestCase

@end
@implementation AGDataManagerTests {
    AGDataManager* _manager;
}

-(void)setUp {
    [super setUp];
    
    // create DataManager
    _manager = [AGDataManager manager];
}

-(void)tearDown {
    [super tearDown];
    
    _manager = nil;
}

-(void)testDataManagerCreation {
    STAssertNotNil(_manager, @"manager should not be nil");
}

-(void)testAddStoreWithDefaultType {
    id<AGStore> store = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
    }];

    STAssertNotNil(store, @"store should not be nil");
}

-(void)testAddStoreWithMemoryType {
    id<AGStore> store = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
        [config setType:@"MEMORY"];
    }];
    
    STAssertNotNil(store, @"store should not be nil");
}

-(void)testAddStoreWithInvalidType {
    id<AGStore> store = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
        [config setType:@"INVALID"];
    }];
    
    STAssertNil(store, @"store should be nil");
}

-(void) testAddAndRemoveStores {
    id<AGStore> taskStore = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
    }];
    
    STAssertNotNil(taskStore, @"store should not be nil");
    
    id<AGStore> tagStore = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"projects"];
    }];
    
    STAssertNotNil(tagStore, @"store should not be nil");
    
    // look em up:
    STAssertNotNil([_manager storeWithName:@"tasks"], @"store should not be nil");
    STAssertNotNil([_manager storeWithName:@"projects"], @"store should not be nil");
    
    // remove it
    [_manager remove:@"tasks"];
    // look it up:
    STAssertNil([_manager storeWithName:@"tasks"], @"store was already removed");
    
    // remove it
    [_manager remove:@"projects"];
    // look it up:
    STAssertNil([_manager storeWithName:@"projects"], @"store was already removed");
}

-(void)testRemoveNonExistingStore {
    id<AGStore> store = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
    }];
    
    STAssertNotNil(store, @"store should not be nil");
    
    // remove non existing store
    id<AGStore> fooStore = [_manager remove:@"FOO"];
    STAssertNil(fooStore, @"store should be nil");
}

-(void)testGetNonExistingStore {
    id<AGStore> store = [_manager store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
    }];
    
    STAssertNotNil(store, @"store should not be nil");
    
    // look up a non existing store
    id<AGStore> fooStore = [_manager storeWithName:@"FOO"];
    STAssertNil(fooStore, @"store should be nil");
}
@end

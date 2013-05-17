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

#import "AGPropertyListStorage.h"

@interface AGPropertyListStorageTests : SenTestCase

@end

@implementation AGPropertyListStorageTests {
    AGStoreConfiguration* _config;
}

-(void)setUp {
    [super setUp];
    
    // shared configuration
    _config = [[AGStoreConfiguration alloc] init];
    [_config setName:@"pliststore"];
    [_config setRecordId:@"id"];
}

-(void)tearDown {
    [super tearDown];

    // remove all elements from the store
    // so next test starts fresh
    AGPropertyListStorage* plistStore = [AGPropertyListStorage storeWithConfig:_config];
    [plistStore reset:nil];
}

-(void) testSaveAndRead{
    NSMutableDictionary* user = [NSMutableDictionary
                                  dictionaryWithObjectsAndKeys:@"Robert",@"name",@"0",@"id", nil];
    

    AGPropertyListStorage* plistStore;

    // create store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // save object
    BOOL success = [plistStore save:user error:nil];
    STAssertTrue(success, @"save should have succeeded");
    

    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // read it
    NSMutableDictionary *readSaved = [plistStore read:@"0"];
    STAssertEqualObjects(@"Robert", [readSaved valueForKey:@"name"], @"should be equal");
}

-(void) testSaveAndRemoveAndRead{
    NSMutableDictionary* user = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    BOOL success;
    
    //save it
    success = [plistStore save:user error:nil];
    STAssertTrue(success, @"save should have succeeded");
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read it
    NSMutableDictionary *readSaved = [plistStore read:@"0"];
    STAssertEqualObjects(@"Robert", [readSaved valueForKey:@"name"], @"should be equal");
    
    // remove it
    success = [plistStore remove:readSaved error:nil];
    STAssertTrue(success, @"remove should have succeeded");

    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    // read it
    NSMutableDictionary* readRemoved = [plistStore read:@"0"];
    STAssertNil(readRemoved, @"object should be nil");
}

-(void) testReset {
    NSMutableDictionary* user1 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"0",@"id", @"Robert",@"name", nil];
    NSMutableDictionary* user2 = [NSMutableDictionary
                                 dictionaryWithObjectsAndKeys:@"1",@"id", @"John",@"name", nil];
    
    
    NSArray* users = [NSArray arrayWithObjects:user1, user2, nil];
    
    AGPropertyListStorage* plistStore;

    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    BOOL success;
    
    //save it
    success = [plistStore save:users error:nil];
    STAssertTrue(success, @"save should have succeeded");

    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    // read first object
    NSMutableDictionary* readFirstObject = [plistStore read:@"0"];
    STAssertEqualObjects(@"Robert", [readFirstObject valueForKey:@"name"], @"should be equal");
    
    // read second object
    NSMutableDictionary* readSecondObject = [plistStore read:@"1"];
    STAssertEqualObjects(@"John", [readSecondObject valueForKey:@"name"], @"should be equal");
    
    // reset all objects
    success = [plistStore reset:nil];
    STAssertTrue(success, @"reset should not have failed");
    
    // reload store
    plistStore = [AGPropertyListStorage storeWithConfig:_config];

    NSMutableDictionary *readRemoved;
    
    // read first object
    readRemoved = [plistStore read:@"0"];
    STAssertNil(readRemoved, @"object should be nil");
    
    // read second object
    readRemoved = [plistStore read:@"1"];
    STAssertNil(readRemoved, @"object should be nil");   
}

-(void)testReadWithEmptyStore {
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    NSMutableDictionary *user = [plistStore read:@"0"];
    STAssertNil(user, @"object should be nil");
}

-(void)testReadAllWithEmptyStore {
    AGPropertyListStorage* plistStore;
    
    plistStore = [AGPropertyListStorage storeWithConfig:_config];
    
    NSArray* objects = [plistStore readAll];
    STAssertEquals((NSUInteger)0, [objects count], @"Must be size 0");
}

@end

//
//  AGViewController.m
//  AeroGearExample
//
//  Created by Corinne Krych on 5/13/13.
//  Copyright (c) 2013 red hat. All rights reserved.
//

#import "AGViewController.h"
#import <AeroGear/AeroGear.h>

@interface AGViewController ()

@end

//@implementation AGViewController
@implementation AGViewController {
    NSArray *_tasks;
    id<AGAuthenticationModule> _authModule;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSURL object:
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server"];
    
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"myModule"];
        [config setBaseURL:projectsURL];
    }];
    
    id<AGPipe> tasksPipe;
   
    
    // create the 'todo' pipeline, which contains the 'projects' pipe:
    AGPipeline *todo = [AGPipeline pipelineWithBaseURL:projectsURL];
    
    tasksPipe = [todo pipe:^(id<AGPipeConfig> config) {  
        [config setName:@"tasks"];
    }];
    
    [_authModule login:@"john" password:@"123" success:^(id object) {
    
    [tasksPipe read:^(id responseObject) {
        
     _tasks = responseObject;

     [self.view setNeedsDisplay];//[self.tableView reloadData];
        
     }
            failure:^(NSError *error) {
            NSLog(@"An error has occured during fetch! \n%@", error);
            }];}
     
               failure:^(NSError *error) {
                    NSLog(@"Auth:%@", error);
               }];
    
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // NSURL object:
//    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server"];
//    
//    id<AGPipe> tasksPipe;
//    
//    // create the 'todo' pipeline, which contains the 'projects' pipe:
//    AGPipeline *todo = [AGPipeline pipelineWithBaseURL:projectsURL];  
//    
//    tasksPipe = [todo pipe:^(id<AGPipeConfig> config) {  
//        [config setName:@"tasks"];
//    }];
//    
//    [tasksPipe read:^(id responseObject) {  
//        
//        _tasks = responseObject; 
//        
//        [self.view setNeedsDisplay];//reloadData];
//        
//    } failure:^(NSError *error) {
//        NSLog(@"An error has occured during fetch! \n%@", error);
//    }];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [[_tasks objectAtIndex:row] objectForKey:@"title"];
    
    return cell;
}

@end

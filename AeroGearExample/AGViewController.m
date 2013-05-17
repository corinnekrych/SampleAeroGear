//
//  AGViewController.m
//  
//
//  Created by Corinne Krych on 5/17/13.
//
//

#import "AGViewController.h"
#import <AeroGear/AeroGear.h>                                           // [1]

@interface AGViewController ()

@end

@implementation AGViewController {
    id<AGAuthenticationModule> _authModule;                             // [2]
    NSArray *_tasks;                                                    // [3]
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSURL object:
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/"];
    
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"myModule"];
        [config setBaseURL:projectsURL];
    }];
    
    id<AGPipe> tasksPipe;
    
    // create the 'todo' pipeline, which contains the 'projects' pipe:
    AGPipeline *todo = [AGPipeline pipelineWithBaseURL:projectsURL];    // [4]
    
    tasksPipe = [todo pipe:^(id<AGPipeConfig> config) {                 // [5]
        [config setName:@"tasks"];
        [config setAuthModule:_authModule];
    }];
    
    [_authModule login:@"john" password:@"123" success:^(id object) {   // [6]
        
        [tasksPipe read:^(id responseObject) {                          // [7]
            
            _tasks = responseObject;                                    // [8]
            
            [self.tableView reloadData];                                // [9]
            
        }
                failure:^(NSError *error) {
                    NSLog(@"An error has occured during fetch! \n%@", error);
                }];}
     
               failure:^(NSError *error) {
                   NSLog(@"Auth:%@", error);
               }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

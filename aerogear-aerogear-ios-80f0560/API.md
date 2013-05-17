AeroGear iOS API - DRAFT 0.1
============================

API Docs are available [here](http://aerogear.org/docs/specs/aerogear-ios/)...

There is a [FAQ](http://aerogear.org/docs/guides/FAQ/) that talks about the API in a general fashion.

Below is a simple 'Getting started' section on how-to use the API

## Creating a pipeline and a pipe object

To create a pipeline, you need to use the AGPipeline class. Below is an example: 

    // NSURL object:
    NSURL* serverURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/"];

    // create the 'todo' pipeline, which points to the baseURL of the REST application
    AGPipeline* todo = [AGPipeline pipelineWithBaseURL:serverURL];

    // Add a REST pipe for the 'projects' endpoint
    id<AGPipe> projects = [todo pipe:^(id<AGPipeConfig> config) {
        [config setName:@"projects"];
        [config setType:@"REST"]; // this is the default, can be emitted
    }];


The AGPipeline class offers some simple 'management' APIs to work with containing AGPipe objects, which itself represents a server connection. The AGPipe API is basically an abstraction layer for a server side connection. In the example above the 'projects' pipe points to an RESTful endpoint (http://todo-aerogear.rhcloud.com/todo-server/projects). However, technical details like RESTful APIs (e.g. HTTP PUT) are not exposed on the AGPipeline and AGPipe APIs. Below is shown how to get access to an actual pipe, from the AGPipeline object:

    // get access to the 'projects' pipe
    id<AGPipe> projects = [todo pipeWithName:@"projects"];

## Save data 

The AGPipe offers an API to store newly created objects on a _remote_ server resource. CURRENTLY the objects are _just_ simple map objects... In the future we are looking to support more advanced(complex) frameworks, like Core Data. The 'save' method is described below:

    // create a dictionary and set some key/value data on it:
    NSMutableDictionary* projectEntity = [NSMutableDictionary dictionary];
    [projectEntity setValue:@"Hello World" forKey:@"title"];
    // add other properties, like style etc ...

    // save the 'new' project:
    [projects save:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        // get the id of the new project, from the JSON response...
        id resourceId = [responseObject valueForKey:@"id"];

        // and update the 'object', so that it knows its ID...
        [projectEntity setValue:[resourceId stringValue] forKey:@"id"];
        
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];

Above the _save_ function stores the given NSDictionary on the server, in this case on a RESTful resource. As arguments it accepts simple blocks that are invoked on _success_ or in case of an _failure_.

## Update data

The 'save' method (like in aerogear.js) is also responsible for updating an 'object'. However this happens _only_ when there is an 'id' property/field available:

    // change the title of the previous project 'object':
    [projectEntity setValue:@"Hello Update World!" forKey:@"title"];
    
    // and now update it on the server
    [projects save:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"UPDATE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"UPDATE: An error occured! \n%@", error);
    }];

## Remove data

The AGPipe also contains a 'remove' method to delete the data on the server. It takes the map object which must have an 'id' property/field set, so that it knows which resource to delete:

    // Now, just remove the project:
    [projects remove:projectEntity success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"DELETE RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"DELETE: An error occured! \n%@", error);
    }];

In this case, where we have a RESTful pipe the API issues a HTTP DELETE request.

## Read all data from the server

The 'read' method allows to (currently) read _all_ data from the server, of the underlying AGPipe:

    [projects read:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"READ RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

Since we are pointing to a RESTful endpoint, the API issues a HTTP GET request. The JSON output of the above NSLog() call looks like this:

    (
            {
            id = 8;
            style = "project-234-255-0";
            tasks =         (
            );
            title = "Created from testcase";
        },
            {
            id = 15;
            style = "project-255-255-255";
            tasks =         (
            );
            title = "Some title";
        }
    )

Of course the _collection_ behind the responseObject can be stored to a variable...

## Time out and Cancel pending operations

### Timeout
During construction of the Pipe object, you can optionally specify a timeout interval (default is 60 secs) for an operation to complete. If the time interval is exceeded with no response from the server, then the _failure_ callback is executed. 

From the todo example above:

    id<AGPipe> projects = [todo pipe:^(id<AGPipeConfig> config) {
        ... 
        [config setTimeout:20];  // set the time interval to 20 secs
    }];

### Cancel
At any time after starting your operations, you can call 'cancel' on the Pipe object to cancel all running Pipe operations. Any registered callbacks on the pipe are NOT executed so it is your responsibility to provide any neccessary cleanups after calling this method.


    [projects read:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"READ RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

    // cancel operations. NOTE that no 'success' or 'failure' callbacks are executed after this.
    [projects cancel];


Paging
=============

The library has built-in paging support, enabling the scrolling to either forward or backwards through a result set returned from the server. Paging metadata located in the server response (either in the headers, in the body or using [webLinking](http://tools.ietf.org/html/rfc5988)) are used to identify the next or the previous result set. For example, in Twitter case, paging metadata are located in the body of the response, using "next\_page" or "previous\_page" to identify the next or previous result set respectively. The location of this metadata as well as naming, is fully configurable during the creation of the pipe, thus enabling greater flexibility in supporting several different paging strategies.

Below is an example that goes against the AeroGear Controller Server.

First we create our pipeline. Notice that in the Pipe configuration object, we explicitely declare the name of the paging identifiers supported by the server, as well as the the location of these identifiers in the response. Note that If not specified, the library will assume the server is using Web Linking paging strategy.

    NSURL* baseURL = [NSURL URLWithString:@"https://controller-aerogear.rhcloud.com/aerogear-controller-demo"];
    AGPipeline* agPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    
    id<AGPipe> cars = [agPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"cars-custom"];
        [config setNextIdentifier:@"AG-Links-Next"];
        [config setPreviousIdentifier:@"AG-Links-Previous"];
        [config setMetadataLocation:@"header"];
    }];

## Start Paging

To kick-start pagination, you use the method _readWithParams_ of the underlying AGPipe, passing your desired query parameters to the server. Upon successfully completion, the _pagedResultSet_ (an enchached category of nsarray) will allow you to scroll through the result set.

    __block NSMutableArray *pagedResultSet;

    // fetch the first page
    [cars readWithParams:@{@"color" : @"black", @"offset" : @"0", @"limit" : @1} success:^(id responseObject) {
        pagedResultSet = responseObject;

        // do something

    } failure:^(NSError *error) {
        //handle error
    }];

## Move Forward in the result set

To move forward in the result set, you simple call _next_ on the _pagedResultSet_ :

    // move to the next page
    [pagedResultSet next:^(id responseObject) {
        // do something

    } failure:^(NSError *error) {
        // handle error
    }];

## Move Backwards in the result set

To move backwards in the result set, you simple call _previous_ on the _pagedResultSet_ :

    [pagedResultSet previous:^(id responseObject) {
        // do something
        
    } failure:^(NSError *error) {
        // handle error
    }];

## Exception cases

Moving beyond last or first page is left on the behaviour of the specific server implementation, that is the library will not treat it differently. Some servers can throw an error (like Twitter or AeroGear Controller does) by respondng with an http error response, or simply return an empty list. The user is responsible to cater for exception cases like this.

AGDataManager
=============

## Create a datamanager with store object:

After receiving data from the server, your application may want to keep the data around. The AGDataManager API allows you to create AGStore instances. To create a datamanager, you need to use the AGDataManager class. Below is an example: 

    // create the datamanager
    AGDataManager* dm = [AGDataManager manager];
    // add a new (default) store object:
    id<AGStore> myStore = [dm store:^(id<AGStoreConfig> config) {
        [config setName:@"tasks"];
    }];

The AGDataManager class offers some simple 'management' APIs to work with containing AGStore objects. The API offers read and write functionality. The default implementation represents an "in-memory" store. Similar to the pipe API technical details of the underlying system are not exposed.

## Save data to the Store

When using a pipe to read all entries of a endpoint, you can use the AGStore to save the received objects:

    ....
    id<AGPipe> tasksPipe = [todo get:@"tasks"];
    ...

    [tasksPipe read:^(id responseObject) {
        // the response object represents an NSArray,
        // containing multile 'Tasks' (as NSDictionary objects)

        // Save the response object to the store
        NSError *error;
        
        if (![myStore save:responseObject error:&error])
            NSLog(@"Save: An error occured during save! \n%@", error);    

    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

When loading all tasks from the server, the AGStore object is used inside of the _read_ block from the AGPipe object. The returned collection of tasks is stored inside our in-memory store, from where the data can be accessed.

## Read an object from the Store

    // read the task with the '0' ID:
    id taskObject =  [myStore read:@"0"];

The _read_ function accepts the _recordID_ of the object you want to retrieve. If the object does not exist in the store, _nil_ is returned.

If you want to read _all_ the objects contained in the store, simply call the _readAll_ function

    // read all objects from the store
    NSArray *objects = [myStore readAll];

## Remove one object from the Store

The remove function allows you to delete a single entry in the collection, if present:

    // remove the task with the '0' ID:
    NSError *error;

    if (![myStore remove:@"0" error:error])
        NSLog(@"Save: An error occured during remove! \n%@", error);    

The remove method accepts the _recordID_ of the object you want to remove. If the object does not exist in the store, FALSE is returned.

## Filter the entire store

Filtering of the data available in the AGStore is also supported, by using the familiar NSPredicate class available in iOS. In the following example, after storing a pair of dictionaries representing user information details in the store (which can be easily come from a response from a server), we simple call the _filter_ method to filter out the desired information:
     
     NSMutableDictionary *user1 = [@{@"id" : @"1",
                                    @"name" : @"Robert",
                                    @"city" : @"Boston",
                                    @"department" : @{@"name" : @"Software", @"address" : @"Cornwell"},
                                    @"experience" : @[@{@"language" : @"Java", @"level" : @"advanced"},
                                                      @{@"language" : @"C", @"level" : @"advanced"}]
                                  } mutableCopy];
    
    NSMutableDictionary *user2 = [@{@"id" : @"2",
                                    @"name" : @"David",
                                    @"city" : @"Boston",
                                    @"department" : @{@"name" : @"Software", @"address" : @"Cornwell"},
                                    @"experience" : @[@{@"language" : @"Java", @"level" : @"intermediate"},
                                                      @{@"language" : @"Python", @"level" : @"intermediate"}]
                                  } mutableCopy];

    NSMutableDictionary *user3 = [@{@"id" : @"3",
                                    @"name" : @"Peter",
                                    @"city" : @"Boston",
                                    @"department" : @{@"name" : @"Software", @"address" : @"Branton"},
                                    @"experience" : @[@{@"language" : @"Java", @"level" : @"advanced"},
                                                      @{@"language" : @"C", @"level" : @"intermediate"}]
                                  } mutableCopy];

    // save objects
    BOOL success = [_memStore save:users error:nil];

    if (success) { // if save succeeded, query the data
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"city = 'Boston' AND department.name = 'Software' \
                                  AND SUBQUERY(experience, $x, $x.language = 'Java' AND $x.level = 'advanced').@count > 0" ];

        NSArray *results = [_memStore filter:predicate];

        // The array now contains the dictionaries _user1_ and _user_3, since they both satisfy the query predicate.
        // do something with the 'results'
        // ...
    }

Using NSPredicate to filter desired data, is a powerful mechanism offered in iOS and we strongly suggest to familiarize yourself with it, if not already. Take a look at Apple's own [documentation](http://tinyurl.com/chmgwv5) for more information.

## Reset the entire store

The reset function allows you the erase all data available in the used AGStore object:

    // clears the entire store
    NSError *error;

    if (![myStore reset:&error])
        NSLog(@"Reset: An error occured during reset! \n%@", error);    
    

## Persistent Storage system

A simple _Property list_ storage system is part of the library as well, The same ```AGStore``` protocol is used for reading and writing. Below is a small example on how to save to the file system:

    // initalize plist store (if the file does not exist it will be created)
    AGDataManager* manager = [AGDataManager manager];
    id<AGStore> plistStore = [manager store:^(id<AGStoreConfig> config) {
        [config setName:@"secrets"]; // will be used as the filename for the plist
        [config setType:@"PLIST"];
    }];
 
    // the object to save (e.g. a dictionary)
    NSDictionary *otp = [NSDictionary dictionaryWithObjectsAndKeys:@"19a01df0281afcdbe", @"otp", @"1", @"id", nil];

    // save it
    NSError *error;
        
    if (![plistStore save:otp error:&error])
        NSLog(@"Save: An error occured during save! \n%@", error);    

    
The ```read```, ```reset``` or ```remove``` API behave the same, as on the default ("in memory") store. 

Authentication and User enrollment
==================================

## Creating an authenticator with an authentication module

To create an authenticator, you need to use the AGAuthenticator class. Below is an example: 

    // create an authenticator object
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];

    // add a new auth module and the required 'base url':
    NSURL* baseURL = [NSURL URLWithString:@"https://todoauth-aerogear.rhcloud.com/todo-server/"];
    id<AGAuthenticationModule> myMod = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"authMod"];
        [config setBaseURL:baseURL];
    }];

The AGAuthenticator class offers some simple 'management' APIs to work with containing AGAuthenticationModule objects. The API provides an authentication and enrollment API. The default implementation uses REST as the auth transport. Similar to the pipe API technical details of the underlying system are not exposed.

## Register a user

The _enroll_ function of the ```AGAuthenticationModule``` protocol is used to register new users with the backend:

    // assemble the dictionary that has all the data for THIS particular user:
    NSMutableDictionary* userData = [NSMutableDictionary dictionary];
    [userData setValue:@"john" forKey:@"username"];
    [userData setValue:@"123" forKey:@"password"];
    [userData setValue:@"me@you.com" forKey:@"email"];
    [userData setValue:@"21sda812sad24" forKey:@"betaAccountToken"];

    // register a new user
    [myMod enroll:userData success:^(id data) {
        // after a successful _registration_, we can work
        // with the returned data...
        NSLog(@"We got: %@", data);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];

The _enroll_ function submits a generic map object with contains all the information about the new user, that the server endpoint requires. The default (REST) auth module issues for the above a request against _https://todoauth-aerogear.rhcloud.com/todo-server/auth/enroll_. Besides the NSDictionary the function accepts two simple blocks that are invoked on success or in case of an failure.

## Login 

Once you have a _valid_ user you can use that information to issue a login against the server, to start accessing protected endpoints:

    // issuing a login
    [myMod login:@"john" password:@"123" success:^(id object) {
        // after a successful _login_, we can work
        // with the returned data...
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];

The default (REST) auth module issues for the above a request against _https://todoauth-aerogear.rhcloud.com/todo-server/auth/login_. Besides the _username_ and the _password_, the function accepts two simple blocks that are invoked on success or in case of an failure.

## Pass the auth module to a pipe

After running a successful login, you can start using the _AGAuthenticationModule_ object on a _AGPipe_ object to access protected endpoints:

    ...
    id<AGPipe> tasks = [pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tasks"];
        [config setBaseURL:serverURL];
        [config setAuthModule:myMod];
    }];

    [tasks read:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"READ RESPONSE\n%@", [responseObject description]);
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"Read: An error occured! \n%@", error);
    }];

When creating a pipe you need to use the _authModule_ argument in order to pass in an _AGAuthenticationModule_ object.

## Logout

The logout from the server can be archived by using the _logout_ function:

    // logout:
    [myMod logout:^{
        // after a successful _logout_, when can notify the application
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];

The default (REST) auth module issues for the above a request against _https://todoauth-aerogear.rhcloud.com/todo-server/auth/logout_. The function accepts two simple blocks that are invoked on success or in case of an failure.

## Time out and Cancel pending operations

As with the case of Pipe, configured timeout interval (in the config object) and cancel operation in _AGAuthenticationModule_ is supported too.

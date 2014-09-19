//
//  EVXMasterViewController.m
//  JsonParseMe
//
//  Created by evx on 9/17/14.
//  Copyright (c) 2014 evxyz001. All rights reserved.
//

#import "EVXMasterViewController.h"

#import "EVXDetailViewController.h"
#import "Course.h"

@interface EVXMasterViewController () {
// a mutableArray already declared for us.
    NSMutableArray *_objects;
    // two vars we will need

    Course *currentCourse;
    NSMutableString *currentValue;
}
@end

@implementation EVXMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;

    NSURL *url = [NSURL URLWithString:@"http://www.pluralsight.com/odata/Courses"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error){

        // [NSURLConnection sendAsynchronousRequest allows us to
        // a block as a completionHandler: once the XML request has finished
        // one of the things that will be passed to the block is NSData *data,
        // which we can accept and intialize
        NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:data];
        // delegate for parser declared
        [xmlParser setDelegate:self];
        // then we just call parse method
        [xmlParser parse];
        // before this will work;
        // goto header and tell it we will be delegate
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NSXMLParserDelegate Methods 
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    // this gets called only at the beginning so put
    // initialization stuff here
    currentValue =[[NSMutableString alloc]init];
    _objects = [[NSMutableArray alloc]init];

}
-(void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    [currentValue setString:@""];
// courses begins with an entry tag
    if ([elementName isEqualToString:@"entry"]) {
        currentCourse = [[Course alloc]init];
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [currentValue appendString:string];
}
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"d:Title"]) {
        [currentCourse setTitle:[currentValue stringByTrimmingCharactersInSet: [NSCharacterSetwhitespaceAndNewlineCharacterSet]]];
    }
    if ([elementName isEqualToString:@"d:Category"]) {
        [currentCourse setTitle:[currentValue stringByTrimmingCharactersInSet: [NSCharacterSetwhitespaceAndNewlineCharacterSet]]];
    }
    if ([elementName isEqualToString:@"d:ShortDescription"]) {
        [currentCourse setTitle:[currentValue stringByTrimmingCharactersInSet: [NSCharacterSetwhitespaceAndNewlineCharacterSet]]];
    }
    // finshed with parse add it to the array
    if ([elementName isEqualToString:@"d:entry"]) {
        [_objects addObject:currentCourse];
    }

}

-(void)paserDidEndDocument:(NSXMLParser *)parser {
    // using background threads in an asyc pattern
    // allows mobile apps to stay responsive while gathering
    // data
    // return to main thread and Update tableView
    // getting on a backgrounding thread is okay
    // posting from a background thread is likely to throw an error
    // return to the main thread before posting to
    // UIKIT

    [dispatch_async(dispatch_get_main_queue(), ^{
        // refreshes table view
        [[self tableView]reloadData];
    });

}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error Code: %d",[parseError code]);
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Course *object = _objects[indexPath.row];
    cell.textLabel.text = [object   title];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end

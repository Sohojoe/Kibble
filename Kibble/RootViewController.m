//
//  RootViewController.m
//  Kibble
//
//  Created by Joe on 3/18/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "RootViewController.h"
#import "KTClassRnD.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSMutableArray *items = [NSMutableArray arrayWithObjects:@"One",
    //                         @"Two", @"Three!", nil];
    //SCArrayOfStringsSection *stringsSection = [SCArrayOfStringsSection
     //                                          sectionWithHeaderTitle:@"Strings Section" items:items];
    //[self.tableViewModel addSection:stringsSection];
    

    // Create the TaskStep definition
    SCClassDefinition *classDef = [SCClassDefinition
                                   definitionWithClass:[KTClass class]
                                   autoGeneratePropertyDefinitions:YES];
    [classDef propertyDefinitionWithName:@"name;classesTemp;classMethods;instanceMethods;instanceVars"].type = SCPropertyTypeTextView;
    
    
    KTFoundation *f = [KTFoundation foundationFromDisk:@"TestFoundation"];
    
    SCClassDefinition *foundationDef = [SCClassDefinition
                                  definitionWithClass:[KTFoundation class]
                                  propertyNamesString:@"name;classesTemp;classes"];
/*
    SCPropertyDefinition *classesPropertyDef = [foundationDef propertyDefinitionWithName:@"classesTemp"];
    classesPropertyDef.type = SCPropertyTypeArrayOfObjects;
    classesPropertyDef.attributes = [SCSelectionAttributes
                                      attributesWithItems:f.classesTemp allowMultipleSelection:NO
                                      allowNoSelection:NO];
*/
/*
    __block NSMutableArray *classes = [NSMutableArray new];
    [f enumerateClasses:^(KTClass *aClass) {
        [classes addObject:aClass];
    }];

    // Create the Task definition
    SCPropertyDefinition *classRelDef = [foundationDef propertyDefinitionWithName:@"classes"];
    classRelDef.title = @"Classes";
    classRelDef.type = SCPropertyTypeAutoDetect;
    classRelDef.attributes = [SCArrayOfObjectsAttributes attributesWithObjectDefinition:classDef allowAddingItems:YES
                                  allowDeletingItems:NO allowMovingItems:YES];
    // Create the section for the tasks array
    SCArrayOfObjectsSection *classSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil items:classes
                                             itemsDefinition:foundationDef];
    classSection.addButtonItem = self.addButton;
    classSection.placeholderCell = [SCTableViewCell
                                    cellWithText:@"No tasks yet!" textAlignment: NSTextAlignmentCenter];
    //[self.tableViewModel addSection:classSection];
    
    

    // Create the section(s) for the task object
    [self.tableViewModel generateSectionsForObject:[f classWithName:@"NSString"]
                                    withDefinition:classDef];
*/
    [self.tableViewModel generateSectionsForObject:f
                                    withDefinition:foundationDef];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  RootViewController.m
//  Kibble
//
//  Created by Joe on 3/18/14.
//  Copyright (c) 2014 Vidya Gamer. All rights reserved.
//

#import "RootViewController.h"
#import "KTClassRnD.h"


@interface RootClass : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *arrayOfSubObjects;
@end
@interface SubClass : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *arrayOfSubObjects;
@end
@implementation RootClass @end
@implementation SubClass @end

@interface Task : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@interface TTFoundation : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *classes;
@property (nonatomic, strong) KTFoundation *foundation;
@end
@interface TTClass : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *classMethods;
@property (nonatomic, strong) NSMutableArray *instanceMethods;
@property (nonatomic, strong) NSMutableArray *instanceVars;
+(TTClass*)classFromKT:(KTClass*)thisClass;
@end
@interface TTMethod : NSObject
@property (nonatomic, strong) NSString *name;
@end
@implementation TTFoundation
@synthesize name,classes;
-(NSString*)name{
    return self.foundation.name;
}
-(NSMutableArray*)classes{
    if (classes == nil) {
        classes = [NSMutableArray new];
        [self.foundation enumerateClasses:^(KTClass *aClass) {
            [classes addObject:[TTClass classFromKT:aClass]];
        }];
    }
    return classes;
}
@end
@implementation TTClass
+(TTClass*)classFromKT:(KTClass*)ktClass;{
    TTClass *newClass = [TTClass new];
    
    newClass.name = ktClass.name;
    newClass.classMethods = [NSMutableArray new];
    newClass.instanceMethods = [NSMutableArray new];
    newClass.instanceVars = [NSMutableArray new];
    [ktClass enumerateInterface:^(KTMethod *aClassMethod, KTMethod *anIntanceMethod, KTVariable *anInstanceVariable) {
        if (aClassMethod) {
            [newClass.classMethods addObject:aClassMethod];
        }
        if (anIntanceMethod) {
            [newClass.instanceMethods addObject:anIntanceMethod];
        }
        if (anInstanceVariable) {
            [newClass.instanceVars addObject:anInstanceVariable];
        }
    }];
    
    
    return newClass;
}
@end

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
    [self test10];
    
}

-(void)test12{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}



// Method description
-(void)test11{
    TTFoundation *f = [TTFoundation new];
    KTFoundation *sourceF = [KTFoundation foundationFromDisk:@"TestFoundation"];
    f.foundation = sourceF;
    TTClass *s = [TTClass classFromKT:[sourceF classWithName:@"AAString"]];
    
}


// Class description
-(void)test10{
    TTFoundation *f = [TTFoundation new];
    KTFoundation *sourceF = [KTFoundation foundationFromDisk:@"TestFoundation"];
    f.foundation = sourceF;
    KTClass *c = [sourceF classWithName:@"NSString"];
    //TTClass *s = [TTClass classFromKT:[sourceF classWithName:@"AAString"]];
    
    //SCClassDefinition *classDef = [SCClassDefinition definitionWithClass:[TTMethod class] propertyNamesString:@"Message:(name); Comments:(comment);Returns:(returns); Params:(params)"];
    SCClassDefinition *methodDef = [SCClassDefinition definitionWithClass:[KTMethod class] propertyNamesString:@"Message:(name); Comments:(comment);Returns:(returns); Params:(params)"];
    SCClassDefinition *returnsDef = [SCClassDefinition definitionWithClass:[KTType class] propertyNamesString:@"Message:(name)"];
    
    
    SCPropertyDefinition *translationsPropertyDef = [methodDef propertyDefinitionWithName:@"returns"];
    translationsPropertyDef.type = SCPropertyTypeObjectSelection;
    translationsPropertyDef.attributes = [SCObjectAttributes attributesWithObjectDefinition:returnsDef];

    //SCClassDefinition *classDef = [SCClassDefinition definitionWithClass:[KTClass class] autoGeneratePropertyDefinitions:YES];
    
    
    SCClassDefinition *stringDef = [SCClassDefinition definitionWithClass:[NSString class] propertyNamesString:@"Content:(description)"];
    
    SCArrayOfObjectsSection *titleSection = [SCArrayOfObjectsSection
                                               sectionWithHeaderTitle:@"Class Name" items:[NSMutableArray arrayWithArray:@[c.name]] itemsDefinition:stringDef];
    [self.tableViewModel addSection:titleSection];
    
    
    NSMutableArray *classMethods = [NSMutableArray new];
    NSMutableArray *instanceMethods = [NSMutableArray new];
    NSMutableArray *instanceVars = [NSMutableArray new];
    [c enumerateInterface:^(KTMethod *aClassMethod, KTMethod *anIntanceMethod, KTVariable *anInstanceVariable) {
        if (aClassMethod) {
            [classMethods addObject:aClassMethod];
        }
        if (anIntanceMethod) {
            [instanceMethods addObject:anIntanceMethod];
        }
        if (anInstanceVariable) {
            [instanceVars addObject:anInstanceVariable];
        }
    }];

    
    
    SCArrayOfObjectsSection *classMethodsSection = [SCArrayOfObjectsSection
                                               sectionWithHeaderTitle:@"Class Methods" items:classMethods itemsDefinition:methodDef];
    classMethodsSection.cellActions.detailTableViewModel = ^SCTableViewModel*(SCTableViewCell *cell, NSIndexPath *indexPath)
    {
        SCTableViewModel *detailModel = nil;
        if([cell isKindOfClass:[SCArrayOfObjectsCell class]])
        {
            detailModel = [SCArrayOfObjectsModel modelWithTableView:nil];
        }
        
        return detailModel;
    };
    [self.tableViewModel addSection:classMethodsSection];

    SCArrayOfObjectsSection *instanceMethodsSection = [SCArrayOfObjectsSection
                                                    sectionWithHeaderTitle:@"Instance Methods" items:instanceMethods itemsDefinition:methodDef];
    [self.tableViewModel addSection:instanceMethodsSection];

    SCArrayOfObjectsSection *instanceVarsSection = [SCArrayOfObjectsSection
                                                    sectionWithHeaderTitle:@"Instance Vars" items:instanceVars itemsDefinition:methodDef];
    [self.tableViewModel addSection:instanceVarsSection];
}


-(void)test9{
    RootClass *root = [RootClass new];
    root.name = @"Section Title";
    SubClass *subLevel1A = [SubClass new];
    SubClass *subLevel1B = [SubClass new];
    SubClass *subLevel1C = [SubClass new];
    subLevel1A.name = @"level 1, object A";
    subLevel1B.name = @"level 1, object B";
    subLevel1C.name = @"level 1, object C";
    SubClass *subLevel2A =[SubClass new];
    subLevel2A.name = @"level 2, object A";
    subLevel2A.arrayOfSubObjects = [NSMutableArray arrayWithArray:@[@"string1",@"string2",@"string3"]];
    subLevel1A.arrayOfSubObjects = [NSMutableArray arrayWithArray:@[subLevel2A]];
    root.arrayOfSubObjects = [NSMutableArray arrayWithArray:@[subLevel1A, subLevel1B, subLevel1C]];
    

    SCClassDefinition *subClassDef = [SCClassDefinition definitionWithClass:[SubClass class] propertyNamesString:@"Name:(name);Sub Classes:(arrayOfSubObjects)"];
    SCClassDefinition *stringClassDef = [SCClassDefinition definitionWithClass:[NSString class] propertyNamesString:@"description"];
    

    SCArrayOfObjectsSection *classesSection = [SCArrayOfObjectsSection
                                               sectionWithHeaderTitle:root.name items:root.arrayOfSubObjects itemsDefinition:subClassDef];
    [self.tableViewModel addSection:classesSection];
}



-(void)test8{
    TTFoundation *f = [TTFoundation new];
    KTFoundation *sourceF = [KTFoundation foundationFromDisk:@"TestFoundation"];
    f.foundation = sourceF;

    //self.tableView.autoAssignDelegateForDetailModels = YES;
    self.tableViewModel.delegate = self;
    
    SCClassDefinition *foundationDef = [SCClassDefinition definitionWithClass:[TTClass class] propertyNamesString:@"Name:(name);Class Methods:(classMethods)"];
    SCClassDefinition *classDef = [SCClassDefinition definitionWithClass:[KTMethod class] propertyNamesString:@"Message:(name, description); Comments:(comment);Returns:(returns); Params:(params)"];

    
    SCPropertyDefinition *classMethodsPropertyDef = [foundationDef propertyDefinitionWithName:@"classMethods"];
    
	//classMethodsPropertyDef.type = SCPropertyTypeTextView;
	//classMethodsPropertyDef.attributes = [SCArrayOfObjectsAttributes attributesWithObjectDefinition:classDef
    //                                                                        allowAddingItems:YES
    //                                                                      allowDeletingItems:YES
    //                                                                               allowMovingItems:YES];
    
    
    
    
/*

    SCArrayOfObjectsSection *classSection
    = [SCArrayOfObjectsSection sectionWithHeaderTitle:(NSString *)@"helloClasses"
                                                items:f.classes
                                      itemsDefinition:(SCDataDefinition *)classDef];
    
    classSection.itemsAccessoryType = UITableViewCellAccessoryNone;
    classSection.sectionActions.detailTableViewModelForRowAtIndexPath = ^SCTableViewModel*(SCTableViewSection *section, NSIndexPath *indexPath)    {
        
        SCTableViewModel *detailModel = [SCTableViewModel new];
        
        return detailModel;
    };
*/


    
    SCArrayOfObjectsSection *classesSection = [SCArrayOfObjectsSection
                                               sectionWithHeaderTitle:f.name items:f.classes itemsDefinition:foundationDef];
    [self.tableViewModel addSection:classesSection];
}

-(void)test7{
    SCClassDefinition *testDef = [SCClassDefinition definitionWithClass:[KTClass class] propertyNamesString:@"Name:(name);Class Functions:(methodsTemp)"];
    //[testDef add]

    
    SCPropertyDefinition *descPropertyDef = [testDef propertyDefinitionWithName:@"methodsTemp"];
    descPropertyDef.type = SCPropertyTypeCustom;

    
    KTFoundation *f = [KTFoundation foundationFromDisk:@"TestFoundation"];

    
    __block NSMutableArray *classes = [NSMutableArray new];
    [f enumerateClasses:^(KTClass *aClass) {
        [classes addObject:aClass];
    }];
    
    SCArrayOfObjectsSection *classesSection = [SCArrayOfObjectsSection
                                              sectionWithHeaderTitle:f.name items:classes itemsDefinition:testDef];
    [self.tableViewModel addSection:classesSection];
}

-(void)test6{
    // Add tweets section
    SCClassDefinition *testDef = [SCClassDefinition definitionWithClass:[Task class] propertyNamesString:@"TaskDetails:(name,description,category,dueDate);TaskStatus:(completed)"];
    //SCPropertyDefinition *namePropertyDef = [testDef propertyDefinitionWithName:@"name"];
    
    NSMutableArray *testArray = [NSMutableArray new];
    
    [testArray addObject:[Task new]];
    
    
    SCArrayOfObjectsSection *tweetsSection = [SCArrayOfObjectsSection
                                              sectionWithHeaderTitle:@"hello" items:testArray itemsDefinition:testDef];


    [self.tableViewModel addSection:tweetsSection];
}

-(void)test5{
    self.title = @"Tasks";
    self.navigationBarType = SCNavigationBarTypeAddLeftEditRight;
    // Create the Task definition
    SCClassDefinition *taskDef = [SCClassDefinition definitionWithClass:[Task class] propertyNamesString:@"TaskDetails:(name,description,category,dueDate);TaskStatus:(completed)"];
    SCPropertyDefinition *namePropertyDef = [taskDef propertyDefinitionWithName:@"name"];
    
    namePropertyDef.required = TRUE;
    
    SCPropertyDefinition *descPropertyDef = [taskDef propertyDefinitionWithName:@"description"];
    
    descPropertyDef.type = SCPropertyTypeTextView;
    
    SCPropertyDefinition *categoryPropertyDef = [taskDef propertyDefinitionWithName:@"category"];
    
    categoryPropertyDef.type = SCPropertyTypeSelection;
    
    NSArray *categoryItems = [NSArray arrayWithObjects:@"Home", @"Work", @"Other", nil];
    
    categoryPropertyDef.attributes = [SCSelectionAttributes attributesWithItems:categoryItems allowMultipleSelection:NO allowNoSelection:NO];
    
    
    // Create the Tasks array
    
    NSMutableArray *tasksArray = [NSMutableArray array];
    
    // Create the section for the tasks array
    
    SCArrayOfObjectsSection *tasksSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil items:tasksArray itemsDefinition:taskDef];
    
    tasksSection.addButtonItem = self.addButton;
    
    tasksSection.placeholderCell = [SCTableViewCell cellWithText:@"No tasks yet!" textAlignment:NSTextAlignmentCenter];
    
    [self.tableViewModel addSection:tasksSection];
}

-(void)test4{
    // Create the Task definition
    
    SCClassDefinition *taskDef = [SCClassDefinition definitionWithClass:[Task class] propertyNamesString:@"name;description;category;dueDate;completed;array;dictionary"];
    
    SCPropertyDefinition *descPropertyDef = [taskDef propertyDefinitionWithName:@"description"];
    descPropertyDef.type = SCPropertyTypeTextView;
    
    SCPropertyDefinition *categoryPropertyDef = [taskDef propertyDefinitionWithName:@"category"];
    categoryPropertyDef.type = SCPropertyTypeSelection;
    NSArray *categoryItems = [NSArray arrayWithObjects:@"Home",@"Work", @"Other", nil];
    categoryPropertyDef.attributes = [SCSelectionAttributes attributesWithItems:categoryItems
                                                         allowMultipleSelection:NO
                                                               allowNoSelection:NO];

    SCPropertyDefinition *temp = [taskDef propertyDefinitionWithName:@"array"];
    temp.type = SCPropertyTypeArrayOfObjects;

    
    // Create an instance of the Task object
    Task *myTask = [[Task alloc] init];
    [myTask.array addObject:@"hellp"];
    // Create the section(s) for the task object
    [self.tableViewModel generateSectionsForObject:myTask
                                    withDefinition:taskDef];
}

-(void)test3{
    // Create the Task definition
    SCClassDefinition *taskDef = [SCClassDefinition
                                  definitionWithClass:[Task class]
                                  propertyNamesString:@"name;description;category;dueDate;completed"]
    ;
    // Create an instance of the Task object
    Task *myTask = [[Task alloc] init];
    // Create the section(s) for the task object
    [self.tableViewModel generateSectionsForObject:myTask
                                    withDefinition:taskDef];
}

-(void)test2{
    NSMutableArray *items = [NSMutableArray arrayWithObjects:@"One",
                             @"Two", @"Three!", nil];
    SCArrayOfStringsSection *stringsSection = [SCArrayOfStringsSection
                                              sectionWithHeaderTitle:@"Strings Section" items:items];
    [self.tableViewModel addSection:stringsSection];
}

- (void)test1
{

    // Create the TaskStep definition
    SCClassDefinition *classDef = [SCClassDefinition
                                   definitionWithClass:[KTClass class]
                                   autoGeneratePropertyDefinitions:YES];
    [classDef propertyDefinitionWithName:@"name;classesTemp;classMethods;instanceMethods;instanceVars"].type = SCPropertyTypeTextView;
    
    
    KTFoundation *f = [KTFoundation foundationFromDisk:@"TestFoundation"];
    
    SCClassDefinition *foundationDef = [SCClassDefinition
                                  definitionWithClass:[KTFoundation class]
                                  propertyNamesString:@"name;classesTemp;classes;description;name"];

    SCPropertyDefinition *classesPropertyDef = [foundationDef propertyDefinitionWithName:@"classesTemp"];
    classesPropertyDef.type = SCPropertyTypeArrayOfObjects;
    classesPropertyDef.attributes = [SCSelectionAttributes
                                      attributesWithItems:f.classesTemp allowMultipleSelection:NO
                                      allowNoSelection:NO];

    __block NSMutableArray *classes = [NSMutableArray new];
    [f enumerateClasses:^(KTClass *aClass) {
        [classes addObject:aClass];
    }];
    SCArrayOfObjectsSection *tasksSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil items:classes
                                             itemsDefinition:classesPropertyDef];

/*

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

@class Task;
-(void)sampleCode{
    // Create the Task definition
    SCClassDefinition *taskDef = [SCClassDefinition
                                  definitionWithClass:[NSString class]
                                  propertyNamesString:@"name;description;category;dueDate;completed"];
    
    SCPropertyDefinition *descPropertyDef = [taskDef
                                             propertyDefinitionWithName:@"description"];
    descPropertyDef.type = SCPropertyTypeTextView;
    SCPropertyDefinition *categoryPropertyDef = [taskDef
                                                 propertyDefinitionWithName:@"category"];
    categoryPropertyDef.type = SCPropertyTypeSelection;
    NSArray *categoryItems = [NSArray arrayWithObjects:@"Home",
                              @"Work", @"Other", nil];
    categoryPropertyDef.attributes = [SCSelectionAttributes
                                      attributesWithItems:categoryItems allowMultipleSelection:NO
                                      allowNoSelection:NO];
    // Create an instance of the Task object
    Task *myTask = [[NSString alloc] init];
    // Create the section(s) for the task object
    [self.tableViewModel generateSectionsForObject:myTask
                                    withDefinition:taskDef];
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


@implementation Task
@synthesize name, description, category, dueDate, completed;
- (id)init {
    self = [super init];
    if(self)
    {
        name = nil;
        description = nil;
        category = nil;
        dueDate = nil;
        completed = FALSE;
    }
    return self;
}
@end

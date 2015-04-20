//
//  SMREditCostBenefitViewController.m
//  SMARTRecovery
//
//  Created by Aaron Schachter on 3/30/15.
//  Copyright (c) 2015 smartrecovery.org. All rights reserved.
//

#import "SMREditCostBenefitViewController.h"
#import "SMRLeftMenuViewController.h"
#import "SMRCostBenefitViewController.h"
#import "SMRCostBenefitItemViewController.h"
#import "SMRViewControllerHelper.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

@interface SMREditCostBenefitViewController ()

@property (strong, nonatomic) NSArray *typeOptions;
@property (strong, nonatomic) NSString *costBenefitType;
@property (strong, nonatomic) NSString *descActivity;
@property (strong, nonatomic) NSString *descSubstance;
@property (strong, nonatomic) NSString *op;
@property (strong, nonatomic) NSString *placeholderActivity;
@property (strong, nonatomic) NSString *placeholderSubstance;

@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *titleDescLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)trashTapped:(id)sender;

@end

@implementation SMREditCostBenefitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;

    _typeOptions = @[@"The substance", @"The activity"];

    // Activity help text:
    _descActivity = @"e.g. Procrastinating, gambling, over-eating, etc.";
    _placeholderActivity = @"Activity name";

    // Substance help text:
    _descSubstance = @"e.g. Alcohol, nicotine, sugar, etc.";
    _placeholderSubstance = @"Substance name";

    if (self.costBenefit != nil) {
        self.op = @"update";
        self.title = @"Edit CBA";
        self.titleTextField.text = self.costBenefit.title;
        self.costBenefitType = self.costBenefit.type;
    }
    else {
        self.saveButton.enabled = NO;
        self.op = @"insert";
        self.title = @"New CBA";
        self.costBenefitType = @"substance";
        self.navigationController.toolbarHidden = YES;
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    }
    [self setHelpText:self.costBenefitType];
    [self.titleTextField addTarget:self
                            action:@selector(editingChanged:)
                  forControlEvents:UIControlEventEditingChanged];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.costBenefit.type isEqualToString:@"activity"]) {
        [self.typePicker selectRow:1 inComponent:0 animated:YES];
        [self.typePicker reloadComponent:0];
    }
}

-(void) editingChanged:(id)sender {
    self.saveButton.enabled = YES;
    if ([self.titleTextField.text length] < 3) {
        self.saveButton.enabled = NO;
    }
}

- (void)setHelpText:(NSString *)type {
    if ([type isEqualToString:@"activity"]) {
        self.titleTextField.placeholder = self.placeholderActivity;
        self.titleDescLabel.text = self.descActivity;
    }
    else {
        self.titleTextField.placeholder = self.placeholderSubstance;
        self.titleDescLabel.text = self.descSubstance;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row == 0) {
        self.costBenefitType = @"substance";
    }
    else {
        self.costBenefitType = @"activity";

    }
    [self setHelpText:self.costBenefitType];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _typeOptions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _typeOptions[row];
}

- (IBAction)cancelTapped:(id)sender {
    // If new CostBenefit:
    if ([self.op isEqualToString:@"insert"]) {

        // Delete the newly created CostBenefit.
        [self.context deleteObject:self.costBenefit];

        // Redirect to home screen.
        [SMRViewControllerHelper presentHome:self context:self.context];
    }
    // Else redirect to CostBenefit VC.
    else {
        [SMRViewControllerHelper presentCostBenefit:self.costBenefit viewController:self context:self.context];
    }
}

- (IBAction)saveTapped:(id)sender {

    // If new CostBenefit:
    if ([self.op isEqualToString:@"insert"]) {
        self.costBenefit = [SMRCostBenefit createCostBenefitInContext:self.context];
        // Redirect to the CostBenefitItem Nav VC to create new item.
//        UINavigationController *destNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"costBenefitItemNavigationController"];
//        SMRCostBenefitItemViewController *destVC = (SMRCostBenefitItemViewController *)destNavVC.topViewController;
//        destVC.context = self.context;
//        destVC.costBenefit = self.costBenefit;
//        [self presentViewController:destNavVC animated:YES completion:nil];

    }
    // Else redirect to CostBenefit VC.
    else {
 //       [SMRViewControllerHelper presentCostBenefit:self.costBenefit viewController:self context:self.context];
    }
    self.costBenefit.title = self.titleTextField.text;
    self.costBenefit.type = self.costBenefitType;
    NSError *error;
    [self.context save:&error];
    UINavigationController *costBenefitNavVC = [self.storyboard instantiateViewControllerWithIdentifier:@"costBenefitNavigationController"];
    SMRCostBenefitViewController *costBenefitVC = ( SMRCostBenefitViewController *)costBenefitNavVC.topViewController;
    [costBenefitVC setDrawer:self.drawer];
    [costBenefitVC setCostBenefit:self.costBenefit];
    [costBenefitVC setContext:self.context];
    [self.drawer setCenterViewController:costBenefitNavVC withCloseAnimation:YES completion:nil];

}

- (IBAction)trashTapped:(id)sender {
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Delete this CBA?"
                                 message:@"All items will be deleted as well. This cannot be undone."
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Delete"
                         style:UIAlertActionStyleDestructive
                         handler:^(UIAlertAction * action)
                         {
                             [view dismissViewControllerAnimated:YES completion:nil];
                             [self.context deleteObject:self.costBenefit];
                             [SMRViewControllerHelper presentHome:self context:self.context];
                             NSError *error;
                             [self.context save:&error];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];

                             }];


    [view addAction:ok];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end

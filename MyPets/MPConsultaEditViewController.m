//
//  MPConsultaEditViewController.m
//  MyPets
//
//  Created by HP Developer on 25/12/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPConsultaEditViewController.h"
#import "MPCoreDataService.h"
#import "MPLibrary.h"
#import "MPLembretes.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MPAds.h"

@interface MPConsultaEditViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (weak, nonatomic) IBOutlet UITextField *editData;
@property (weak, nonatomic) IBOutlet UITextField *editHora;
@property (weak, nonatomic) IBOutlet UITextField *editLembreteTipo;
@property (weak, nonatomic) IBOutlet UITextField *editNotas;

@end

@implementation MPConsultaEditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLS(@"Editar");
    self.navigationItem.title = self.title;
    
    self.editData.placeholder         = NSLS(@"placeholderPetData");
    self.editHora.placeholder         = NSLS(@"placeholderPetHora");
    self.editLembreteTipo.placeholder = NSLS(@"placeholderLembrete");
    self.editNotas.placeholder        = NSLS(@"placeholderNotas");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self carregarTeclados];
    
    [self createBannerView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Consulta Edit Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self requestBanner:kBanner_Edits];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self atualizarPagina];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Métodos
- (void)atualizarPagina
{
    if ([[MPCoreDataService shared] consultaSelected]) {
        Consulta *consulta = [[MPCoreDataService shared] consultaSelected];
        
        
        if (consulta.cData) {
            self.editData.text = [MPLibrary date:consulta.cData
                                                toFormat:NSLS(@"dd.MM.yyyy")];
            self.editHora.text = [MPLibrary date:consulta.cData
                                                toFormat:NSLS(@"hh:mm a")];
        }
        
        self.editLembreteTipo.text = consulta.cLembrete;
        self.editNotas.text        = consulta.cObs;
    }
}

- (void)carregarTeclados
{
    Consulta *consulta = nil;
    if ([[MPCoreDataService shared] consultaSelected]) {
        consulta = [[MPCoreDataService shared] consultaSelected];
    }
    
    UITextField *__editData = self.editData;
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    UITextField *__editHora = self.editHora;
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    UITextField *__editLembreteTipo = self.editLembreteTipo;
    [self.editLembreteTipo setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteTipo]];
    UITextField *__editNotas = self.editNotas;
    [self.editNotas setInputAccessoryView:[self returnToolBarToDismiss:&__editNotas]];
    
    
    
    //Data
    UIDatePicker *datePicker1 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker1 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker1 setDatePickerMode:UIDatePickerModeDate];
    [datePicker1 addTarget:self
                    action:@selector(datePickerValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [datePicker1 setTag:1];
    if (consulta) {
        [datePicker1 setDate:consulta.cData ? consulta.cData : [NSDate date]];
    }else{
        [datePicker1 setDate:[NSDate date]];
    }
    [self.editData setInputAccessoryView:[self returnToolBarToDismiss:&__editData]];
    [self.editData setInputView:datePicker1];
    
    //Hora
    UIDatePicker *datePicker2 = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker2 setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePicker2 setDatePickerMode:UIDatePickerModeTime];
    [datePicker2 addTarget:self
                    action:@selector(datePickerValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [datePicker2 setTag:1];
    if (consulta) {
        [datePicker2 setDate:consulta.cData ? consulta.cData : [NSDate date]];
    }else{
        [datePicker2 setDate:[NSDate date]];
    }
    [self.editHora setInputAccessoryView:[self returnToolBarToDismiss:&__editHora]];
    [self.editHora setInputView:datePicker2];
    
    
    UIPickerView *pickerViewLembrete = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [pickerViewLembrete setDelegate:self];
    [pickerViewLembrete setDataSource:self];
    [pickerViewLembrete setTag:1];
    [self.editLembreteTipo setInputAccessoryView:[self returnToolBarToDismiss:&__editLembreteTipo]];
    [self.editLembreteTipo setInputView:pickerViewLembrete];
}

- (UIToolbar *)returnToolBarToDismiss:(UITextField **)textField
{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:*textField action:@selector(resignFirstResponder)];
    [barButton setStyle:UIBarButtonItemStyleDone];
    [barButton setTitle:@"Ok"];
    
    UIBarButtonItem *barSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar setItems:[NSArray arrayWithObjects:barSpace,barButton, nil]];
    
    return toolbar;
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillShow:(NSNotification *)notification
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 264, self.tableView.scrollIndicatorInsets.right);
    [self.tableView setScrollIndicatorInsets:edge];
    [self.tableView setContentInset:edge];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 0, self.tableView.scrollIndicatorInsets.right);
    [self.tableView setScrollIndicatorInsets:edge];
    [self.tableView setContentInset:edge];
}

#pragma mark - IBActions
- (IBAction)barButtonRightTouched:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"%@ %@?",NSLS(@"Deseja apagar"),NSLS(@"Consulta")];
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title
                                                        delegate:self
                                               cancelButtonTitle:NSLS(@"Cancelar")
                                          destructiveButtonTitle:NSLS(@"Apagar")
                                               otherButtonTitles:nil];
    
    [sheet setTag:1];
    [sheet showFromBarButtonItem:self.barButtonRight animated:YES];
}

- (IBAction)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    if (datePicker.tag == 1) {
        self.editData.text = [MPLibrary date:datePicker.date
                                    toFormat:NSLS(@"dd.MM.yyyy")];
        self.editHora.text = [MPLibrary date:datePicker.date
                                    toFormat:NSLS(@"hh:mm a")];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self keyboardWillShow:nil];
    UIView *view = [[[textField superview] superview] superview];
    if ([view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)view;
        [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    Consulta *consulta = [[MPCoreDataService shared] consultaSelected];
    BOOL loadAll = FALSE;
    BOOL loadNotify = FALSE;
    
    if (textField == self.editData) {
        [consulta setCData:[(UIDatePicker *)self.editData.inputView date]];
        [(UIDatePicker *)self.editHora.inputView setDate:consulta.cData];
        loadNotify = YES;
    }else if (textField == self.editHora){
        [consulta setCData:[(UIDatePicker *)self.editHora.inputView date]];
        [(UIDatePicker *)self.editData.inputView setDate:consulta.cData];
        loadNotify = YES;
    }else if (textField == self.editLembreteTipo){
        [consulta setCLembrete:self.editLembreteTipo.text];
        loadNotify = YES;
    }else if (textField == self.editNotas){
        [consulta setCObs:self.editNotas.text];
    }
    
    [MPCoreDataService saveContext];
    if (loadAll) {
        [[MPCoreDataService shared] loadAllPets];
    }
    
    if (loadNotify) {
        [[MPLembretes shared] scheduleNotification:consulta];
    }
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: { return NSLS(@"Data e Hora"); }
            break;
        case 1: { return NSLS(@"Lembrete"); }
            break;
        case 2: { return NSLS(@"Notas"); }
            break;
    }
    
    return @"";
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[MPLembretes shared] arrayLembretes].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[MPLembretes shared] arrayLembretes] objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.editLembreteTipo.text = [[[MPLembretes shared] arrayLembretes] objectAtIndex:row];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Deletar"     // Event category (required)
                                                                  action:@"Deletar Consulta"  // Event action (required)
                                                                   label:@"Deletar Consulta"          // Event label
                                                                   value:nil] build]];
            
            [[MPCoreDataService shared] deleteConsultaSelected];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
}
@end

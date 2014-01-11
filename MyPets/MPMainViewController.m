//
//  MPMainViewController.m
//  MyPets
//
//  Created by Henrique Morbin on 25/10/13.
//  Copyright (c) 2013 Henrique Morbin. All rights reserved.
//

#import "MPMainViewController.h"
#import "MPLibrary.h"
#import "MPCellMainPet.h"
#import "MPCoreDataService.h"
#import "Animal.h"
#import "MPAnimations.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PKSyncManager.h"
#import "Appirater.h"
#import "LKBadgeView.h"
#import "UIFlatColor.h"

@interface MPMainViewController ()
{
    BOOL CALLBACK_LOCAL;
    int DIV;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;

@end

@implementation MPMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
#warning Pendencias
    //2.0
    //Ok - Ads
    //Ok - Parse Notification
    //Ok - GoogleAnalytics
    //Ok - AppIRater
    
    //2.1.0
    //---Publicacao
    //Prints da app stora melhor com gatos
    //Melhor descricao com reviews, mídia e posicoes
    //Free e Pago -ATENCAO, tem que duplicar appirater, remover ads, analytics
    //Add Frances, Italiano, Espanhol
    //---Desenvolvimento
    //Tela de Configuração com link para app pago para tirar propagandas
    //Teste quando atualizar dropbox o q fazer com os pets sendo atualizados
    //Peso
    //Gráfico
    //Analytics Track - Dropbox connect e desconnect
    //Analytics Track - Peso
    //Analytics Track - e pageview nas configuracoes (todos os abouts) e lembretes
    //Criar um track ou PageView também para os status do SKStore Clicou e Carregou
    //---Oks
    //Ok - About Me (versao, novidades, pagina do face, mais apps, email de contato)
    //Ok - Alterar imagem do clock
    //Ok - Badge na collection do numero de upcoming
    //Ok - Lembretes Programados
    //Ok - Ordem por nome
    //Ok - redimensionar fotos ao salvar
    //Ok - Tradução da tela configuracoes
    //Ok - Diminuicão do tamanho do banco interno
    //Ok - Foto de vermífugo padrao
    //Ok - Correção de bug do Evento Lembretes
    //Ok - Melhorar sombra
    //Ok - Evento significante ao add pet Appirater
    //Ok - Dropbox
    //Ok - iAds
    //Ok - FIX - nao salvar foto padrao nas vacinas e vermifugos
    //Ok - FIX - limpar sem animal
    //Ok - redimensionar fotos na entrada
    
    
    
    //Later
    //iPad
    //Instagram
    //Tela Pet UpComing
    //Alterar a ordem da lista
    //Selecionar Collection ou Lista
    
    //Events
    //Ok - Telas
    //Ok - Add com total de itnes
    //Ok - Delecoes 
    //Ok - Fotos
    //Ok - Lembretes
    //Dropbox connect e desconnect
    //Peso
    //Event track e pageview nas configuracoes e lembretes
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title                 = NSLS(@"Meus Pets");
    self.navigationItem.title  = self.title;
    
    
    
    [self.collection setBackgroundColor:[UIColor clearColor]];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell2"];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell3"];
    [self.collection setAllowsSelection:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackPetsCompleted:) name:MTPSNotificationPets object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxNotification:) name:PKSyncManagerDatastoreStatusDidChangeNotification object:nil];
    
    
    DIV = 1;
    CALLBACK_LOCAL = FALSE;
    [[MPCoreDataService shared] loadAllPets];
    
    [self loadBanner];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)viewDidAppear:(BOOL)animated
{
    ((MPCoreDataService *)[MPCoreDataService shared]).animalSelected = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)barButtonRightTouched:(id)sender
{
    [[MPCoreDataService shared] setAnimalSelected:[[MPCoreDataService shared] newAnimal]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Adicionar"     // Event category (required)
                                                          action:@"Novo Pet"  // Event action (required)
                                                           label:@"Novo Pet"          // Event label
                                                           value:[NSNumber numberWithInt:[[MPCoreDataService shared] arrayPets].count]] build]];
    
    [Appirater userDidSignificantEvent:YES];
    
    [self performSegueWithIdentifier:@"petViewController" sender:nil];
}

- (IBAction)barButtonLeftTouched:(id)sender
{
    [self performSegueWithIdentifier:@"configuracaoViewController" sender:nil];
    
}

#pragma mark - Métodos
- (void)loadBanner
{
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [bannerView_ setFrame:CGRectMake(0, self.view.frame.size.height-bannerView_.frame.size.height, bannerView_.frame.size.width, bannerView_.frame.size.height)];
    
    bannerView_.adUnitID = @"ca-app-pub-8687233994493144/1806932365";
    

    bannerView_.rootViewController = self;
    bannerView_.delegate = self;
    [self.view addSubview:bannerView_];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"d739ce5a07568c089d5498568147e06a", @"7229798c8732c56f536549c0f153d45f"];
    request.testing = NO;
    [bannerView_ loadRequest: request];
}

- (void)configurarBadge:(LKBadgeView *)badge
{
    [badge setBadgeColor:[UIColor colorWithRed:255.0f/255.0f green:202.0f/255.0f blue:80.0f/255.0f alpha:1.0f]];
    [badge setShadowColor:[UIFlatColor blueColor]];
    [badge setHorizontalAlignment:LKBadgeViewHorizontalAlignmentCenter];
    [badge setWidthMode:LKBadgeViewWidthModeStandard];
    [badge setHeightMode:LKBadgeViewHeightModeStandard];
    [badge setFont:[UIFont systemFontOfSize:12.0f]];
    
}

#pragma mark - GADBannerDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    UIEdgeInsets edge =  UIEdgeInsetsMake(self.collection.scrollIndicatorInsets.top, self.collection.scrollIndicatorInsets.left, bannerView_.frame.size.height*1, self.collection.scrollIndicatorInsets.right);
    [self.collection setScrollIndicatorInsets:edge];
    [self.collection setContentInset:edge];
}

#pragma mark - UICollectionView
#pragma mark  UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    int count = [[[MPCoreDataService shared] arrayPets] count];
    
    if (count <= 2) {
        DIV = 1;
    }else if (count <= 6){
        DIV = 2;
    }else{
        DIV = 3;
    }
    
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"cell%d",DIV] forIndexPath:indexPath];
    
    MPCellMainPet *cellView = (MPCellMainPet *)[cell viewWithTag:10];
    LKBadgeView *badge = (LKBadgeView *)[cell viewWithTag:20];
    if (!cellView) {
        cellView = [[MPCellMainPet alloc] initWithDiv:DIV andWidth:self.collection.frame.size.width];
        [cellView setTag:10];
        [cell addSubview:cellView];
    }
    
    if (!badge) {
        CGRect badgeRect;
        switch (DIV) {
            case 1:
                badgeRect = CGRectMake(cell.frame.size.width-60, -4, 60, 60);
                break;
            case 2:
                badgeRect = CGRectMake(cell.frame.size.width-40, -2, 36, 36);
                break;
            case 3:
                badgeRect = CGRectMake(cell.frame.size.width-32, -6, 30, 30);
                break;
                
            default:
                break;
        }
        badge = [[LKBadgeView alloc] initWithFrame:badgeRect];
        [badge setTag:20];
        [self configurarBadge:badge];
        [cell addSubview:badge];
    }
    
    
    Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
    [cellView.imagemPet setImage:[animal getFoto]];
    [cellView.labelNome setText:[animal getNome]];
    
    int upcoming = [animal getUpcomingTotal];
    if (upcoming > 0) {
        [badge setText:[NSString stringWithFormat:@"%d", upcoming]];
        [badge setHidden:NO];
    }else{
        [badge setHidden:YES];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPCellMainPet *cellView = (MPCellMainPet *)[[self.collection cellForItemAtIndexPath:indexPath] viewWithTag:10];
    
    [MPAnimations animationPressDown:cellView];
    
    Animal *animal = [[[MPCoreDataService shared] arrayPets] objectAtIndex:indexPath.row];
    [[MPCoreDataService shared] setAnimalSelected:animal];
    
    [self performSegueWithIdentifier:@"petViewController" sender:nil];
}


#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float w = self.collection.frame.size.width;
    
    return CGSizeMake((w/DIV), (w/DIV));
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 4);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - MTNotifications
- (void)callbackPetsCompleted:(NSNotification *)notification
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MTPSNotificationPets object:nil];
    
    CALLBACK_LOCAL = TRUE;
    
    if (notification.userInfo) {
        NSLog(@"error: %s", __PRETTY_FUNCTION__);
    }else{
        [self.collection reloadData];
    }
}

- (void)dropboxNotification:(NSNotification *)notification
{
    if (notification.userInfo) {
        NSLog(@"%s Notification: %@", __PRETTY_FUNCTION__, notification.userInfo);
        [[MPCoreDataService shared] loadAllPets];
    }
}


@end

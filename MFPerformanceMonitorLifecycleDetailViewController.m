//
//  MFPerformanceMonitorLifecycleDetailViewController.m
//  MakeFriends
//
//  Created by Vic on 15/8/16.
//
//

#import "MFPerformanceMonitorLifecycleDetailViewController.h"
#import "MFPerformanceMonitorManager.h"
#import "MFPerformanceModel.h"
#import "PNChart.h"
#include "LibXL/libxl.h"

#if _INTERNAL_MFPM_ENABLED

@interface MFPerformanceMonitorLifecycleDetailViewController ()

@property (nonatomic, strong) MFControllerPerformanceInfo *controllerPerformanceInfo;
@property (nonatomic, weak)   PNLineChart *lineChart;

@end

@implementation MFPerformanceMonitorLifecycleDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self inits];
}

- (void)inits
{
    [self initDatas];
    [self initViews];
}

- (void)initDatas
{
    _controllerPerformanceInfo = [[MFPerformanceMonitorManager sharedManager].performanceModel.lifecyclePerformanceDict objectForKey:_controllerName];
}

- (void)initViews
{
    [self initNavis];
    self.view.backgroundColor = [UIColor whiteColor];
    
    PNLineChart *lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 60)];
    [self.view addSubview:lineChart];
    _lineChart = lineChart;
    
    lineChart.yLabelFormat = @"%1.1f";
    lineChart.backgroundColor = [UIColor clearColor];
    lineChart.showCoordinateAxis = YES;
    
    NSMutableArray<MFPerformanceInfo *> *didloadPerformance = _controllerPerformanceInfo.didloadPerformance;
    [lineChart setXLabels:[didloadPerformance valueForKeyPath:@"intervalSeconds"]];

    PNLineChartData *didloadMemChartData = [PNLineChartData new];
    didloadMemChartData.dataTitle = @"ViewDidLoad增加的内存(MB)";
    didloadMemChartData.color = PNFreshGreen;
    didloadMemChartData.itemCount = didloadPerformance.count;
    didloadMemChartData.inflexionPointStyle = PNLineChartPointStyleCircle;
    didloadMemChartData.getData = ^(NSUInteger index){
        CGFloat memoryUsage = didloadPerformance[index].memoryUsage;
        return [PNLineChartDataItem dataItemWithY:memoryUsage];
    };
    
    NSMutableArray<MFPerformanceInfo *> *deallocPerformance = _controllerPerformanceInfo.deallocPerformance;
    PNLineChartData *deallocMemChartData = [PNLineChartData new];
    deallocMemChartData.dataTitle = @"Dealloc后变化内存(MB)";
    deallocMemChartData.color = PNRed;
    deallocMemChartData.itemCount = deallocPerformance.count;
    deallocMemChartData.inflexionPointStyle = PNLineChartPointStyleCircle;
    deallocMemChartData.getData = ^(NSUInteger index){
        CGFloat memoryUsage = deallocPerformance[index].memoryUsage;
        return [PNLineChartDataItem dataItemWithY:memoryUsage];
    };
    BOOL hasDeallocPerformanceData = deallocPerformance.count > 0;
    
    NSMutableArray<MFPerformanceInfo *> *totloadPerformance = _controllerPerformanceInfo.totloadPerformance;
    PNLineChartData *totloadMemChartData = [PNLineChartData new];
    totloadMemChartData.dataTitle = @"APP总内存(MB)";
    totloadMemChartData.color = PNYellow;
    totloadMemChartData.itemCount = totloadPerformance.count;
    totloadMemChartData.inflexionPointStyle = PNLineChartPointStyleCircle;
    totloadMemChartData.getData = ^(NSUInteger index){
        CGFloat memoryUsage = totloadPerformance[index].memoryUsage;
        return [PNLineChartDataItem dataItemWithY:memoryUsage];
    };
    
    lineChart.chartData = hasDeallocPerformanceData ? @[didloadMemChartData,deallocMemChartData,totloadMemChartData] : @[didloadMemChartData,totloadMemChartData];
    [lineChart strokeChart];
    
    self.lineChart.legendStyle = PNLegendItemStyleStacked;
    self.lineChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    self.lineChart.legendFontColor = [UIColor blackColor];
    UIView *legend = [self.lineChart getLegendWithMaxWidth:[UIScreen mainScreen].bounds.size.width];
    [legend setFrame:CGRectMake(30, [UIScreen mainScreen].bounds.size.height - 64 - 60, legend.frame.size.width, 60)];
    [self.view addSubview:legend];
}

- (void)initNavis
{
    self.title = _controllerName;
}

@end


#endif
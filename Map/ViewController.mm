//
//  ViewController.m
//  Map
//
//  Created by yons on 15/5/18.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "ViewController.h"

#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件
#import <BaiduMapAPI/BMKMapView.h>//只引入所需的单个头文件
@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UIGestureRecognizerDelegate,BMKGeoCodeSearchDelegate>
{
    BMKMapView* _mapView;
    BMKLocationService* _locService;
    UIButton* startBtn;
    UIButton* stopBtn;
    UIButton* followingBtn;
    UIButton* followHeadBtn;
    UILabel *label;
    BMKGeoCodeSearch *_geoCodeSearch;

    bool isGeoSearch;

}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_mapView];
    
//    //初始化BMKLocationService
//    _locService = [[BMKLocationService alloc]init];
//    _locService.delegate = self;

    _geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    //初始化逆地理编码类
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self addCustomGestures];//添加自定义的手势
    
    _locService = [[BMKLocationService alloc]init];
    [followHeadBtn setEnabled:NO];
    [followingBtn setAlpha:0.6];
    [followingBtn setEnabled:NO];
    [followHeadBtn setAlpha:0.6];
    [stopBtn setEnabled:NO];
    [stopBtn setAlpha:0.6];
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    _locService = [[BMKLocationService alloc]init];
    [followHeadBtn setEnabled:NO];
    [followingBtn setAlpha:0.6];
    [followingBtn setEnabled:NO];
    [followHeadBtn setAlpha:0.6];
    [stopBtn setEnabled:NO];
    [stopBtn setAlpha:0.6];
    
    label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    label.text=@"1234567890";
    label.textAlignment=NSTextAlignmentCenter;
    label.numberOfLines=0;
    [self.view addSubview:label];
    
    startBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    startBtn.backgroundColor=[UIColor orangeColor];
    startBtn.frame=CGRectMake(self.view.frame.size.width/4*0, 64, self.view.frame.size.width/4, 49);
    startBtn.tag=0;
    [startBtn setTitle:@"定位" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    followingBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    followingBtn.backgroundColor=[UIColor orangeColor];
    followingBtn.frame=CGRectMake(self.view.frame.size.width/4*1, 64, self.view.frame.size.width/4, 49);
    followingBtn.tag=1;
    [followingBtn setTitle:@"跟随" forState:UIControlStateNormal];
    [followingBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:followingBtn];
    
    followHeadBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    followHeadBtn.backgroundColor=[UIColor orangeColor];
    followHeadBtn.frame=CGRectMake(self.view.frame.size.width/4*2, 64, self.view.frame.size.width/4, 49);
    followHeadBtn.tag=2;
    [followHeadBtn setTitle:@"罗盘" forState:UIControlStateNormal];
    [followHeadBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:followHeadBtn];
    
    stopBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopBtn.backgroundColor=[UIColor orangeColor];
    stopBtn.frame=CGRectMake(self.view.frame.size.width/4*3, 64, self.view.frame.size.width/4, 49);
    stopBtn.tag=3;
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];


    

}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geoCodeSearch.delegate = self;

}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;

}
-(void)btnClick:(UIButton *)btn
{
    if (btn.tag==0) {
        NSLog(@"进入普通定位态");
        [_locService startUserLocationService];
//        _mapView.showsUserLocation = NO;//先关闭显示的定位图层
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = YES;//显示定位图层
        [startBtn setEnabled:NO];
        [startBtn setAlpha:0.6];
        [stopBtn setEnabled:YES];
        [stopBtn setAlpha:1.0];
        [followHeadBtn setEnabled:YES];
        [followHeadBtn setAlpha:1.0];
        [followingBtn setEnabled:YES];
        [followingBtn setAlpha:1.0];
    }
    if (btn.tag==1) {
        NSLog(@"进入跟随态");

        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;
    }
    if (btn.tag==2) {
        NSLog(@"进入罗盘态");
        
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
        _mapView.showsUserLocation = YES;
    }
    if (btn.tag==3) {
        NSLog(@"停止定位");

        [_locService stopUserLocationService];
        _mapView.showsUserLocation = NO;
        [stopBtn setEnabled:NO];
        [stopBtn setAlpha:0.6];
        [followHeadBtn setEnabled:NO];
        [followHeadBtn setAlpha:0.6];
        [followingBtn setEnabled:NO];
        [followingBtn setAlpha:0.6];
        [startBtn setEnabled:YES];
        [startBtn setAlpha:1.0];
    }
    
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alert show];
    alert = nil;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: click blank");
}

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"map view: double click");
}

#pragma mark - 添加自定义的手势（若不自定义手势，不需要下面的代码）

- (void)addCustomGestures {
    /*
     *注意：
     *添加自定义手势时，必须设置UIGestureRecognizer的属性cancelsTouchesInView 和 delaysTouchesEnded 为NO,
     *否则影响地图内部的手势处理
     */
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.cancelsTouchesInView = NO;
    doubleTap.delaysTouchesEnded = NO;
    
    [self.view addGestureRecognizer:doubleTap];
    
    /*
     *注意：
     *添加自定义手势时，必须设置UIGestureRecognizer的属性cancelsTouchesInView 和 delaysTouchesEnded 为NO,
     *否则影响地图内部的手势处理
     */
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.delaysTouchesEnded = NO;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [_mapView addGestureRecognizer:singleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap {
    /*
     *do something
     */
    NSLog(@"my handleSingleTap");
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)theDoubleTap {
    /*
     *do something
     */
    NSLog(@"my handleDoubleTap");
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    //    BMKGeoCodeSearch *_geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    //    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    //    //需要逆地理编码的坐标位置
    //    reverseGeoCodeOption.reverseGeoPoint = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    //     [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    //    label.text=[NSString stringWithFormat:@"lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    NSLog(@"%@",[NSString stringWithFormat:@"lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude]);
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    isGeoSearch = false;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
//    BMKGeoCodeSearch *_geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
//    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
//    //需要逆地理编码的坐标位置
//    reverseGeoCodeOption.reverseGeoPoint = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
//     [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    label.text=[NSString stringWithFormat:@"lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    NSLog(@"%@",[NSString stringWithFormat:@"lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude]);
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@",result);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"反向地理编码";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        label.text=[NSString stringWithFormat:@"%@",showmeg];
//        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//        [myAlertView show];
    }
}
/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

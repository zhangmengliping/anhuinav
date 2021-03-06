//
//  FNDetailViewController.m
//  FoodNav
//
//  Created by aa on 16/6/7.
//  Copyright © 2016年 xxcao. All rights reserved.
//

#import "FNDetailViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "CAppService.h"
@interface FNDetailViewController ()<MAMapViewDelegate>
{
    MAMapView *_mapView;
    BOOL iscollect;
    BOOL isallScreen;
}
@end

@implementation FNDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //配置用户Key
    //        [AMapNaviServices sharedServices].apiKey =@"90a6b42e298d22c2ca28a5638adfbbfc";
    self.title = @"粮仓详情";
    UIBarButtonItem *tmpbarButtonItem = [[UIBarButtonItem alloc] init];
    tmpbarButtonItem.title = NullString;
    self.navigationItem.backBarButtonItem = tmpbarButtonItem;
    [AMapServices sharedServices].apiKey = @"90a6b42e298d22c2ca28a5638adfbbfc";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)-20, 420)];
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
//    [_mapView addGestureRecognizer:tapGes];
    
    _mapView.delegate = self;
    [self.fnmapView addSubview:_mapView];
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    setViewCorner(self.navButton, 5);
    iscollect = NO;
    
    [[CAppService sharedInstance] liangDetail_request:self.liangId success:^(NSDictionary *model) {
        [self setUIdata:model];
    } failure:^(CAppServiceError *error) {
        
    }];
    if([Common isEmptyString:user_id]){
        self.collButton.hidden = YES;
    }
    isallScreen = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUIdata:(NSDictionary *)dataDic
{
    if([dataDic.allKeys containsObject:@"data"]){
        NSDictionary *model = dataDic[@"data"];
        if([model.allKeys containsObject:@"graindepot_name"]){
            self.name.text = model[@"graindepot_name"];
            CGRect r = [self.name.text boundingRectWithSize:CGSizeMake(Screen_Width, Screen_Height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.name.font} context:nil];
            SetFrameByXPos(self.collButton.frame, 134+r.size.width+10);
        }
        
        if([model.allKeys containsObject:@"address"])
            self.address.text = model[@"address"];
        
        if([model.allKeys containsObject:@"store_count"]){
            if([model[@"store_count"] integerValue] != 0){
            self.cangHouseAllNum.text = [NSString stringWithFormat:@"%@ 个",model[@"store_count"]];
            self.cangHouseAllNum1.text = [NSString stringWithFormat:@"%@ 个",model[@"store_count"]];
            }
        }
        
        if([model.allKeys containsObject:@"warehouse_count"]){
            if([model[@"warehouse_count"] integerValue] != 0){
            self.aoHouseAllNum.text = [NSString stringWithFormat:@"%d 个",[model[@"warehouse_count"] integerValue]];
            self.aoHouseAllNum1.text = [NSString stringWithFormat:@"%d 个",[model[@"warehouse_count"] integerValue]];
            }
        }
        
        if([model.allKeys containsObject:@"oilcan_count"]){
            if([model[@"oilcan_count"] integerValue] != 0){
            self.youguanAllnumber.text = [NSString stringWithFormat:@"%d 个",[model[@"oilcan_count"] integerValue]];
            self.youguanAllnumber1.text =  [NSString stringWithFormat:@"%d 个",[model[@"oilcan_count"] integerValue]];
            }
        }
        
        if([model.allKeys containsObject:@"store_design_capacity"]){
            if([model[@"store_design_capacity"] integerValue] != 0){
                if(![model[@"store_design_capacity"] isEqualToString:@".0000"]){
                    self.designAllcapacity.text =  [NSString stringWithFormat:@"%d 吨",[model[@"store_design_capacity"] integerValue]];
                }
            }
        }
        
        if([model.allKeys containsObject:@"oilcan_design_capacity"]){
            if([model[@"oilcan_design_capacity"] integerValue] != 0){
                if(![model[@"oilcan_design_capacity"] isEqualToString:@".0000"]){
                    self.youkuanDesignAll.text = [NSString stringWithFormat:@"%d 吨",[model[@"oilcan_design_capacity"] integerValue]];
                }
            }
        }
        
        
        if([model.allKeys containsObject:@"enterprise_name"])
            self.enterpriseName.text = model[@"enterprise_name"];
        
        if([model.allKeys containsObject:@"longitude"] && [model.allKeys containsObject:@"latitude"]){
            self.lbsSign.text = [NSString stringWithFormat:@"%@, %@",model[@"longitude"],model[@"latitude"]];
            
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake([model[@"latitude"] doubleValue], [model[@"longitude"] doubleValue]);
            pointAnnotation.title = model[@"graindepot_name"];
            pointAnnotation.subtitle = model[@"address"];
            [_mapView addAnnotation:pointAnnotation];
            _mapView.centerCoordinate =  CLLocationCoordinate2DMake([model[@"latitude"] doubleValue], [model[@"longitude"] doubleValue]);
        }
        if([model.allKeys containsObject:@"isCollected"]){
            if([model[@"isCollected"] integerValue] == 1){
                [self.collButton setImage:Image(@"fnalcollecticon") forState:UIControlStateNormal];
                iscollect = YES;
            }
        }
        if([model.allKeys containsObject:@"distance"])
            self.distancelab.text = [NSString stringWithFormat:@"%.1f km",[model[@"distance"] floatValue]/1000];
 
    }
 
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view
{

}
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

}
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(!isallScreen){
    SetFrameByYPos(self.mymapView.frame, 0);
    SetFrameByHeight(self.mymapView.frame,Screen_Height-tabBar_Height-default_NavigationHeight_iOS7);
    SetFrameByHeight(self.fnmapView.frame,Screen_Height-tabBar_Height-default_NavigationHeight_iOS7-50);
    SetFrameByHeight(_mapView.frame,Screen_Height-tabBar_Height-default_NavigationHeight_iOS7-50);
        isallScreen = YES;
    }
    else{
        SetFrameByYPos(self.mymapView.frame, 420);
        SetFrameByHeight(self.mymapView.frame,470);
        SetFrameByHeight(self.fnmapView.frame,420);
        SetFrameByHeight(_mapView.frame,420);
        isallScreen = NO;
    }
}
- (IBAction)navigateBtnClick:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",@"粮仓位置", 39.989631, 117.481018];
    str=[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * myURL_APP_A =[[NSURL alloc] initWithString:str];
    NSLog(@"%@",myURL_APP_A);
    //    if ([[UIApplication sharedApplication] canOpenURL:myURL_APP_A]) {
    [[UIApplication sharedApplication] openURL:myURL_APP_A];
    //    }
    //    else{
    //        Alert(@"请您先安装高德地图");
    //    }
}
- (IBAction)collectBtnClick:(id)sender
{
    if(iscollect){
        [[CAppService sharedInstance] collectLiang_request:user_id warehouse_id:self.liangId isdelte:1 success:^(NSDictionary *model) {
            if([model.allKeys containsObject:@"msg"]){
                if([model[@"msg"] isEqualToString:@"00007"]){
                    [self.collButton setImage:Image(@"fnuncollecticon") forState:UIControlStateNormal];
                    iscollect = !iscollect;
                }
            }
        } failure:^(CAppServiceError *error) {
        }];
    }
    else{
        [[CAppService sharedInstance] collectLiang_request:user_id warehouse_id:self.liangId isdelte:0 success:^(NSDictionary *model) {
            if([model[@"msg"] isEqualToString:@"00001"]){
                [self.collButton setImage:Image(@"fnalcollecticon") forState:UIControlStateNormal];
                iscollect = !iscollect;
//                NSArray *tmparr = UserDefaultsGet(UserDefaultKey_Collect);
//                if(tmparr.count == 0){
//                    NSMutableArray *arr = [];
//                }
//                UserDefaultsSave(, UserDefaultKey_Collect)
            }
        } failure:^(CAppServiceError *error) {
        }];
    }
}
@end

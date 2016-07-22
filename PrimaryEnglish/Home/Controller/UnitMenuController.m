//
//  UnitMenuController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/22.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "UnitMenuController.h"

@interface UnitMenuController ()

@end

@implementation UnitMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.unitArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"unit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.unitArray[indexPath.row];
    return cell;
}
@end

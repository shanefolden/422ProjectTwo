
//  viewController.h
//  422Proj2
//
//  Created by Siqi wang on 5/26/20.
//  Copyright © 2020 Siqi wang. All rights reserved.
//

@interface LoginViewController : UIViewController
//account
@property(nonatomic,strong) UITextField *account;
//password
@property(nonatomic,strong) UITextField *password;
//login button
@property(nonatomic,strong) UIButton *loginButton;
//tie to account
@property(nonatomic,strong) UIButton *bindUser;
@end


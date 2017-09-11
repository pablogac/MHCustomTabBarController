/*
 * Copyright (c) 2013 Martin Hartl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHCustomTabBarController.h"

#import "MHTabBarSegue.h"

NSString *const MHCustomTabBarControllerViewControllerChangedNotification = @"MHCustomTabBarControllerViewControllerChangedNotification";
NSString *const MHCustomTabBarControllerViewControllerAlreadyVisibleNotification = @"MHCustomTabBarControllerViewControllerAlreadyVisibleNotification";

@implementation MHCustomTabBarController {
    NSMutableDictionary *_viewControllersByIdentifier;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    self.controllerArray = [[NSMutableArray alloc]init];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
    if (self.childViewControllers.count < 1) {
        [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
    }
     */
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.destinationViewController.view.frame = self.container.bounds;
}



#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    
    self.oldViewController = segue.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
        [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    for (UIButton *aButton in self.buttons) {
        [aButton setSelected:NO];
    }
        
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerChangedNotification object:nil]; 

    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerAlreadyVisibleNotification object:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
   [[_viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [_viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
  
}

-(void)moveTo:(UIViewController*)controller addVC:(BOOL)addVC
{
    //remove old viewController
    if (self.container.subviews.count) {
        [self.oldViewController viewWillDisappear:NO];
        [self.oldViewController willMoveToParentViewController:nil];
        [self.oldViewController.view removeFromSuperview];
        [self.oldViewController removeFromParentViewController];
    }
    self.oldViewController = controller;
    if(addVC)
        [self.controllerArray addObject:controller];

    [controller viewWillAppear:NO];
    controller.view.frame = self.container.bounds;
    [self addChildViewController:controller];
    [self.container addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

-(NSMutableArray*)getViewControllers{
    return self.controllerArray;
}

-(UIViewController*)getOldViewControllers{
    return self.oldViewController;
}

@end

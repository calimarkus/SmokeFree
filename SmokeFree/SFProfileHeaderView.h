//
//  SFProfileHeaderView.h
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <UIKit/UIKit.h>

@interface SFProfileHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBoxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBoxImageView;

@property (weak, nonatomic) IBOutlet UIView *rightBox;
@property (weak, nonatomic) IBOutlet UIView *bottomBox;

@end

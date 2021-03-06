////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2018 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

#import "BKPubKeyDetailsViewController.h"
#import "UIDevice+DeviceName.h"
#import "BKDefaults.h"
#import "Blink-Swift.h"

@interface BKPubKeyDetailsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *comments;
@end

@implementation BKPubKeyDetailsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  _name.text = _pubkey.ID;
  _comments.text = [NSString stringWithFormat:@"%@@%@", [BKDefaults defaultUserName] , [UIDevice getInfoTypeFromDeviceName:BKDeviceInfoTypeDeviceName]];
}

- (void)viewWillDisappear:(BOOL)animated
{
  if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
    [self performSegueWithIdentifier:@"unwindFromDetails" sender:self];
  }
  [super viewWillDisappear:animated];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if (textField == _name) {
    if ([string isEqualToString:@" "]) {
      return NO;
    }
  }

  return YES;
}

- (IBAction)copyPublicKey:(id)sender
{
  UIPasteboard *pb = [UIPasteboard generalPasteboard];
  [pb setString:_pubkey.publicKey];
}

- (IBAction)copyPrivateKey:(id)sender
{
  [[LocalAuth shared] authenticateWithCallback:^(BOOL success) {
    if (success) {
      UIPasteboard *pb = [UIPasteboard generalPasteboard];
      [pb setString:_pubkey.privateKey];
    }
  } reason:@"to copy private key to clipboard."];
}

- (IBAction)sharePublicKey:(id)sender
{
  NSArray *sharingItems = @[_pubkey];

  UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
  activityController.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                               UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard,
                                               UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                               UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                               UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
  activityController.popoverPresentationController.barButtonItem = sender;
  [self presentViewController:activityController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"unwindFromDetails"]) {
    if (_name.text.length && ![_name.text isEqualToString:_pubkey.ID]) {
      _pubkey.ID = _name.text;
      [BKPubKey saveIDS];
    }
  }
}

@end

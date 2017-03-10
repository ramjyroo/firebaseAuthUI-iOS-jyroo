//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "FUIAccountSettingsOperationDeleteAccount.h"

#import "FUIAccountSettingsOperation_Internal.h"
#import "FUIAccountSettingsOperationForgotPassword.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationDeleteAccount

- (void)execute:(BOOL)showDialog {
  if (showDialog) {
    [self showDeleteAccountDialog];
  } else {
    [self showDeleteAccountViewWithPassword];
  }
}

- (void)showDeleteAccountDialog {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    if (![provider.providerID isEqualToString:FIREmailPasswordAuthProviderID]) {
      [self reauthenticateWithProvider:provider.providerID actionHandler:^{
        [self showDeleteAccountView];
      }];
    } else {
      [self showDeleteAccountViewWithPassword];
    }
  }
                      alertTitle:FUILocalizedString(kStr_DeleteAccountConfimationTitle)
                    alertMessage:FUILocalizedString(kStr_DeleteAccountBody)
                alertCloseButton:FUILocalizedString(kStr_Cancel)];
}

- (void)showDeleteAccountViewWithPassword {
  __block FUIStaticContentTableViewCell *passwordCell =
  [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Password)
                                        action:nil
                                          type:FUIStaticContentTableViewCellTypePassword];
  FUIStaticContentTableViewContent *contents =
      [FUIStaticContentTableViewContent contentWithSections:@[
   [FUIStaticContentTableViewSection sectionWithTitle:nil cells:@[passwordCell]],
  ]];

  NSString *message = FUILocalizedString(kStr_DeleteAccountConfirmationMessage);
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc]
          initWithContents:contents
                 nextTitle:FUILocalizedString(kStr_Delete)
                nextAction:^{ [self deleteCurrentAccountWithPassword:passwordCell.value]; }
                headerText:message
                footerText:FUILocalizedString(kStr_ForgotPassword)
              footerAction:^{
        [FUIAccountSettingsOperationForgotPassword executeOperationWithDelegate:_delegate];
      }];
  // TODO: add localization
  controller.title = FUILocalizedString(kStr_DeleteAccountControllerTitle);
  [_delegate pushViewController:controller];
}

- (void)showDeleteAccountView {
  NSString *message = FUILocalizedString(kStr_DeleteAccountConfirmationMessage);
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:nil
                                                          nextTitle:FUILocalizedString(kStr_Delete)
                                                         nextAction:^{
        [self onDeleteAccountViewNextAction];
      }
                                                         headerText:message];
  // TODO: add localization
  controller.title = FUILocalizedString(kStr_DeleteAccountControllerTitle);
  [_delegate pushViewController:controller];

}


- (void)onDeleteAccountViewNextAction {
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:FUILocalizedString(kStr_DeleteAccountConfimationTitle)
                                      message:FUILocalizedString(kStr_ActionCantBeUndone)
                               preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *deleteAction =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_DeleteAccountControllerTitle)
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * _Nonnull action) {
       [self deleteCurrentAccount];
      }];
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:FUILocalizedString(kStr_Cancel)
                               style:UIAlertActionStyleCancel
                             handler:nil];
  [alertController addAction:deleteAction];
  [alertController addAction:action];
  [_delegate presentViewController:alertController];

}

- (void)deleteCurrentAccountWithPassword:(NSString *)password {
  [self reauthenticateWithPassword:password actionHandler:^{
    [self deleteCurrentAccount];
  }];
}

- (void)deleteCurrentAccount {
  [_delegate incrementActivity];
  [_delegate.auth.currentUser deleteWithCompletion:^(NSError * _Nullable error) {
    [_delegate decrementActivity];
    [self finishOperationWithError:error];
    if (!error) {
      [_delegate presentBaseController];
    }
  }];
}

@end

NS_ASSUME_NONNULL_END
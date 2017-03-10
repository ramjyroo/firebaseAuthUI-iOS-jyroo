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

#import "FUIAccountSettingsOperationUpdateName.h"

#import "FUIAccountSettingsOperation_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FUIAccountSettingsOperationUpdateName

- (void)execute:(BOOL)showDialog {
  __block FUIStaticContentTableViewCell *cell =
      [FUIStaticContentTableViewCell cellWithTitle:FUILocalizedString(kStr_Name)
                                             value:_delegate.auth.currentUser.displayName
                                            action:nil
                                              type:FUIStaticContentTableViewCellTypeInput];
  FUIStaticContentTableViewContent *contents =
    [FUIStaticContentTableViewContent contentWithSections:@[
      [FUIStaticContentTableViewSection sectionWithTitle:nil
                                                   cells:@[cell]],
    ]];

  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:contents
                                                          nextTitle:FUILocalizedString(kStr_Save)
                                                         nextAction:^{
        [self onUpdateName:cell.value];
      }];
  controller.title = FUILocalizedString(kStr_EditNameTitle);
  [_delegate pushViewController:controller];
}

- (void)onUpdateName:(NSString *)username {
  [_delegate incrementActivity];
  FIRUserProfileChangeRequest *request = [_delegate.auth.currentUser profileChangeRequest];
  request.displayName = username;
  [request commitChangesWithCompletion:^(NSError *_Nullable error) {
    [_delegate decrementActivity];
    [self finishOperationWithError:error];
    [_delegate presentBaseController];
  }];
}

@end

NS_ASSUME_NONNULL_END
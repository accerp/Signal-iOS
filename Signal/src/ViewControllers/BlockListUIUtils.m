//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "BlockListUIUtils.h"
#import "PhoneNumber.h"
#import <SignalServiceKit/Contact.h>
#import <SignalServiceKit/OWSBlockingManager.h>

NS_ASSUME_NONNULL_BEGIN

@implementation BlockListUIUtils

+ (void)showBlockContactActionSheet:(Contact *)contact
                 fromViewController:(UIViewController *)fromViewController
                    blockingManager:(OWSBlockingManager *)blockingManager
                    completionBlock:(BlockActionCompletionBlock)completionBlock
{
    NSMutableArray<NSString *> *phoneNumbers = [NSMutableArray new];
    for (PhoneNumber *phoneNumber in contact.parsedPhoneNumbers) {
        if (phoneNumber.toE164.length > 0) {
            [phoneNumbers addObject:phoneNumber.toE164];
        }
    }
    if (phoneNumbers.count < 1) {
        [self showBlockFailedAlert:fromViewController];
        if (completionBlock) {
            completionBlock(NO);
        }
        return;
    }
    [self showBlockPhoneNumbersActionSheet:phoneNumbers
                               displayName:contact.fullName
                        fromViewController:fromViewController
                           blockingManager:blockingManager
                           completionBlock:completionBlock];
}

+ (void)showBlockPhoneNumberActionSheet:(NSString *)phoneNumber
                            displayName:(NSString *)displayName
                     fromViewController:(UIViewController *)fromViewController
                        blockingManager:(OWSBlockingManager *)blockingManager
                        completionBlock:(BlockActionCompletionBlock)completionBlock
{
    [self showBlockPhoneNumbersActionSheet:@[ phoneNumber ]
                               displayName:displayName
                        fromViewController:fromViewController
                           blockingManager:blockingManager
                           completionBlock:completionBlock];
}

+ (void)showBlockPhoneNumbersActionSheet:(NSArray<NSString *> *)phoneNumbers
                             displayName:(NSString *)displayName
                      fromViewController:(UIViewController *)fromViewController
                         blockingManager:(OWSBlockingManager *)blockingManager
                         completionBlock:(BlockActionCompletionBlock)completionBlock
{
    OWSAssert(phoneNumbers.count > 0);
    OWSAssert(displayName.length > 0);
    OWSAssert(fromViewController);
    OWSAssert(blockingManager);

    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"BLOCK_LIST_BLOCK_TITLE_FORMAT",
                                                     @"A format for the 'block user' action sheet title."),
                                displayName];

    UIAlertController *actionSheetController =
        [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *unblockAction = [UIAlertAction
        actionWithTitle:NSLocalizedString(@"BLOCK_LIST_BLOCK_BUTTON", @"Button label for the 'block' button")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [self blockPhoneNumbers:phoneNumbers
                                displayName:displayName
                         fromViewController:fromViewController
                            blockingManager:blockingManager];
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                }];
    [actionSheetController addAction:unblockAction];

    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"TXT_CANCEL_TITLE", @"")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              if (completionBlock) {
                                                                  completionBlock(NO);
                                                              }
                                                          }];
    [actionSheetController addAction:dismissAction];

    [fromViewController presentViewController:actionSheetController animated:YES completion:nil];
}

+ (void)blockPhoneNumbers:(NSArray<NSString *> *)phoneNumbers
              displayName:(NSString *)displayName
       fromViewController:(UIViewController *)fromViewController
          blockingManager:(OWSBlockingManager *)blockingManager
{
    OWSAssert(phoneNumbers.count > 0);
    OWSAssert(displayName.length > 0);
    OWSAssert(fromViewController);
    OWSAssert(blockingManager);

    for (NSString *phoneNumber in phoneNumbers) {
        OWSAssert(phoneNumber.length > 0);
        [blockingManager addBlockedPhoneNumber:phoneNumber];
    }

    [self showOkAlertWithTitle:NSLocalizedString(
                                   @"BLOCK_LIST_VIEW_BLOCKED_ALERT_TITLE", @"The title of the 'user blocked' alert.")
                       message:[NSString
                                   stringWithFormat:NSLocalizedString(@"BLOCK_LIST_VIEW_BLOCKED_ALERT_MESSAGE_FORMAT",
                                                        @"The message format of the 'user blocked' "
                                                        @"alert. It is populated with the "
                                                        @"blocked contact's name."),
                                   displayName]
            fromViewController:fromViewController];
}

+ (void)showUnblockPhoneNumberActionSheet:(NSString *)phoneNumber
                              displayName:(NSString *)displayName
                       fromViewController:(UIViewController *)fromViewController
                          blockingManager:(OWSBlockingManager *)blockingManager
                          completionBlock:(BlockActionCompletionBlock)completionBlock
{
    OWSAssert(phoneNumber.length > 0);
    OWSAssert(displayName.length > 0);
    OWSAssert(fromViewController);
    OWSAssert(blockingManager);

    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"BLOCK_LIST_UNBLOCK_TITLE_FORMAT",
                                                     @"A format for the 'unblock user' action sheet title."),
                                displayName];

    UIAlertController *actionSheetController =
        [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *unblockAction = [UIAlertAction
        actionWithTitle:NSLocalizedString(@"BLOCK_LIST_UNBLOCK_BUTTON", @"Button label for the 'unblock' button")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                    [BlockListUIUtils unblockPhoneNumber:phoneNumber
                                             displayName:displayName
                                      fromViewController:fromViewController
                                         blockingManager:blockingManager];
                    if (completionBlock) {
                        completionBlock(NO);
                    }
                }];
    [actionSheetController addAction:unblockAction];

    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"TXT_CANCEL_TITLE", @"")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              if (completionBlock) {
                                                                  completionBlock(YES);
                                                              }
                                                          }];
    [actionSheetController addAction:dismissAction];

    [fromViewController presentViewController:actionSheetController animated:YES completion:nil];
}

+ (void)unblockPhoneNumber:(NSString *)phoneNumber
               displayName:(NSString *)displayName
        fromViewController:(UIViewController *)fromViewController
           blockingManager:(OWSBlockingManager *)blockingManager
{
    OWSAssert(phoneNumber.length > 0);
    OWSAssert(displayName.length > 0);
    OWSAssert(fromViewController);
    OWSAssert(blockingManager);

    [blockingManager removeBlockedPhoneNumber:phoneNumber];

    [self showOkAlertWithTitle:NSLocalizedString(@"BLOCK_LIST_VIEW_UNBLOCKED_ALERT_TITLE",
                                   @"The title of the 'user unblocked' alert.")
                       message:[NSString
                                   stringWithFormat:NSLocalizedString(@"BLOCK_LIST_VIEW_UNBLOCKED_ALERT_MESSAGE_FORMAT",
                                                        @"The message format of the 'user unblocked' "
                                                        @"alert. It is populated with the "
                                                        @"blocked phone number."),
                                   displayName]
            fromViewController:fromViewController];
}

+ (void)showBlockFailedAlert:(UIViewController *)fromViewController
{
    OWSAssert(fromViewController);

    [self showOkAlertWithTitle:NSLocalizedString(@"BLOCK_LIST_VIEW_BLOCK_FAILED_ALERT_TITLE",
                                   @"The title of the 'block user failed' alert.")
                       message:NSLocalizedString(@"BLOCK_LIST_VIEW_BLOCK_FAILED_ALERT_MESSAGE",
                                   @"The title of the 'block user failed' alert.")
            fromViewController:fromViewController];
}

+ (void)showUnblockFailedAlert:(UIViewController *)fromViewController
{
    OWSAssert(fromViewController);

    [self showOkAlertWithTitle:NSLocalizedString(@"BLOCK_LIST_VIEW_UNBLOCK_FAILED_ALERT_TITLE",
                                   @"The title of the 'unblock user failed' alert.")
                       message:NSLocalizedString(@"BLOCK_LIST_VIEW_UNBLOCK_FAILED_ALERT_MESSAGE",
                                   @"The title of the 'unblock user failed' alert.")
            fromViewController:fromViewController];
}

+ (void)showOkAlertWithTitle:(NSString *)title
                     message:(NSString *)message
          fromViewController:(UIViewController *)fromViewController
{
    OWSAssert(title.length > 0);
    OWSAssert(message.length > 0);
    OWSAssert(fromViewController);

    UIAlertController *controller =
        [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:nil]];
    [fromViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Logging

+ (NSString *)tag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)tag
{
    return self.class.tag;
}

@end

NS_ASSUME_NONNULL_END

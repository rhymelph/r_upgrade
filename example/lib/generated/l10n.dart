// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Update the related`
  String get Update_the_related {
    return Intl.message(
      'Update the related',
      name: 'Update_the_related',
      desc: '',
      args: [],
    );
  }

  /// `Jump to the app store`
  String get Jump_to_the_app_store {
    return Intl.message(
      'Jump to the app store',
      name: 'Jump_to_the_app_store',
      desc: '',
      args: [],
    );
  }

  /// `Jump to the link updated`
  String get Jump_to_the_link_updated {
    return Intl.message(
      'Jump to the link updated',
      name: 'Jump_to_the_link_updated',
      desc: '',
      args: [],
    );
  }

  /// `Starting to all updates`
  String get Starting_to_all_updates {
    return Intl.message(
      'Starting to all updates',
      name: 'Starting_to_all_updates',
      desc: '',
      args: [],
    );
  }

  /// `Install all updates`
  String get Install_all_updates {
    return Intl.message(
      'Install all updates',
      name: 'Install_all_updates',
      desc: '',
      args: [],
    );
  }

  /// `Please {h1}`
  String Please_make_(Object h1) {
    return Intl.message(
      'Please $h1',
      name: 'Please_make_',
      desc: '',
      args: [h1],
    );
  }

  /// `Currently there is no ID can be installed`
  String get Currently_there_is_no_ID_can_be_installed {
    return Intl.message(
      'Currently there is no ID can be installed',
      name: 'Currently_there_is_no_ID_can_be_installed',
      desc: '',
      args: [],
    );
  }

  /// `The request is successful`
  String get The_request_is_successful {
    return Intl.message(
      'The request is successful',
      name: 'The_request_is_successful',
      desc: '',
      args: [],
    );
  }

  /// `The current ID not download`
  String get The_current_ID_not_download {
    return Intl.message(
      'The current ID not download',
      name: 'The_current_ID_not_download',
      desc: '',
      args: [],
    );
  }

  /// `After download to install`
  String get After_download_to_install {
    return Intl.message(
      'After download to install',
      name: 'After_download_to_install',
      desc: '',
      args: [],
    );
  }

  /// `Continue to update`
  String get Continue_to_update {
    return Intl.message(
      'Continue to update',
      name: 'Continue_to_update',
      desc: '',
      args: [],
    );
  }

  /// `Currently there is no ID can be upgraded`
  String get Currently_there_is_no_ID_can_be_upgraded {
    return Intl.message(
      'Currently there is no ID can be upgraded',
      name: 'Currently_there_is_no_ID_can_be_upgraded',
      desc: '',
      args: [],
    );
  }

  /// `updated`
  String get updated {
    return Intl.message(
      'updated',
      name: 'updated',
      desc: '',
      args: [],
    );
  }

  /// `Suspension of success`
  String get Suspension_of_success {
    return Intl.message(
      'Suspension of success',
      name: 'Suspension_of_success',
      desc: '',
      args: [],
    );
  }

  /// `Cancel the update`
  String get Cancel_the_update {
    return Intl.message(
      'Cancel the update',
      name: 'Cancel_the_update',
      desc: '',
      args: [],
    );
  }

  /// `Cancel the success`
  String get Cancel_the_success {
    return Intl.message(
      'Cancel the success',
      name: 'Cancel_the_success',
      desc: '',
      args: [],
    );
  }

  /// `Hot update related`
  String get Hot_update_related {
    return Intl.message(
      'Hot update related',
      name: 'Hot_update_related',
      desc: '',
      args: [],
    );
  }

  /// `Start download hot update`
  String get Start_download_hot_update {
    return Intl.message(
      'Start download hot update',
      name: 'Start_download_hot_update',
      desc: '',
      args: [],
    );
  }

  /// `For hot update`
  String get For_hot_update {
    return Intl.message(
      'For hot update',
      name: 'For_hot_update',
      desc: '',
      args: [],
    );
  }

  /// `Please click on start hot update`
  String get Please_click_on_start_hot_update {
    return Intl.message(
      'Please click on start hot update',
      name: 'Please_click_on_start_hot_update',
      desc: '',
      args: [],
    );
  }

  /// `Hot update is successful, exit the application after 3 s, please re-enter`
  String
      get Hot_update_is_successful_exit_the_application_after_3_s_please_re_enter {
    return Intl.message(
      'Hot update is successful, exit the application after 3 s, please re-enter',
      name:
          'Hot_update_is_successful_exit_the_application_after_3_s_please_re_enter',
      desc: '',
      args: [],
    );
  }

  /// `Hot update failed, please wait for update the download is complete`
  String get Hot_update_failed_please_wait_for_update_the_download_is_complete {
    return Intl.message(
      'Hot update failed, please wait for update the download is complete',
      name: 'Hot_update_failed_please_wait_for_update_the_download_is_complete',
      desc: '',
      args: [],
    );
  }

  /// `Incremental updating`
  String get Incremental_updating {
    return Intl.message(
      'Incremental updating',
      name: 'Incremental_updating',
      desc: '',
      args: [],
    );
  }

  /// `Began to download the incremental updating`
  String get Began_to_download_the_incremental_updating {
    return Intl.message(
      'Began to download the incremental updating',
      name: 'Began_to_download_the_incremental_updating',
      desc: '',
      args: [],
    );
  }

  /// `Please click on start incremental updates`
  String get Please_click_on_start_incremental_updates {
    return Intl.message(
      'Please click on start incremental updates',
      name: 'Please_click_on_start_incremental_updates',
      desc: '',
      args: [],
    );
  }

  /// `Incremental updating failed!`
  String get Incremental_updating_failed {
    return Intl.message(
      'Incremental updating failed!',
      name: 'Incremental_updating_failed',
      desc: '',
      args: [],
    );
  }

  /// `History related`
  String get History_related {
    return Intl.message(
      'History related',
      name: 'History_related',
      desc: '',
      args: [],
    );
  }

  /// `For the last time to download the ID`
  String get For_the_last_time_to_download_the_ID {
    return Intl.message(
      'For the last time to download the ID',
      name: 'For_the_last_time_to_download_the_ID',
      desc: '',
      args: [],
    );
  }

  /// `No ID last time to download`
  String get No_ID_last_time_to_download {
    return Intl.message(
      'No ID last time to download',
      name: 'No_ID_last_time_to_download',
      desc: '',
      args: [],
    );
  }

  /// `According to the last time ID escalation applications`
  String get According_to_the_last_time_ID_escalation_applications {
    return Intl.message(
      'According to the last time ID escalation applications',
      name: 'According_to_the_last_time_ID_escalation_applications',
      desc: '',
      args: [],
    );
  }

  /// `Look at the last time ID download status`
  String get Look_at_the_last_time_ID_download_status {
    return Intl.message(
      'Look at the last time ID download status',
      name: 'Look_at_the_last_time_ID_download_status',
      desc: '',
      args: [],
    );
  }

  /// `Currently there is no ID`
  String get Currently_there_is_no_ID {
    return Intl.message(
      'Currently there is no ID',
      name: 'Currently_there_is_no_ID',
      desc: '',
      args: [],
    );
  }

  /// `{h1} s after finish`
  String The_s_after_finish(Object h1) {
    return Intl.message(
      '$h1 s after finish',
      name: 'The_s_after_finish',
      desc: '',
      args: [h1],
    );
  }

  /// `Waiting for download`
  String get Waiting_for_download {
    return Intl.message(
      'Waiting for download',
      name: 'Waiting_for_download',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get Download_failed {
    return Intl.message(
      'Download failed',
      name: 'Download_failed',
      desc: '',
      args: [],
    );
  }

  /// `Download the suspended`
  String get Download_the_suspended {
    return Intl.message(
      'Download the suspended',
      name: 'Download_the_suspended',
      desc: '',
      args: [],
    );
  }

  /// `Access to resources,`
  String get Access_to_resources {
    return Intl.message(
      'Access to resources,',
      name: 'Access_to_resources',
      desc: '',
      args: [],
    );
  }

  /// `In the download`
  String get In_the_download {
    return Intl.message(
      'In the download',
      name: 'In_the_download',
      desc: '',
      args: [],
    );
  }

  /// `Download successful`
  String get Download_successful {
    return Intl.message(
      'Download successful',
      name: 'Download_successful',
      desc: '',
      args: [],
    );
  }

  /// `Download the cancel`
  String get Download_the_cancel {
    return Intl.message(
      'Download the cancel',
      name: 'Download_the_cancel',
      desc: '',
      args: [],
    );
  }

  /// `The unknown`
  String get The_unknown {
    return Intl.message(
      'The unknown',
      name: 'The_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Are already starting to all updates`
  String get Are_already_starting_to_all_updates {
    return Intl.message(
      'Are already starting to all updates',
      name: 'Are_already_starting_to_all_updates',
      desc: '',
      args: [],
    );
  }

  /// `Have begun to hot update`
  String get Have_begun_to_hot_update {
    return Intl.message(
      'Have begun to hot update',
      name: 'Have_begun_to_hot_update',
      desc: '',
      args: [],
    );
  }

  /// `Has already started to incremental updates`
  String get Has_already_started_to_incremental_updates {
    return Intl.message(
      'Has already started to incremental updates',
      name: 'Has_already_started_to_incremental_updates',
      desc: '',
      args: [],
    );
  }

  /// `Full quantity update`
  String get Full_quantity_update {
    return Intl.message(
      'Full quantity update',
      name: 'Full_quantity_update',
      desc: '',
      args: [],
    );
  }

  /// `Hot update`
  String get Hot_update {
    return Intl.message(
      'Hot update',
      name: 'Hot_update',
      desc: '',
      args: [],
    );
  }

  /// `Get Android Store`
  String get getAndroidStore {
    return Intl.message(
      'Get Android Store',
      name: 'getAndroidStore',
      desc: '',
      args: [],
    );
  }

  /// `Get Version From Android Store`
  String get getVersionFromAndroidStore {
    return Intl.message(
      'Get Version From Android Store',
      name: 'getVersionFromAndroidStore',
      desc: '',
      args: [],
    );
  }

  /// `Install Related`
  String get Install_Related {
    return Intl.message(
      'Install Related',
      name: 'Install_Related',
      desc: '',
      args: [],
    );
  }

  /// `Install Type`
  String get Install_Type {
    return Intl.message(
      'Install Type',
      name: 'Install_Type',
      desc: '',
      args: [],
    );
  }

  /// `Normal Install`
  String get Install_Type_Normal {
    return Intl.message(
      'Normal Install',
      name: 'Install_Type_Normal',
      desc: '',
      args: [],
    );
  }

  /// `Silent Install`
  String get Install_Type_Silent {
    return Intl.message(
      'Silent Install',
      name: 'Install_Type_Silent',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get Install_Type_None {
    return Intl.message(
      'None',
      name: 'Install_Type_None',
      desc: '',
      args: [],
    );
  }

  /// `Please note that this installation type requires system permissions!`
  String get Install_Type_Silent_Tip {
    return Intl.message(
      'Please note that this installation type requires system permissions!',
      name: 'Install_Type_Silent_Tip',
      desc: '',
      args: [],
    );
  }

  /// `Notification Related`
  String get Notification_Related {
    return Intl.message(
      'Notification Related',
      name: 'Notification_Related',
      desc: '',
      args: [],
    );
  }

  /// `Notification Visibility`
  String get Notification_Visibility {
    return Intl.message(
      'Notification Visibility',
      name: 'Notification_Visibility',
      desc: '',
      args: [],
    );
  }

  /// `Visible`
  String get Notification_Visibility_Visible {
    return Intl.message(
      'Visible',
      name: 'Notification_Visibility_Visible',
      desc: '',
      args: [],
    );
  }

  /// `Visible Notify Completed`
  String get Notification_Visibility_Visible_Notify_Completed {
    return Intl.message(
      'Visible Notify Completed',
      name: 'Notification_Visibility_Visible_Notify_Completed',
      desc: '',
      args: [],
    );
  }

  /// `Visible Notify Only Completion`
  String get Notification_Visibility_Visible_Notify_Only_Completion {
    return Intl.message(
      'Visible Notify Only Completion',
      name: 'Notification_Visibility_Visible_Notify_Only_Completion',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get Notification_Visibility_Hidden {
    return Intl.message(
      'Hidden',
      name: 'Notification_Visibility_Hidden',
      desc: '',
      args: [],
    );
  }

  /// `Notification Style`
  String get Notification_Style {
    return Intl.message(
      'Notification Style',
      name: 'Notification_Style',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get Notification_Style_None {
    return Intl.message(
      'None',
      name: 'Notification_Style_None',
      desc: '',
      args: [],
    );
  }

  /// `Speech/PlanTime`
  String get Notification_Style_Speech_PlanTime {
    return Intl.message(
      'Speech/PlanTime',
      name: 'Notification_Style_Speech_PlanTime',
      desc: '',
      args: [],
    );
  }

  /// `PlanTime/Speech`
  String get Notification_Style_PlanTime_Speech {
    return Intl.message(
      'PlanTime/Speech',
      name: 'Notification_Style_PlanTime_Speech',
      desc: '',
      args: [],
    );
  }

  /// `Speech`
  String get Notification_Style_Speech {
    return Intl.message(
      'Speech',
      name: 'Notification_Style_Speech',
      desc: '',
      args: [],
    );
  }

  /// `PlanTime`
  String get Notification_Style_PlanTime {
    return Intl.message(
      'PlanTime',
      name: 'Notification_Style_PlanTime',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

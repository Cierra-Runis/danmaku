// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..themeMode = $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode'])
  ..currentVersion = json['currentVersion'] as String?
  ..userDataDir = json['userDataDir'] as String?
  ..startUp = json['startUp'] as bool?;

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'currentVersion': instance.currentVersion,
      'userDataDir': instance.userDataDir,
      'startUp': instance.startUp,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

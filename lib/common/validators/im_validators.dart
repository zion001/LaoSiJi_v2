import 'package:flutter/material.dart';

/// 表单验证
class IMValidators {
  /// 用户名（账号）
  static FormFieldValidator<String> userName(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg = RegExp(r'^[A-Za-z0-9]{6,32}$'); //账号为6-32位英文字母或数字组合
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };

  /// 密码
  static FormFieldValidator<String> password(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg = RegExp(r'^[A-Za-z0-9]{6,32}$'); //密码为6-32位英文字母或数字组合
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };

  /// 昵称
  static FormFieldValidator<String> nickname(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg =
            RegExp(r'^[\u4E00-\u9FA5A-Za-z0-9]{2,32}$'); //昵称为2-32位英文字母、数字或中文组合
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };

  /// 联系人备注
  static FormFieldValidator<String> friendRemark(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg = RegExp(
            r'^[\u4E00-\u9FA5A-Za-z0-9]{2,32}$'); //联系人备注为2-32位英文字母、数字或中文组合
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };

  /// 群名称
  static FormFieldValidator<String> groupName(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg =
            RegExp(r'^[\u4E00-\u9FA5A-Za-z0-9]{1,32}$'); //群名称为1-32位英文字母、数字或中文组合
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };

  /// 群公告
  static FormFieldValidator<String> groupNotice(String str) => (v) {
        if (v?.isEmpty ?? true) {
          return null;
        }
        RegExp reg = RegExp(r'^.{2,5000}$'); //群公告不能少于2个字，不能超过5千字
        bool result = reg.hasMatch(v!);
        return result ? null : str;
      };
}

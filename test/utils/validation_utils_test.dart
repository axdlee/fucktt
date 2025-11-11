import 'package:flutter_test/flutter_test.dart';

import 'package:value_filter/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('手机号验证', () {
      test('有效手机号', () {
        expect(ValidationUtils.isValidPhone('13800138000'), isTrue);
        expect(ValidationUtils.isValidPhone('15912345678'), isTrue);
      });

      test('无效手机号', () {
        expect(ValidationUtils.isValidPhone('1380013800'), isFalse); // 位数不足
        expect(ValidationUtils.isValidPhone('138001380000'), isFalse); // 位数过多
        expect(ValidationUtils.isValidPhone('abc00138000'), isFalse); // 包含字母
        expect(ValidationUtils.isValidPhone('12800138000'), isFalse); // 开头不对
      });
    });

    group('邮箱验证', () {
      test('有效邮箱', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), isTrue);
        expect(ValidationUtils.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(ValidationUtils.isValidEmail('user+tag@example.com'), isTrue);
      });

      test('无效邮箱', () {
        expect(ValidationUtils.isValidEmail('invalidemail'), isFalse);
        expect(ValidationUtils.isValidEmail('test@'), isFalse);
        expect(ValidationUtils.isValidEmail('@example.com'), isFalse);
        expect(ValidationUtils.isValidEmail('test @example.com'), isFalse);
      });
    });

    group('密码强度验证', () {
      test('弱密码', () {
        expect(
          ValidationUtils.checkPasswordStrength('123456'),
          equals(PasswordStrength.weak),
        );
        expect(
          ValidationUtils.checkPasswordStrength('abcdef'),
          equals(PasswordStrength.weak),
        );
        expect(
          ValidationUtils.checkPasswordStrength('12345678'),
          equals(PasswordStrength.weak),
        );
      });

      test('中等强度密码', () {
        expect(
          ValidationUtils.checkPasswordStrength('abcdefgh'),
          equals(PasswordStrength.medium),
        );
        expect(
          ValidationUtils.checkPasswordStrength('Abc12345'),
          equals(PasswordStrength.medium),
        );
      });

      test('强密码', () {
        expect(
          ValidationUtils.checkPasswordStrength('Abc123456!'),
          equals(PasswordStrength.strong),
        );
        expect(
          ValidationUtils.checkPasswordStrength('MyStr0ngP@ssw0rd'),
          equals(PasswordStrength.strong),
        );
      });
    });

    group('URL验证', () {
      test('有效URL', () {
        expect(ValidationUtils.isValidUrl('https://example.com'), isTrue);
        expect(ValidationUtils.isValidUrl('http://example.com'), isTrue);
        expect(ValidationUtils.isValidUrl('https://example.com/path?param=value'), isTrue);
      });

      test('无效URL', () {
        expect(ValidationUtils.isValidUrl('not_a_url'), isFalse);
        expect(ValidationUtils.isValidUrl('ftp://example.com'), isFalse);
        expect(ValidationUtils.isValidUrl('example.com'), isFalse);
      });
    });

    group('文本验证', () {
      test('中文检测', () {
        expect(ValidationUtils.isChinese('你好世界'), isTrue);
        expect(ValidationUtils.isChinese('Hello世界'), isTrue);
        expect(ValidationUtils.isChinese('Hello'), isFalse);
      });

      test('长度验证', () {
        expect(ValidationUtils.hasMinLength('hello', 3), isTrue);
        expect(ValidationUtils.hasMinLength('hello', 10), isFalse);

        expect(ValidationUtils.hasMaxLength('hello', 10), isTrue);
        expect(ValidationUtils.hasMaxLength('hello', 3), isFalse);
      });

      test('非空验证', () {
        expect(ValidationUtils.isNotEmpty('hello'), isTrue);
        expect(ValidationUtils.isNotEmpty(''), isFalse);
        expect(ValidationUtils.isNotEmpty('   '), isFalse); // 空格算空（trim后）
        expect(ValidationUtils.isNotEmpty(null), isFalse);
        expect(ValidationUtils.isNotEmpty([]), isFalse);
        expect(ValidationUtils.isNotEmpty([1, 2, 3]), isTrue);
      });
    });

    group('数字范围验证', () {
      test('在范围内', () {
        expect(ValidationUtils.isInRange(5, 1, 10), isTrue);
        expect(ValidationUtils.isInRange(1, 1, 10), isTrue); // 边界值
        expect(ValidationUtils.isInRange(10, 1, 10), isTrue); // 边界值
      });

      test('超出范围', () {
        expect(ValidationUtils.isInRange(0, 1, 10), isFalse);
        expect(ValidationUtils.isInRange(11, 1, 10), isFalse);
      });
    });
  });
}
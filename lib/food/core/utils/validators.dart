import 'package:form_field_validator/form_field_validator.dart';

final nameValidator = MultiValidator([
  RequiredValidator(errorText: 'This field is required'),
  MinLengthValidator(2, errorText: 'Too short'),
  MaxLengthValidator(45, errorText: 'Too long'),
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Please enter a valid email'),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(6, errorText: 'Too short'),
  MaxLengthValidator(30, errorText: 'Too long'),
  PatternValidator(
    r'(?=.*?[A-Z])',
    errorText: 'Passwords must have at least one uppercase letter',
  ),
  PatternValidator(
    r'(?=.*?[a-z])',
    errorText: 'Passwords must have at least one lowercase letter',
  ),
  PatternValidator(
    r'(?=.*?[#?+.,<>?!@$%,^&*-])',
    errorText: 'Passwords must have at least one special character',
  ),
]);

final addressValidator = MultiValidator([
  RequiredValidator(errorText: 'This field is required'),
  MinLengthValidator(2, errorText: 'Address is too short'),
  MaxLengthValidator(
    500,
    errorText: 'Address cannot be more than 500 characters',
  ),
]);

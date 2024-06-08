// Model
class LoginModel {
  String _email = '';
  String _password = '';

  String get email => _email;
  String get password => _password;

  set email(String value) {
    _email = value;
  }

  set password(String value) {
    _password = value;
  }
}
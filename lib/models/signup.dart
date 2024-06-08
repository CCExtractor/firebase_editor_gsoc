// Model
class SignUpModel {
  String _name = '';
  String _email = '';
  String _password = '';

  String get name => _name;
  String get email => _email;
  String get password => _password;

  set name(String value) {
    _name = value;
  }

  set email(String value) {
    _email = value;
  }

  set password(String value) {
    _password = value;
  }
}
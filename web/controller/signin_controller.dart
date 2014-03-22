part of timetracker;

@NgController(
    selector: '[signin-controller]',
    publishAs: 'ctrl')
class SigninController {

  Router _router;
  Session _session;
  
  List<User> users = User.defaultUsers();
  
  User user;
    
  SigninController(this._router, this._session);
  
  signIn() {
    _session.user = user;
    _router.go('projects', {});
  }
}

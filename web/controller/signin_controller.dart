part of timetracker;

@NgController(
    selector: '[signin-controller]',
    publishAs: 'ctrl')
class SigninController {

  Router _router;
  LoggedUser _loggedUser;
  
  List<User> users = User.defaultUsers();
  
  User user;
    
  SigninController(this._router, this._loggedUser);
  
  signIn() {
    _loggedUser.user = user;
    _router.go('projects', {});
  }
}

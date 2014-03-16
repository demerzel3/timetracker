part of timetracker;

@NgController(
    selector: '[header-controller]',
    publishAs: 'ctrl')
class HeaderController {

  Router _router;
  LoggedUser loggedUser;
      
  HeaderController(this.loggedUser, this._router);

  signOut() {
    loggedUser.user = null;
    _router.go('signin', {});
  }
}

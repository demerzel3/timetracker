part of timetracker;

@NgController(
    selector: '[header-controller]',
    publishAs: 'ctrl')
class HeaderController {

  Router _router;
  Session session;
      
  HeaderController(this.session, this._router);

  signOut() {
    session.user = null;
    _router.go('signin', {});
  }
}

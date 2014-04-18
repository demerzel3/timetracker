part of timetracker;

class _Endpoint {
  String url;
  String name;
  _Endpoint(this.name, this.url);
}

@Controller(
    selector: '[signin-controller]',
    publishAs: 'ctrl')
class SigninController {

  Router _router;
  Session _session;
  
  List<User> users = User.defaultUsers();
  
  User user;
  List<_Endpoint> availableEndpoints = [
    new _Endpoint('(localhost)', 'http://127.0.0.1:5984'),
    new _Endpoint('BS Davide', 'http://192.168.1.11:5984'),
    new _Endpoint('BS Gabriele', 'http://192.168.230.230:5984'),
  ];
  _Endpoint endpoint;
    
  SigninController(this._router, this._session) {
    if (_session.endpointUrl != null) {
      for (_Endpoint endpoint in availableEndpoints) {
        if (endpoint.url == _session.endpointUrl) {
          this.endpoint = endpoint;
        }
      }
    }
    if (endpoint == null) {
      endpoint = availableEndpoints[0];
    }
  }
  
  signIn() {
    _session.user = user;
    _session.endpointUrl = endpoint.url;
    _router.go('projects', {});
  }
}

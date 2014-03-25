part of timetracker;

class Session {
  Store _store;
  User _user;
  String _endpointUrl;
  async.Future _loading;
  
  EventStream _endpointUrlChanged = new EventStream();
  async.Stream get endpointUrlChanged => _endpointUrlChanged.stream; 
  
  Session(this._store) {
    if (_store.isOpen) {
      _loading = _load();  
    } else {
      _loading = _store.open().then((_) => _load());
    }
  }
  
  _load() {
    // load session info from the store
    return async.Future.wait([
      // user id 
      _store.getByKey('userId').then((String storedUserId) {
        if (storedUserId == null) {
          return;
        }
        
        var users = User.defaultUsers();
        for (User u in users) {
          if (u.id == storedUserId) {
            _user = u;
            break;
          }
        }  
        
        if (_user == null) {
          _store.removeByKey('userId');
        }
      }),
      // endpoint url
      _store.getByKey('endpointUrl').then((String endpointUrl) => _endpointUrl = endpointUrl)
    ]);
  }

  async.Future isLoading() => _loading;
  
  _storeValue(String name, value) {
    if (value == null) {
      _store.removeByKey(name);
    } else {
      _store.save(value, name);
    }
  }
  
  bool get isAuthenticated => _user != null;

  User get user => _user;
  set user(User user) {
    _user = user;
    _storeValue('userId', user != null ? user.id : null);
  }
  
  String get endpointUrl => _endpointUrl;
  set endpointUrl(String endpointUrl) {
    if (_endpointUrl == endpointUrl) {
      return;
    }
    _endpointUrl = endpointUrl;
    _storeValue('endpointUrl', _endpointUrl);
    _endpointUrlChanged.signal();
  }
  
}
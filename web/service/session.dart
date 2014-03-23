part of timetracker;

class Session {
  Store _store;
  User _user;
  async.Future _loading;
  
  Session(this._store) {
    if (_store.isOpen) {
      _loading = _load();  
    } else {
      _loading = _store.open().then((_) => _load);
    }
  }
  
  _load() {
    // load session info from the store
    return _store.getByKey('userId').then((String storedUserId) {
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
    });
  }

  async.Future isLoading() => _loading;
  
  bool get isAuthenticated => _user != null;

  User get user => _user;
  
  set user(User user) {
    _user = user;
    if (user == null) {
      _store.removeByKey('userId');
    } else {
      _store.save(_user.id, 'userId');
    }
  }
  
}
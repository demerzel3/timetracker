part of timetracker;

class LoggedUser {
  static const String USERID_COOKIE_NAME = 'tt_user';
  
  Cookies _cookies;
  
  User _user;
  
  LoggedUser(this._cookies);
  
  User get user {
    var cookieUserId = _cookies[USERID_COOKIE_NAME];
    if (_user == null && cookieUserId != null) {
      var users = User.defaultUsers();
      
      for (User u in users) {
        if (u.id == cookieUserId) {
          _user = u;
          break;
        }        
      }
     
      if (_user == null) {
        _cookies[USERID_COOKIE_NAME] = null;
      }
    }
    return _user;
  }
  
  set user(User user) {
    _user = user;
    if (user == null) {
      _cookies.remove(USERID_COOKIE_NAME);
    } else {
      _cookies[USERID_COOKIE_NAME] = user.id;
    }
  }
  
  bool get isAuthenticated {
    return user != null;
  }
}
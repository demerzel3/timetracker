part of timetracker;

class User {
  String id;
  String name;
  String avatarUrl;
  
  User(this.id, this.name, this.avatarUrl);
  
  static List<User> defaultUsers() {
    return [
      new User('davide', 'Davide', 'resources/images/davide.jpg'),
      new User('elisa', 'Elisa', 'resources/images/elisa.jpg'),
      new User('gabriele', 'Gabriele', 'resources/images/gabriele.jpg')
    ];
  }
  
  String toString() {
    return 'User['+id+']';
  }
  
  bool operator ==(other) {
    if (other is User) {
      return other.id == id;
    } else {
      return false;
    }
  }
  
}

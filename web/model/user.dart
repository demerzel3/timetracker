part of timetracker;

class User {
  String id;
  String name;
  
  User(this.id, this.name);
  
  static List<User> defaultUsers() {
    return [
      new User('davide', 'Davide'),
      new User('elisa', 'Elisa'),
      new User('gabriele', 'Gabriele')
    ];
  }
  
  String toString() {
    return 'User['+id+']';
  }
}

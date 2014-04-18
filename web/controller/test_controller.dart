part of timetracker;

@Controller(
    selector: '[test-controller]',
    publishAs: 'ctrl')
class TestController {

  int _counter = 0;
  
  /*
  List<User> users = [
    new User('gabriele', 'Gabriele', null),
    new User('davide', 'Davide', null),
    new User('elisa', 'Elisa', null),    
  ];
  */
  
  List<Map<String, String>> users = [
    {'id': 'gabriele', 'name': 'Gabriele'},
    {'id': 'davide', 'name': 'Davide'},
    {'id': 'elisa', 'name': 'Elisa'},
  ];  
  
  Map<String, int> userIdIndex = {
    'gabriele': 0,
    'davide': 1,
    'elisa': 2
  };
  /*
  List<String> userIds = ['gabriele', 'davide', 'elisa'];
  List<String> userNames = ['Gabriele', 'davide', 'elisa'];
  */
  
  TestController() {
    print("prova");
  }
  
  doSomething() {
    int index = userIdIndex['gabriele'];
    var user = users[index];
    user['name'] = 'Sticazzi ' + _counter.toString();
    //user.name = 'Sticazzi ' + _counter.toString();
    print(user['name']);
    _counter++;
  }
  
}

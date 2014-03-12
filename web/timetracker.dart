library timetracker;

//@MirrorsUsed(symbols: const ['name', 'tasks', 'timings', 'id', 'user', 'date', 'duration'], override: '*')
import 'dart:html' as dom;
import 'dart:async' as async;
import 'dart:convert';
import 'dart:collection';

/* Should be used to reduce ouput size
@MirrorsUsed(targets: const[
    'angular',
    'angular.core',
    'angular.core.dom',
    'angular.filter',
    'angular.perf',
    'angular.directive',
    'angular.routing',
    'angular.core.parser',
    'perf_api',
    'NodeTreeSanitizer'
  ],
  override: '*')
import 'dart:mirrors';
*/
import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:intl/intl.dart';
import 'package:bootjack/bootjack.dart';
//import 'package:serialization/serialization.dart';

part 'auth/logged_user.dart';

part 'component/input_date_directive.dart';
part 'component/input_time_directive.dart';

part 'controller/projects_controller.dart';
part 'controller/project_controller.dart';
part 'controller/signin_controller.dart';

part 'filter/duration_filter.dart';
part 'filter/floor_filter.dart';

part 'model/project.dart';
part 'model/task.dart';
part 'model/timing.dart';
part 'model/user.dart';

part 'data/couchdb_client.dart';
part 'data/projects_client.dart';




class TTRouter {
  
  final LoggedUser _loggedUser;
  
  TTRouter(this._loggedUser);
  
  void call(Router router, ViewFactory views) {
    views.configure({
      'signin': ngRoute(
          path: '/signin',
          view: 'view/signin.html'),
    });
    /*
    router.root
      ..addRoute(
        name: 'signin',
        path: '/signin',
        enter: views('view/signin.html'))
      ..addRoute(
        name: 'project',
        path: '/projects/:projectId',
        enter: authView(router, views('view/project.html')))
      ..addRoute(
        name: 'projects',
        defaultRoute: true,
        path: '/',
        enter: authView(router, views('view/projects.html')));
    */
  }
  
  authView(Router router, ngView) {
    return (RouteEvent e) {
      if (!_loggedUser.isAuthenticated) {
        return router.go('signin', {});        
      }
      return ngView(e);
    };
  }  
}

@NgController(
    selector: '[header-controller]',
    publishAs: 'ctrl')
class HeaderController {
  Router _router;
  LoggedUser loggedUser;
  
  HeaderController(this._router, this.loggedUser);
  
  signOut() {
    loggedUser.user = null;
    _router.go('signin', {});
  }
}

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
    type(LoggedUser);
    
    type(HeaderController);
    type(ProjectsController);
    type(ProjectController);
    type(SigninController);
    
    type(DateInputDirective);
    type(TimeInputDirective);
    
    type(DurationFilter);
    type(FloorFilter);
    
    type(RouteInitializerFn, implementedBy: TTRouter);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
    
    factory(ProjectsClient, (Injector injector) {
      //return new ProjectsClient(injector.get(Http), 'http://127.0.0.1:5984');
      // http://192.168.230.230/
      return new ProjectsClient(injector.get(Http), 'http://192.168.230.230:5984');
    });
  }
}

void main() {
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}
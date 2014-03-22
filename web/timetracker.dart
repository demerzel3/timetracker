library timetracker;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'dart:convert';
import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:angular/angular.dart';
import 'package:angular/utils.dart';
import 'package:bootjack/bootjack.dart';
import 'package:event_stream/event_stream.dart';

import 'package:lawndart/lawndart.dart';

part 'auth/logged_user.dart';

part 'component/input_date_directive.dart';
part 'component/input_time_directive.dart';

part 'controller/header_controller.dart';
part 'controller/projects_controller.dart';
part 'controller/project_controller.dart';
part 'controller/signin_controller.dart';
part 'controller/test_controller.dart';

part 'data/couchdb_client.dart';
part 'data/projects_client.dart';

part 'event/change_event.dart';

part 'filter/duration_filter.dart';
part 'filter/floor_filter.dart';

part 'model/project.dart';
part 'model/task.dart';
part 'model/timing.dart';
part 'model/user.dart';
part 'model/task_timeline.dart';

part 'service/session.dart';

class TTRouter {
  
  final Session _session;
  
  TTRouter(this._session);
  
  void call(Router router, ViewFactory views) {
    router.root
      ..addRoute(
        name: 'signin',
        path: '/signin',
        enter: anonView(router, views, 'view/signin.html'))
      ..addRoute(
        name: 'project',
        path: '/projects/:projectId',
        enter: userView(router, views, 'view/project.html'))
      ..addRoute(
        name: 'projects',
        defaultRoute: true,
        path: '/',
        enter: userView(router, views, 'view/projects.html'));
  }
  
  anonView(Router router, ViewFactory views, String view) {
    return (RouteEvent e) {
      _session.isAuthenticated().then((bool isAuthenticated) {
        if (isAuthenticated) {
          router.go('projects', {});
        } else {
          views(view)(e);    
        }
      });
    };    
  }
  
  userView(Router router, ViewFactory views, String view) {
    return (RouteEvent e) {
      _session.isAuthenticated().then((bool isAuthenticated) {
        if (!isAuthenticated) {
          router.go('signin', {});
        } else {
          views(view)(e);    
        }
      });
    };    
  }  
}

class TimeTrackerModule extends Module {
  TimeTrackerModule(Store sessionStore) {
    type(LoggedUser);
    
    type(HeaderController);
    type(ProjectsController);
    type(ProjectController);
    type(SigninController);
    type(TestController);
    
    type(DateInputDirective);
    type(TimeInputDirective);
    
    type(DurationFilter);
    type(FloorFilter);
    
    factory(Session, (Injector injector) => new Session(sessionStore));
    
    type(RouteInitializerFn, implementedBy: TTRouter);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
    
    factory(ProjectsClient, (Injector injector) {
      return new ProjectsClient(injector.get(Http), 'http://127.0.0.1:5984');
      // http://192.168.230.230/
      //return new ProjectsClient(injector.get(Http), 'http://192.168.230.230:5984');
    });
  }
}

void main() {
  // open session store
  var store = new Store('timetracker', 'session');
  store.open().then((_) {
    // bootstrap angular
    ngBootstrap(module: new TimeTrackerModule(store));
  });  
}


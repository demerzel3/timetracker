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
        preEnter: _anonymousFirewall(router),
        enter: views('view/signin.html'))
      ..addRoute(
        name: 'project',
        path: '/projects/:projectId',
        preEnter: _authenticatedFirewall(router),
        enter: views('view/project.html'))
      ..addRoute(
        name: 'projects',
        defaultRoute: true,
        path: '/',
        preEnter: _authenticatedFirewall(router),
        enter: views('view/projects.html')/*userView(router, views, 'view/projects.html')*/);
  }

  /**
   * Returns a RoutePreEnterEventHandler that allows entry for authenticated users only,
   * redirecting anonymous users to "/projects"
   */  
  _authenticatedFirewall(Router router) {
    return (RoutePreEnterEvent e) {
      e.allowEnter(_session.isLoading().then((_) {
        if (!_session.isAuthenticated) {
          router.go('signin', {});
        }
        return _session.isAuthenticated;
      }));
    };
  }
  
  /**
   * Returns a RoutePreEnterEventHandler that allows entry for anonymous users only,
   * redirecting authenticated users to "/projects"
   */
  _anonymousFirewall(Router router) {
    return (RoutePreEnterEvent e) {
      e.allowEnter(_session.isLoading().then((_) {
        if (_session.isAuthenticated) {
          router.go('projects', {});
        }
        return !_session.isAuthenticated;
      }));
    };    
  }
}

class TimeTrackerModule extends Module {
  TimeTrackerModule() {
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
    
    factory(Session, (Injector injector) {
      var store = new Store('timetracker', 'session');      
      return new Session(store); 
    });
    
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
  // bootstrap angular
  ngBootstrap(module: new TimeTrackerModule());
}


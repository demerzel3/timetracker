library timetracker;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'dart:math' as Math;
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
  
  void call(Router router, RouteViewFactory views) {
    views.configure({
      'signin': ngRoute(
          path: '/signin',
          enter: _anonymousFirewall(router, views, 'view/signin.html')),
      'project': ngRoute(
          path: '/projects/:projectId',
          enter: _authenticatedFirewall(router, views, 'view/project.html')),
      'projects': ngRoute(
          defaultRoute: true,
          path: '/projects',
          enter: _authenticatedFirewall(router, views, 'view/projects.html')),
    });
  }

  /**
   * Returns a RoutePreEnterEventHandler that allows entry for authenticated users only,
   * redirecting anonymous users to "/projects"
   */  
  _authenticatedFirewall(Router router, RouteViewFactory views, String viewName) {
    return (RouteEnterEvent e) {
      if (!_session.isAuthenticated) {
        router.go('signin', {});
      } else {
        return views(viewName)(e);
      }
    };
  }
  
  /**
   * Returns a RoutePreEnterEventHandler that allows entry for anonymous users only,
   * redirecting authenticated users to "/projects"
   */
  _anonymousFirewall(Router router, RouteViewFactory views, String viewName) {
    return (RouteEnterEvent e) {
      if (_session.isAuthenticated) {
        return router.go('projects', {});
      } else {
        return views(viewName)(e);
      }
    };    
  }
}

class TimeTrackerModule extends Module {
  TimeTrackerModule(Session session) {
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
    
    value(Session, session);
        
    type(RouteInitializerFn, implementedBy: TTRouter);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
    
    factory(ProjectsClient, (Injector injector) {
      var client = new ProjectsClient(injector.get(Http), session.endpointUrl);
      
      // aggiorna server url ogni volta che cambia sessionUrl in session
      session.endpointUrlChanged.listen((_) => client.serverUrl = session.endpointUrl);      
      
      return client; 
      // http://192.168.230.230/
      //return new ProjectsClient(injector.get(Http), 'http://192.168.230.230:5984');
    });
    
  }
}

void main() {
  // load session and then bootstrap angular
  var session = new Session(new Store('timetracker', 'session'));
  session.isLoading().then((_) {
    // bootstrap angular
    ngBootstrap(module: new TimeTrackerModule(session));
  });
}


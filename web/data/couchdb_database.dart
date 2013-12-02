part of timetracker;

class CouchDbDatabase {
  Http _http;
  String _serverUrl;
  String _dbName;
  
  // TODO: should this be configured in another part of the application maybe? 
  Serialization _ser;
  
  CouchDbDatabase(this._http, this._ser, this._serverUrl, this._dbName) {
  }
  
  getAll() {
    return _http.get([_serverUrl, _dbName, '_all_docs'].join('/')).then((HttpResponse response) {
      //List rows = response.data['rows'];
      print(_ser.read(response.data['rows'][0]));
      /*
      var projects = new List<Project>.from(rows.map((rawProject) => new Project.fromRawData(rawProject)));
      print(projects);
      return projects;
      */
      //rows.forEach((element) => print((Project)element));
      //print(rows);
    });
  }
  
  get(String id, {String rev}) {
    
  }
  
  post(String id, Object data) {
    
  }
  
  put(String id, Object data) {
    
  }
  
  delete(String id) {
    
  }
  
  toString() {
    return "CouchDbDatabase[${_serverUrl}/${_dbName}]";
  }
}
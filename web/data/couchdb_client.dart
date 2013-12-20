part of timetracker;

typedef T Constructor<T>(rawData);

class CouchDbClient<Model> {
  Http _http;
  String _serverUrl;
  String _dbName;
  
  Constructor<Model> _modelConstructor;
  
  CouchDbClient(this._http, this._serverUrl, this._dbName, this._modelConstructor);
    
  async.Future<List<Model>> getAll() {
    return _http.get([_serverUrl, _dbName, '_all_docs'].join('/')).then((HttpResponse response) {
      List rows = response.data['rows'];

      // carica ogni elemento singolarmente e inserisce le Futures in una lista
      var elementFutures = rows.map((row) => get(row["id"]));
      
      return async.Future.wait(elementFutures);
      //rows.forEach((element) => print((Project)element));
      //print(rows);
    });
  }
  
  async.Future<Model> get(String id, {String rev}) {
    return _http.get([_serverUrl, _dbName, id].join('/')).then((HttpResponse response) {
      return _modelConstructor(response.data);
    });
  }
  
  async.Future<Model> post(Model model) {
    var json = JSON.encode(model); 
    return _http.post([_serverUrl, _dbName].join('/'), json).then((HttpResponse response) {
      Map data = response.data;
      if (data['ok'] == true) {
        model.id = data['id'];
        model.rev = data['rev'];
        return model;
      } else {
        print('Something went horribly wrong!');
      }
    });    
  }
  
  /**
   * Restituisce la versione aggiornata del modello passato come argomento.
   */
  async.Future<Model> put(Model model) {
    var json = JSON.encode(model); 
    return _http.put([_serverUrl, _dbName, model.id].join('/'), json).then((HttpResponse response) {
      Map data = response.data;
      if (data['ok'] == true) {
        model.id = data['id'];
        model.rev = data['rev'];
        return model;
      } else {
        print('Something went horribly wrong!');
      }
    });
  }
  
  delete(Model model) {
    
  }
  
  async.Future<String> generateUuid() {
    return _http.get([_serverUrl, '_uuids'].join('/')).then((HttpResponse response) {
      return response.data['uuids'][0];
    });
  }
  
  toString() {
    return "CouchDbDatabase[${_serverUrl}/${_dbName}]";
  }
}
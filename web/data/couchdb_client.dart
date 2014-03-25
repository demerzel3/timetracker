part of timetracker;

typedef T Constructor<T>(rawData);

class CouchDbClient<Model> {
  Http _http;
  String _serverUrl;
  String _dbName;
  int _lastSeq = 0;
  
  Constructor<Model> _modelConstructor;
  
  CouchDbClient(this._http, this._serverUrl, this._dbName, this._modelConstructor);
  
  int get lastSeq => _lastSeq;
  
  String get serverUrl => _serverUrl;
  set serverUrl(String serverUrl) {
    _serverUrl = serverUrl;
    _lastSeq = 0;
  }
  
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
  
  /**
   * Listens for changes to the database using long polling 
   * and resolves to a list of changed documents. An internal pointer tracks
   * the last seq in order to retrieve only new changes.
   * It is possible to force a change in the seq number by specifiying one.
   * Automathically iterates when the call returns with no results.
   */
  async.Future<List<Model>> pollForChanges({int seq: null, List docIds: null}) {
    if (seq == null) {
      seq = _lastSeq;
    } else {
      _lastSeq = seq; // reset lastSeq to the given seq, to deal with the recursive case correctly
    }
    var url = [_serverUrl, _dbName, '_changes'].join('/');
    var params = {
      'feed': 'longpoll', 
      'since': seq,
      'include_docs': true
    };
    
    if (docIds != null) {
      params['filter'] = '_doc_ids';
      params['doc_ids'] = JSON.encode(docIds);
    }
    
    return _http.get(url, params: params).then((HttpResponse response) {
      Map data = response.data;
      List results = data['results'];
      if (results.length == 0) {
        // no results, do a recursion
        return pollForChanges();
      }
      
      _lastSeq = data['last_seq'];
      List<Model> models = new List<Model>();
      results.forEach((Map change) {
        // ignore deleted documents
        if (change['deleted'] == true) {
          return;
        }
        models.add(_modelConstructor(change['doc']));
      });
      return models;
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
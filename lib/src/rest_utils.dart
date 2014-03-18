part of restlib;

typedef String FileCallBack(String fileContent);

class Route {
  final String url;
  final String method;
  final String others_param;

  const Route(this.url, {this.method: "GET", this.others_param: ""});

  String toString() => "${this.method} : [${this.url}]";
}

class RouteObject {
  RegExp url;
  String method;
  List<String> others_param;
  DeclarationMirror callBackFunction;
  InstanceMirror _objectInstance = null;
  var _function = null;
  var _argument = null;
  var _completer;

  RouteObject(this.url, this.method, String others_params, this._objectInstance, this.callBackFunction) {
    this.others_param = others_params.split(",");
  }
  RouteObject.function(this.url, this.method, String others_params, this._function) {
    this.others_param = others_params.split(",");
  }

  String toString() => "Route: ${this.method} - [${this.url}] -> ${this.callBackFunction}";

  Future<String> call(Iterable<Match> l, HttpRequest r, HttpResponse response) {
    this._completer = new Completer();
    if (this._function != null)
      return new Future(() => this._function(l, r, response));
    List arg = new List();
    for (Match m in l) {
      List<int> idx_list = new List<int>.generate(m.groupCount, (int i) {
        return i+1;
      });
      //print(this.url.toString());
      List<String> idx = m.pattern.pattern.split("\\");
      int i = 1;

      // Getting parameter to send to the callback
      for (String g in m.groups(idx_list)) {
        if (idx[i][0] == "d") {
          arg.add(int.parse(g));
        } else {
          arg.add(g);
        }
      }

      // Adding lib param
      for (String k in this.others_param) {
        if (k == "RouteObject") {
          arg.add(this);
        } else if (k == "HttpRequest") {
          arg.add(r);
        } else if (k == "Session") {
          arg.add(r.session);
        }
      }
    }
    return new Future(() => this._objectInstance.invoke(this.callBackFunction.simpleName, arg).reflectee);
  }
}

class RouteFileObject {
  String file_path;
  File _file;
  var _completer;
  FileCallBack _function = null;
  HttpResponse _response;

  RouteFileObject(this.file_path, [this._function]) {
    this._file = new File(this.file_path);
  }

  String onReadFile(String file_content) {
    if (this._function != null) {
      this._completer.complete(this._function(file_content));
    }
    this._completer.complete(file_content);
    return file_content;
  }

  void _onFileError(var e) {
    this._response.statusCode = HttpStatus.NOT_FOUND;
    this._completer.complete("404 not Found");
  }

  Future<String> call(Iterable<Match> l, HttpRequest r, HttpResponse response) {
    this._completer = new Completer();
    this._response = response;
    this._file.readAsString().then(this.onReadFile).catchError(this._onFileError);
    return this._completer.future;
  }
}
part of sdhs;

/**
 * [Route] is a annotation type used to create the routing.
 * 
 * - url : is the route that will be used
 * - method : It is the method that the route will listen. (GET / PUT ...)
 * - others_param : It decribes the additional parameter passed to the callBack function.
 *         Today, to possible parameter are : "RouteObject", "HttpRequest", "HttpResponse", "Session".
 *         The separator used is ",", So to get multiple parameter, the [String] passed will look like "RouteObject,HttpRequest"
 */
class Route {
  final String url;
  final String method;
  final String others_param;

  const Route(this.url, {this.method: "GET", this.others_param: ""});

  String toString() => "${this.method} : [${this.url}]";
}
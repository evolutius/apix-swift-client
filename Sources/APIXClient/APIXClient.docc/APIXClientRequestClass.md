# ``APIXClient/APIXClient/Request``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}

A struct that handles the creation of requests for API-X servers.

## Overview

API-X servers require very specific data with each request. In addition,
it requires that the data be formatted and properly constructed. This object
simplifies the process of creating API-X requests.

All API-X servers require that a valid application make the requests.
Applications are identified by their API Key and Application Key. This object
requires that both of those keys are provided in the available initializer
``APIXClient/APIXClient/Request/init(apiKey:appKey:)``.

In addition, a request must be directed to a specific API-X server, and so in
order to create a request, the at least the scheme and host must be provided.
Optionally, users may also provide a port.

### Creating an API-X URL Request
Creating an API-X URL request requires that users create an instance of the
``APIXClient/APIXClient/Request`` object, then configure the object with the
host, and finally, create a request. This is the a good method of creating
requests when it is expected that multiple requests will be created for the
same API-X server.

```swift
let clientRequest = APIXClient.Request(
    apiKey: "someAPIKey",
    appKey: "someAppKey")
clientRequest.host = "apixserver.com"
clientRequest.scheme = APIXClient.Constants.URLScheme.https
let request = clientRequest.request(
    for: .get,
    entity: "someEntity",
    method: "someMethod")
Task {
    let json = try? await APIXClient.shared.json(from: request)
    ...
}
```

### Composing an API-X URL Request
Composing requests is a lightweight to create one-time requests in a succint
and easy to understand manner. Users can use a ``APIXClient/APIXClient/Request/Builder``
object to cascade the request-building process. This method does not store
information about the ``APIXClient/APIXClient/Request`` object, but rather it
creates it only when needed.

> ``APIXClient/APIXClient/Request/Builder`` objects may be stored for later use as
> well, however, this is only recommended if the subsequent requests all require
> the same type of data, otherwise, those would need to be cleared on every request.
> Additionally, builder objects are reference types, where as
> ``APIXClient/APIXClient/Request`` are value types, which may make them preferable
> in certain scenarios.

```swift
let request = APIXClient.Request
    .builder(apiKey: "someAPIKey", appKey: "someAppKey")
    .httpMethod(.get)  // optional as default is .get
    .scheme(APIXClient.Constants.URLScheme.https)
    .host("apixserver.com")
    .entity("someEntity")
    .method("someMethod")
    .build()
Task {
    let json = try? await APIXClient.shared.json(from: request)
    ...
}
```

## Topics

### Creating a Request Object

- ``APIXClient/APIXClient/Request/init(apiKey:appKey:)``

### Configuring the API-X host

- ``APIXClient/APIXClient/Request/scheme``
- ``APIXClient/APIXClient/Request/host``
- ``APIXClient/APIXClient/Request/port``

### Creating URL Requests

- ``APIXClient/APIXClient/Request/request(for:entity:method:parameters:httpBody:)``
- ``APIXClient/APIXClient/Request/getRequest(for:method:parameters:)``
- ``APIXClient/APIXClient/Request/postRequest(for:method:parameters:httpBody:)``
- ``APIXClient/APIXClient/Request/putRequest(for:method:parameters:httpBody:)``
- ``APIXClient/APIXClient/Request/HTTPMethod``

### Composing URL Requests

- ``APIXClient/APIXClient/Request/builder(apiKey:appKey:)``
- ``APIXClient/APIXClient/Request/Builder``

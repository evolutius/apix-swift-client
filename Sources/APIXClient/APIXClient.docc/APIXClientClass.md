# ``APIXClient/APIXClient``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}

An object that can send requests to an API-X based server.

## Overview

This class provides a mechanism for sending requests to an API-X server.
A request must be created using a ``APIXClient/APIXClient/Request`` or its
builder ``APIXClient/APIXClient/Request/builder(apiKey:appKey:)`` object in
order to be a valid request.

## Topics

### Using the Shared Client

- ``APIXClient/APIXClient/shared``

### Creating a Client

- ``APIXClient/APIXClient/init()``
- ``APIXClient/APIXClient/init(configuration:)``

### Creating Requests

- ``APIXClient/APIXClient/Request``

### Performing Asynchronous Requests

- <doc:BuildingAClient>
- ``APIXClient/APIXClient/data(from:)``
- ``APIXClient/APIXClient/json(from:)``

### Adding Requests to a Client

- ``APIXClient/APIXClient/execute(with:completion:)``

### Performing Requests as a Combine Publisher

- ``APIXClient/APIXClient/publisher(for:)``
- ``APIXClient/APIXClient/jsonPublisher(for:)``
- ``APIXClient/APIXClient/Publisher``
- ``APIXClient/APIXClient/JSONPublisher``

### Handling Errors

- ``APIXClient/APIXClient/ClientError``

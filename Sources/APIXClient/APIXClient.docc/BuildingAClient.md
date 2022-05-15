# Building An API-X Client

Build an API-X client for API-X-based servers using the power and
simplicity of APIXClient. 

## Overview

APIXClient lets your create an API-X client for API-X-based servers. This sample
app shows how to create an API-X client using the frame. This sample app is going
to request data from a fictional API-X-based recommendation service called `RecommendX`.
`RecommendX` issues recommendations accross a wide variety of categories, such as
songs, movies, TV shows, anime, and other kind of media.

The `RecommendX` service has issued an API Key and App Key so that we can use to
enjoy those recommendations to create a great app or service for users.

## Writing a RecommendX Client

The first step is to implement a `RecommentXClient` class that has the
methods that we need to conveniently obtain recommendations. Throughout this
sample app, it is assumed that there's an structure `Constants` nested into
the `RecommendXClient` class that constains other structures and constants
that are used in the client.

In addition, there are types such as `RecommendX.Option`, `RecommendX.Response`,
`RecommendX.SongGenre`, `RecommendX.Song`, among others, that should be assumed
to exist as models that encapsulate data.

### Writing a Generic Method For Getting Recommendations

Before implementing methods for obtaining specific sets of recommendations (such
as song recommendations), it is useful to implement a generic method that takes
care of the cases that all recommendations have in common. This method will be
called `recommendations` as it returns a set of recommendations in its completion
handler. These recommendations can be for any kind of recommendation that
`RecommendX` supports.

This method can then be leveraged to implement more specific methods. For this
reason, this method will be made `private`, and more specific methods will be the
publicly accessible ones that the users of the client will call. There may also
be helper methods such as `RecommendX.optionsQueryValue(from:)` that are assumed
to exist throughout this sample implementation.

```swift
public class RecommendXClient {
    public static let shared = RecommendXClient()
    private let requestBuilder = APIXClient.Request(apiKey: Constants.apiKey, appKey: Constants.appKey)
    private let apiXClient = APIXClient.shared

    private func recommendations(for entity: String, parameters: [String : String], options: [RecommendX.Option]) async throws -> RecommendX.Response {
        let additionalParameters: [String : String] = [
            Constants.ItemQueryName.recommendationOptions: RecommendX.optionsQueryValue(from: options)
        ]
        let urlQueryParameters = parameters.merging(additionalParameters) { (current, _) in current }
        let request = requestBuilder.request(
            for: .get,
            entity: entity,
            method: Constants.Methods.recommendation,
            parameters: urlQueryParameters
        )
        let json = try await apixClient.json(from: request)
        let decoder = JSONDecoder()
        return try decoder.decode(RecommendX.Response.self, from: data)
    }
}
```

### Writing a Method For Getting Song Recommendations

Now that there's an abstraction of code that we can leverage to obtain
recommendations from the `RecommendX` API-X server, we can build a specific
method to obtain song recommendation, as an example. In this sample, we will
extend the `RecommendXClient` with a method to obtain song recommendations.

```swift
public extension RecommendXClient {
    func songRecommendations(with genres: [RecommendX.SongGenre], options: [RecommendX.Option]) async throws -> RecommendX.SongResponse {
        let recommendXResponse = try await recommendations(
            for: Constants.Entity.song,
            parameters: [
                Constants.ItemQueryName.SongGenreList: RecommendX.genresQueyValue(from: genres),
            ],
            options: options)

        guard let songRecommendationResponse = recommendXResponse as? RecommendX.SongRecommendation else {
            throw RecommendXError(kind: .invalidDataType))
        }
    }
}
```

As can be seen in the snippet of code above, there's an abstraction for getting
song recommendations using the `RecommendXClient`. Users of this client can now
obtain song recommendations leveraging this abstraction:

```swift
Task {
    do {
        let response = RecommendXClient.shared.songRecommendations(
            with: [
                .instrumental,
                .jazz,
                .live
            ],
            options: [
                .sortByPopularity,          // Sorted by popularity
                .filter(ratedBelow: 3),     // Minimum 3 out of 5 stars rating
                .filter(durationAbove: 6),  // Maximum 10 minutes of duration
                .maxResults(500),           // Return a maximum of 500 songs
            ])
        let songRecommendations = response.songs()  // Builds and returns [RecommendX.Song]

        DispatchQueue.main.async {
            self.displaySongs(songRecommendations)
        }
        
    } catch {
        // Handle error
    }
}
```

The user simply specifies the genres of songs they'd want, the options, and finally,
when the response is returned, handle the it by either logging/display errors or
displaying the song recommendations perhaps in a list.

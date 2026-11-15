import Foundation

struct YouTubeSearchResponse: Decodable {
    let items: [YouTubeSearchItem]
}

struct YouTubeSearchItem: Decodable {
    let id: VideoID
    let snippet: VideoDetails
}

struct VideoID: Decodable {
    let videoId: String
}

struct VideoDetails: Decodable {
    let title: String
    let channelTitle: String
}

enum YouTubeSearchService {
    static func searchVideos(
        query: String,
        apiKey: String
    ) async throws -> [YouTubeSearchItem] {
        var components = URLComponents(
            string: "https://www.googleapis.com/youtube/v3/search"
        )!
        
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "10"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(
            YouTubeSearchResponse.self,
            from: data
        )
        
        return response.items
    }
}

//
//  WembleyFilmsAPIClient+Extensions.swift
//  WembleyFilms
//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

extension WembleyFilmsAPIClient {
    
    func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T {
        let request = try configureRequest(from: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, handleResponse(for: httpResponse) else {
            throw NetworkError.badRequest
        }

        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return result
        } catch let decodingError {
            print("Decoding error: \(decodingError)")
            print("Decoding error localized description: \(decodingError.localizedDescription)")
            throw NetworkError.decodingFailed
        }

    }
}

private extension WembleyFilmsAPIClient {
    
    func handleResponse(for response: HTTPURLResponse?) -> Bool {
        guard let statusCode = response?.statusCode, 200...299 ~= statusCode else {
            return false
        }
        return true
    }

    
    func configureRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: routeURL(endpoint.path)) else { fatalError("Error while unwrapping url")}

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.httpMethod = endpoint.method.rawValue
        try configureParametersAndHeaders(parameters: endpoint.parameters, headers: endpoint.httpHeaderFields, request: &request)
        return request
    }
    
    func configureParametersAndHeaders(parameters: [String: Any]?,headers: [String: String]?, request: inout URLRequest) throws {
        do {
            if let headers = headers, let parameters = parameters {
                try encodeParameters(for: &request, with: parameters)
                try setHeaders(for: &request, with: headers)
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
    
    private func routeURL(_ pathURL: String) -> String {
        return WembleyFilmsAPI.baseURL.absoluteString + pathURL
    }
    
    private func encodeParameters(for urlRequest: inout URLRequest, with parameters: [String: Any]) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            for (key,value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
    
    private func setHeaders(for urlRequest: inout URLRequest, with headers: [String: String]) throws {
        for (key, value) in headers{
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
    }
}

extension WembleyFilmsAPIClient {
    public enum NetworkError: String, Error {
        case encodingFailed = "Parameter Encoding failed"
        case decodingFailed = "Unable to Decode data"
        case badRequest = "Bad request"
        case pageNotFound = "Page not found"
        case missingURL = "The URL is nil"
    }

}

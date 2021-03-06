//
//  FirebaseClient.swift
//  Albums
//
//  Created by Shawn Gee on 4/6/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

private let baseURL = URL(string: "https://albums-shawngee.firebaseio.com/")!

enum NetworkError: Error {
    case clientError(Error)
    case invalidResponseCode(Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case invalidData
}

class FirebaseClient {
    func getAlbums(completion: @escaping (Result<[Album], NetworkError>) -> Void) {
        let request = URLRequest(url: baseURL.appendingPathExtension("json"))
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.clientError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.invalidResponseCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let albums = try Array(JSONDecoder().decode([String: Album].self, from: data).values)
                completion(.success(albums))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func putAlbum(_ album: Album, completion: @escaping (NetworkError?) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent(album.id).appendingPathExtension("json"))
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(album)
        } catch {
            completion(.encodingError(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.clientError(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.invalidResponseCode(response.statusCode))
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func deleteAlbum (_ album: Album, completion: @escaping (NetworkError?) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent(album.id).appendingPathExtension("json"))
        request.httpMethod = "DELETE"
        
        do {
            request.httpBody = try JSONEncoder().encode(album)
        } catch {
            completion(.encodingError(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.clientError(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.invalidResponseCode(response.statusCode))
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func getImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.clientError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.invalidResponseCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }
            
            completion(.success(image))
        }.resume()
    }
}

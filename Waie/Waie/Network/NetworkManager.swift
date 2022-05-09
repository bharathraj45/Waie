//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Bharath Raj Venkatesh on 12/03/22.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func request<T: Codable>(url:String, completion: @escaping (Result<T, Error>) -> ()) {
        
        guard let url = URL(string: url) else {
            print("Error: cannot create url")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let err = error {
                completion(.failure(err))
                print(err.localizedDescription)
                return
            }
            guard response != nil, let data = data else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(response))
            } catch let error {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

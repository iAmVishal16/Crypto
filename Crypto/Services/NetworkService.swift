//
//  NetworkService.swift
//  Crypto
//
//  Created by Vishal Paliwal on 26/11/24.
//

import Foundation
import Combine

class NetworkService {
    
    public static let shared = NetworkService()
    private var disposeBag = Set<AnyCancellable>()
    private var connector: Connector

    private init() {
        self.connector = Connector()
    }
}

extension NetworkService: NetworkServiceProtocol {
    
    func getCryptoCoins() -> Future<[Crypto], Error> {
        return Future { promise in
            
            let urlString = API.coinsRequestURL
            
            guard let url = URL(string: urlString) else {
                let error = NSError(domain: "", code: 0, userInfo: ["info": "Invalid URL"])
                promise(.failure(error))
                return
            }
            
            var urlRequest = URLRequest(url: url)
            /*
             Accepted headers will lies here
            urlRequest.addValue(API.key, forHTTPHeaderField: "Authorization")
             */
            
            self.connector.connect(for: urlRequest)
                .sink { error in
                    switch error {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: { (response : [Crypto]) in
                    promise(.success(response))
                }
                .store(in: &self.disposeBag)
        }
    }
}

struct Connector {
    
    func connect<T>(for urlRequest: URLRequest) -> Future<T, Error> where T : Decodable, T : Encodable {
        return Future { promise in
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: urlRequest) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let response = try decoder.decode(T.self, from: data)

                        promise(.success(response))
                    } catch let error {
                        let apiError = NSError(domain: "", code: httpResponse.statusCode, userInfo: ["info": error.localizedDescription])
                        promise(.failure(apiError))
                    }
                case 401:
                    // refresh token here
                    break
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: ["info": "Unknown Error!"])
                    promise(.failure(error))
                    break
                }
            }
            .resume()
        }
    }
}

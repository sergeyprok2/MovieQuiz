//
//  NetworkClient.swift
//  MovieQuiz
//
//

import Foundation

/// Отвечает за загрузку данных по URL
struct NetworkClient {

    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error)) //передаем ошибку
//                print(1)
//                print("🚨 СЕТЬ ОТВАЛИЛАСЬ С ОШИБКОЙ: \(error.localizedDescription)")
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
//            print(2)
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
//                print(2)
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
//            print(3)
            handler(.success(data))
        }
        
        task.resume()
    }
}

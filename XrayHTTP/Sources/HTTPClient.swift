//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

typealias Parse<T> = ((Data?) -> Response<T>)

// Responsible for sending a ready request and parsing its response to the
// specified type
struct Resource<A> {
    let request: URLRequest
    let parse: Parse<A>
}

enum Response<T> {
    case success(T)
    case error(XrayError)
}

enum XrayError: Error {
    case network(String)
    case parsing(String)
}
class HTTPClient {
    
    func load<A>(resource: Resource<A>, completion: @escaping ((Response<A>) -> Void)) {
        URLSession.shared.dataTask(with: resource.request) { data, response, error in
            completion(resource.parse(data))
        }.resume()
    }
}

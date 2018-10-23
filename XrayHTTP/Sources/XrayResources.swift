//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


/// Extension for handling registration response
extension XrayRegistration {
    
    static func post(request: URLRequest) -> Resource<XrayRegistration> {
        
        let resource = Resource<XrayRegistration>(request: request) { data in
            // parse the data into a XrayRegistration
            guard let data = data else { return Response.error(XrayError.network("No data from registration response"))}
            
            // parse the data
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let registrationResponse = try decoder.decode(XrayRegistrationResponse.self, from: data)
                return Response.success(registrationResponse.registrationData)
            } catch {
                return Response.error(XrayError.parsing(error.localizedDescription))
            }
        }
        return resource
    }
}

/// Extension for handling batch event responses

extension EventRequest {
    
    static func post(request: URLRequest) ->  Resource<[EventStatus]> {
        let resource = Resource<[EventStatus]>(request: request) { data in
            // todo parse the xray response
            let status = EventStatus(uid: 1, status: .success)
            return Response.success([status])
        }
        return resource
    }
}

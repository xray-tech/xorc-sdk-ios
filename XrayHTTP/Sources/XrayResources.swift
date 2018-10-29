//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation


/// Extension for handling registration response
extension Registration {
    
    static func post(request: URLRequest) -> Resource<Registration> {
        
        let resource = Resource<Registration>(request: request) { data in
            // parse the data into a XrayRegistration
            guard let data = data else { return Response.error(XrayError.network("No data from registration response"))}
            
            // parse the data
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let registrationResponse = try decoder.decode(RegistrationResponseModel.self, from: data)
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
    
    static func post(request: URLRequest) ->  Resource<[EventStatusResponseModel]> {
        let resource = Resource<[EventStatusResponseModel]>(request: request) { data in
            // todo parse the xray response
            let status = EventStatusResponseModel(uid: 1, status: .success)
            return Response.success([status])
        }
        return resource
    }
}

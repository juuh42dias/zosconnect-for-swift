/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class Api {
    let connection: ZosConnect
    let apiName: String
    let baseURL: URL
    let documentation: [String: Any]

    public init(connection: ZosConnect, apiName: String, basePath: String, documentation: [String: Any]) {
        guard let url = URL(string: basePath) else {
            fatalError("Invalid basePath: \(basePath)")
        }
        self.connection = connection
        self.apiName = apiName
        self.baseURL = url
        self.documentation = documentation
    }

    public func invoke(_ verb: String, resource: String, data: Data?, callback: @escaping DataCallback) {
        let normalizedResource = resource.hasPrefix("/") ? resource : "/\(resource)"
        guard let url = URL(string: normalizedResource, relativeTo: baseURL) else {
            let r = ZosConnectResult<Data>()
            r.error = ZosConnectErrors.connectionerror(NSError(domain: "Invalid URL", code: -1))
            callback(r)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = verb
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let user = connection.userId, let pass = connection.password {
            let auth = "\(user):\(pass)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, response, error in
            let resultObj = ZosConnectResult<Data>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                callback(resultObj)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                resultObj.statusCode = httpResponse.statusCode
            }
            resultObj.result = data
            callback(resultObj)
        }.resume()
    }

    public func getApiDoc(_ documentationType: String, callback: @escaping DataCallback) {
        guard let docUri = documentation[documentationType] as? String,
              let url = URL(string: docUri) else {
            let r = ZosConnectResult<Data>()
            r.error = ZosConnectErrors.connectionerror(NSError(domain: "Documentation type not found: \(documentationType)", code: -1))
            callback(r)
            return
        }
        var request = URLRequest(url: url)
        if let user = connection.userId, let pass = connection.password {
            let auth = "\(user):\(pass)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, _, _ in
            let resultObj = ZosConnectResult<Data>()
            resultObj.result = data
            callback(resultObj)
        }.resume()
    }
}
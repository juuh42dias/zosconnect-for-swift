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

open class ZosConnect {
    let baseURL: URL
    let userId: String?
    let password: String?

    public init(uri: String, userId: String? = nil, password: String? = nil) {
        guard let url = URL(string: uri) else {
            fatalError("Invalid URI: \(uri)")
        }
        baseURL = url
        self.userId = userId
        self.password = password
    }

    func makeRequest(path: String, method: String = "GET") -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let user = userId, let pass = password {
            let auth = "\(user):\(pass)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    open func getServices(_ result: @escaping ListCallback) {
        let request = makeRequest(path: "/zosConnect/services")
        URLSession.shared.dataTask(with: request) { data, _, error in
            let resultObj = ZosConnectResult<[String]>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                result(resultObj)
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let serviceList = json["zosConnectServices"] as? [[String: Any]] else {
                result(resultObj)
                return
            }
            resultObj.result = serviceList.compactMap { $0["ServiceName"] as? String }
            result(resultObj)
        }.resume()
    }

    open func getService(_ serviceName: String, result: @escaping ServiceCallback) {
        let request = makeRequest(path: "/zosConnect/services/\(serviceName)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let resultObj = ZosConnectResult<Service>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                result(resultObj)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                result(resultObj)
                return
            }
            resultObj.statusCode = httpResponse.statusCode
            if httpResponse.statusCode == 200 {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let zosConnect = json["zosConnect"] as? [String: Any],
                      let invokeUri = zosConnect["serviceInvokeURL"] as? String else {
                    result(resultObj)
                    return
                }
                resultObj.result = Service(connection: self, serviceName: serviceName, invokeUri: invokeUri)
            } else if httpResponse.statusCode == 404 {
                resultObj.error = ZosConnectErrors.unknownservice
            } else {
                resultObj.error = ZosConnectErrors.servererror(httpResponse.statusCode)
            }
            result(resultObj)
        }.resume()
    }

    open func getApis(_ result: @escaping ListCallback) {
        let request = makeRequest(path: "/zosConnect/apis")
        URLSession.shared.dataTask(with: request) { data, _, error in
            let resultObj = ZosConnectResult<[String]>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                result(resultObj)
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let apiList = json["apis"] as? [[String: Any]] else {
                result(resultObj)
                return
            }
            resultObj.result = apiList.compactMap { $0["name"] as? String }
            result(resultObj)
        }.resume()
    }

    open func getApi(_ apiName: String, result: @escaping ApiCallback) {
        let request = makeRequest(path: "/zosConnect/apis/\(apiName)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let resultObj = ZosConnectResult<Api>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                result(resultObj)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                result(resultObj)
                return
            }
            resultObj.statusCode = httpResponse.statusCode
            if httpResponse.statusCode == 200 {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let basePath = json["apiUrl"] as? String else {
                    result(resultObj)
                    return
                }
                let documentation = json["documentation"] as? [String: Any] ?? [:]
                resultObj.result = Api(connection: self, apiName: apiName, basePath: basePath, documentation: documentation)
            } else if httpResponse.statusCode == 404 {
                resultObj.error = ZosConnectErrors.unknownapi
            } else {
                resultObj.error = ZosConnectErrors.servererror(httpResponse.statusCode)
            }
            result(resultObj)
        }.resume()
    }
}

public enum ZosConnectErrors: Swift.Error {
    case unknownservice, unknownapi
    case connectionerror(Swift.Error), servererror(Int)
}

public typealias DataCallback = (ZosConnectResult<Data>) -> Void
public typealias ListCallback = (ZosConnectResult<[String]>) -> Void
public typealias ServiceCallback = (ZosConnectResult<Service>) -> Void
public typealias ApiCallback = (ZosConnectResult<Api>) -> Void
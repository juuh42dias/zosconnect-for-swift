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

open class Service {
    let connection: ZosConnect
    let serviceName: String
    let invokeBaseURL: URL

    public init(connection: ZosConnect, serviceName: String, invokeUri: String) {
        guard let url = URL(string: invokeUri) else {
            fatalError("Invalid invokeUri: \(invokeUri)")
        }
        self.connection = connection
        self.serviceName = serviceName
        self.invokeBaseURL = url
    }

    open func invoke(_ data: Data?, callback: @escaping DataCallback) {
        guard var components = URLComponents(url: invokeBaseURL, resolvingAgainstBaseURL: false) else {
            let r = ZosConnectResult<Data>()
            r.error = ZosConnectErrors.connectionerror(NSError(domain: "Invalid URL", code: -1))
            callback(r)
            return
        }
        components.queryItems = [URLQueryItem(name: "action", value: "invoke")]
        guard let url = components.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let user = connection.userId, let pass = connection.password {
            let auth = "\(user):\(pass)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = data ?? "{}".data(using: .utf8)

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

    open func getRequestSchema(_ callback: @escaping DataCallback) {
        let path = "/zosConnect/services/\(serviceName)?action=getRequestSchema"
        let request = connection.makeRequest(path: path)
        URLSession.shared.dataTask(with: request) { data, response, error in
            let resultObj = ZosConnectResult<Data>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                callback(resultObj)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(resultObj)
                return
            }
            if httpResponse.statusCode == 200 {
                resultObj.result = data
            } else if httpResponse.statusCode == 404 {
                resultObj.error = ZosConnectErrors.unknownservice
            } else {
                resultObj.error = ZosConnectErrors.servererror(httpResponse.statusCode)
            }
            callback(resultObj)
        }.resume()
    }

    open func getResponseSchema(_ callback: @escaping DataCallback) {
        let path = "/zosConnect/services/\(serviceName)?action=getResponseSchema"
        let request = connection.makeRequest(path: path)
        URLSession.shared.dataTask(with: request) { data, response, error in
            let resultObj = ZosConnectResult<Data>()
            if let error = error {
                resultObj.error = ZosConnectErrors.connectionerror(error)
                callback(resultObj)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(resultObj)
                return
            }
            if httpResponse.statusCode == 200 {
                resultObj.result = data
            } else if httpResponse.statusCode == 404 {
                resultObj.error = ZosConnectErrors.unknownservice
            } else {
                resultObj.error = ZosConnectErrors.servererror(httpResponse.statusCode)
            }
            callback(resultObj)
        }.resume()
    }

    private func callUriWithStatus(_ path: String, verb: String, callback: @escaping StatusCallback) {
        var request = connection.makeRequest(path: path)
        request.httpMethod = verb
        URLSession.shared.dataTask(with: request) { data, _, error in
            let resultObj = ZosConnectResult<ServiceStatus>()
            if let error = error {
                resultObj.error = error
                callback(resultObj)
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let zosConnect = json["zosConnect"] as? [String: Any],
                  let status = zosConnect["serviceStatus"] as? String else {
                callback(resultObj)
                return
            }
            resultObj.result = status == "Started" ? .STARTED : .STOPPED
            callback(resultObj)
        }.resume()
    }

    open func getStatus(_ callback: @escaping StatusCallback) {
        callUriWithStatus("/zosConnect/services/\(serviceName)?action=status", verb: "GET", callback: callback)
    }

    open func start(_ callback: @escaping StatusCallback) {
        callUriWithStatus("/zosConnect/services/\(serviceName)?action=start", verb: "PUT", callback: callback)
    }

    open func stop(_ callback: @escaping StatusCallback) {
        callUriWithStatus("/zosConnect/services/\(serviceName)?action=stop", verb: "PUT", callback: callback)
    }
}

public typealias StatusCallback = (ZosConnectResult<ServiceStatus>) -> Void

public enum ServiceStatus: String {
    case STARTED, STOPPED, UNAVAILABLE
}
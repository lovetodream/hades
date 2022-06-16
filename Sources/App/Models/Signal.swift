//
//  Signal.swift
//  Hades
// 
// 
//  Created by Timo Zacherl on 20.05.22.
//  
//  Copyright © 2022 Timo Zacherl
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
//  of this software and associated documentation files (the "Software"), to deal 
//  in the Software without restriction, including without limitation the rights 
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all 
//  copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
//  SOFTWARE.
//

import Vapor
import Fluent

final class Signal: Model, Content {
    static let schema = "signal"

    @ID
    var id: UUID?

    @Field(key: "type")
    var type: String

    @Field(key: "client_user_id")
    var clientUserID: String?

    @Parent(key: "project_id")
    var project: Project

    @Children(for: \.$signal)
    var payload: [Payload]

    @Timestamp(key: "received_at", on: .create)
    var receivedAt: Date?

    /// Client side creation, if non is provided it will be the a few ms before ``receivedAt``
    @Timestamp(key: "created_at", on: .none)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil,
         type: String,
         clientUserID: String?,
         createdAt: Date?,
         projectID: Project.IDValue) {
        self.id = id
        self.type = type
        self.clientUserID = clientUserID
        self.createdAt = createdAt
        self.$project.id = projectID
    }

    convenience init(id: UUID? = nil,
                     type: String,
                     clientUserID: String?,
                     createdAt: Date?,
                     project: Project) throws {
        self.init(id: id,
                  type: type,
                  clientUserID: clientUserID,
                  createdAt: createdAt,
                  projectID: try project.requireID())
    }

    struct Create: Content {
        var projectID: UUID
        var type: String
        var clientUserID: String?
        var payload: [String: String]
        var createdAt: Date?
    }
}

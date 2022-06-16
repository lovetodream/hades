//
//  SignalController.swift
//  Hades
// 
// 
//  Created by Timo Zacherl on 21.05.22.
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

struct SignalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let signals = routes.grouped("signals")
        signals.get(use: findAll)
        signals.post(use: create)
        signals.group(":id") { signal in
            signal.get(use: findOne)
        }
    }

    func findAll(_ req: Request) async throws -> [Signal] {
        try await Signal.query(on: req.db).with(\.$payload).all()
    }

    func create(_ req: Request) async throws -> Signal {
        let create = try req.content.decode(Signal.Create.self)
        let signal = Signal(type: create.type,
                            clientUserID: create.clientUserID,
                            createdAt: create.createdAt ?? .now,
                            projectID: create.projectID)
        try await signal.create(on: req.db)
        for (key, value) in create.payload {
            let payload = try Payload(signal: signal,
                                      key: key,
                                      value: value)
            try await payload.create(on: req.db)
        }
        return signal
    }

    func findOne(_ req: Request) async throws -> Signal {
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString),
              let signal = try await Signal.query(on: req.db)
                                           .filter(\.$id == id)
                                           .with(\.$payload).first() else {
            throw Abort(.notFound)
        }
        return signal
    }
}

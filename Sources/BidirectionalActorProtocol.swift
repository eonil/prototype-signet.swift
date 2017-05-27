//
//  BidirectionalActorProtocol.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/28.
//  Copyright © 2017 Eonil. All rights reserved.
//
protocol BidirectionalActorProtocol {
    ///
    /// State treated like an undividable atom.
    /// You are responsible to provide consistency
    /// in a state.
    ///
    associatedtype State
    associatedtype Incoming
    associatedtype Outgoing
    var channel: Channel<State> { get }
    var incoming: Relay<Incoming> { get }
    var outgoing: Relay<Outgoing> { get }
}

final class ExampleBidirectionalActor1: BidirectionalActorProtocol {
    let incoming = Relay<Incoming>()
    let outgoing = Relay<Outgoing>()
    private let channelImpl = MutableChannel<State>(State())

    struct State {
        var example1 = false
    }
    enum Incoming {
        case example1
    }
    enum Outgoing {
        case example1
    }

    init() {
        weak var ss = self
        incoming.delegate = { ss?.processIncoming($0) }
    }
    deinit {
    }
    var channel: Channel<State> {
        return channelImpl
    }
    private func processIncoming(_ s: Incoming) {
        switch s {
        case .example1:
            // Do some I/O.
            channelImpl.state.example1 = true
            outgoing.cast(.example1)
        }
    }
}

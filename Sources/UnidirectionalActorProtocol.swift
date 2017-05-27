//
//  UnidirectionalActorProtocol.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/28.
//  Copyright © 2017 Eonil. All rights reserved.
//

protocol UnidirectionalActorProtocol {
    ///
    /// State treated like an undividable atom.
    /// You are responsible to provide consistency
    /// in a state.
    ///
    associatedtype State
    associatedtype Signal
    var channel: Channel<State> { get }
    func process(_: Signal)
}

final class ExampleUnidirectionalActor1: UnidirectionalActorProtocol {
    private let channelImpl = MutableChannel<State>(State())

    struct State {
        var example1 = false
    }
    enum Signal {
        case example1
    }

    init() {
    }
    deinit {
    }

    var channel: Channel<State> {
        return channelImpl
    }
    func process(_ s: Signal) {
        switch s {
        case .example1:
            // Do some I/O.
            channelImpl.state.example1 = true
        }
    }
}

//
//  Relay.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/28.
//  Copyright © 2017 Eonil. All rights reserved.
//

///
/// State-less signal delivery.
///
public class Relay<T> {
    public var delegate: ((T) -> Void)?
    private var receptors = [ObjectIdentifier: (T) -> Void]()
    private var unwatchImpl: (() -> Void)?

    public init() {}
    deinit {
        unwatchImpl?()
    }
    public func cast(_ signal: T) {
        delegate?(signal)
        for receptor in receptors.values {
            receptor(signal)
        }
    }
    public func watch(_ source: Relay<T>) {
        watch(source) { $0 }
    }
    public func watch<S>(_ source: Relay<S>, with map: @escaping (S) -> T) {
        let selfID = ObjectIdentifier(self)
        weak var ss = self
        source.registerReceptor(selfID) { s in
            guard let ss = ss else { return }
            ss.cast(map(s))
        }
        unwatchImpl = { [weak source] in
            guard let source = source else { return }
            source.deregisterReceptor(selfID)
        }
    }
    public func unwatch() {
        unwatchImpl?()
    }

    private func registerReceptor(_ id: ObjectIdentifier, _ function: @escaping (T) -> Void) {
        receptors[id] = function
    }
    private func deregisterReceptor(_ id: ObjectIdentifier) {
        receptors[id] = nil
    }
}

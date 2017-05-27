////
////  xRelay.swift
////  TransmitterExperiment1
////
////  Created by Hoon H. on 2017/05/28.
////  Copyright © 2017 Eonil. All rights reserved.
////
//
//public final class EmittableRelay<T>: Relay<T> {
//    public override init() {
//        super.init()
//    }
//    public override func cast(_ signal: T) {
//        super.cast(signal)
//    }
//}
//public class TransmittableRelay<T>: Relay<T> {
//    public override init() {
//        super.init()
//    }
//    public func watch(_ source: Relay<T>) {
//        watch(source) { $0 }
//    }
//    public override func watch<S>(_ source: Relay<S>, with map: @escaping (S) -> T) {
//        super.watch(source, with: map)
//    }
//    public override func unwatch() {
//        super.unwatch()
//    }
//}
//public final class AbsorbableRelay<T>: TransmittableRelay<T> {
//    public override init() {
//        super.init()
//    }
//    public override var delegate: ((T) -> Void)? {
//        didSet {}
//    }
//}
//
/////
///// State-less signal delivery.
/////
//public class Relay<T> {
//    fileprivate var delegate: ((T) -> Void)?
//    private var receptors = [ObjectIdentifier: (T) -> Void]()
//    private var unwatchImpl: (() -> Void)?
//
//    fileprivate init() {}
//    fileprivate func cast(_ signal: T) {
//        delegate?(signal)
//        for receptor in receptors.values {
//            receptor(signal)
//        }
//    }
//    fileprivate func watch<S>(_ source: Relay<S>, with map: @escaping (S) -> T) {
//        let selfID = ObjectIdentifier(self)
//        weak var ss = self
//        source.registerReceptor(selfID) { s in
//            guard let ss = ss else { return }
//            ss.cast(map(s))
//        }
//        unwatchImpl = { [weak source] in
//            guard let source = source else { return }
//            source.deregisterReceptor(selfID)
//        }
//    }
//    fileprivate func unwatch() {
//        unwatchImpl?()
//    }
//
//    private func registerReceptor(_ id: ObjectIdentifier, _ function: @escaping (T) -> Void) {
//        receptors[id] = function
//    }
//    private func deregisterReceptor(_ id: ObjectIdentifier) {
//        receptors[id] = nil
//    }
//}

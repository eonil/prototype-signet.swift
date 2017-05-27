//
//  Channel.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/27.
//  Copyright © 2017 Eonil. All rights reserved.
//

///
/// You can watch station from a channel.
/// But a station cannot watch any other.
///
/// Stations expose state mutator.
/// Stations provides editable source value
/// storage for channel network.
///
public class MutableChannel<T>: Channel<T> {
    public public(set) override var state: T {
        get { return super.state }
        set { super.state = newValue }
    }
}

///
/// You can watch a channel from a transmitter.
/// But a transmitter does not provide state mutator.
/// You can only read from it.
///
public class TransmittableChannel<T>: Channel<T> {

    ///
    /// Idempotent.
    ///
    public func watch(_ source: Channel<T>) {
        watch(source, with: { $0 })
    }
    public override func watch<S>(_ source: Channel<S>, with map: @escaping (S) -> T) {
        super.watch(source, with: map)
    }
    ///
    /// Watches two sources, and produces reduced state.
    ///
    /// This produces for each time any of two sources are emitting new state.
    /// Latest state of each other will be used for reducing.
    /// Latest state is stored in an internal shared storage, so this will work
    /// even one of source dies early.
    ///
    /// Idempotent.
    ///
    public func watch<A,B>(_ sourceA: Channel<A>, _ sourceB: Channel<B>, with reduce: @escaping (A,B) -> T) {
        var sharedStorageBox = MutableBox(WatchByReduceSharedStorage(a: sourceA.state, b: sourceB.state))
        weak var aa = sourceA
        weak var bb = sourceB
        func getLatestSourceAState() -> A {
            guard let aa = aa else { return sharedStorageBox.value.a }
            return aa.state
        }
        func getLatestSourceBState() -> B {
            guard let bb = bb else { return sharedStorageBox.value.b }
            return bb.state
        }
        watch(sourceA) { (_ a: A) -> T in
            sharedStorageBox.value.a = a
            let b = getLatestSourceBState()
            return reduce(a, b)
        }
        watch(sourceB) { (_ b: B) -> T in
            sharedStorageBox.value.b = b
            let a = getLatestSourceAState()
            return reduce(a, b)
        }
    }
    private struct WatchByReduceSharedStorage<A,B> {
        var a: A
        var b: B
    }

    public override func unwatch() {
        super.unwatch()
    }
}

///
/// An object which can be watched by a channel.
/// This is read-only representation of mutating state over time.
///
/// `Watchable`s stores its current state, but code users cannot
/// mutate the state directly. You need to use one of its 
/// subclasses for your needs.
///
/// - `Station` for mutable source value storage node.
/// - `Transmitter` for transformation/delivery node.
///
/// Channels together build a value transformation
/// network. This is a sort of push-FRP.
///
/// - Note:
///     Channel implements all functionalities of 
///     `TransmittableChannel` and `MutableChannel`.
///     The classes exists only for logical access control of
///     interfaces.
///
/// - Note:
///     This class does not compromise with
///     ownership and delay.
///
///     - No cycles. Everything is weakly referenced.
///     - No event delay. Everything is delivered immediately.
///
///     Also,
///
///     - All methods are idempotent. It may cause extra 
///         calculations, but result is same.
///
public class Channel<T> {
    public var delegate: ((T) -> Void)?
    private var stateImpl: T
    private var bridges = [ObjectIdentifier: (T) -> Void]()
    private var receptorIDs = [ObjectIdentifier]()
    private var unwatchImpl: (() -> Void)?

    public init(_ initialState: T) {
        stateImpl = initialState
    }
    deinit {
        unwatchImpl?()
    }
    public fileprivate(set) var state: T {
        get {
            return stateImpl
        }
        set {
            stateImpl = newValue
            delegate?(newValue)
            propagateState()
        }
    }
    ///
    /// Idempotent.
    ///
    fileprivate func watch<S>(_ source: Channel<S>, with map: @escaping (S) -> T) {
        source.addReceptor(self)
        source.setMappingFunctionOfBridgeToReceptor(self, map)
        weak var ss = self
        unwatchImpl = { [weak source] () -> Void in
            guard let ss = ss else { return } // Dead self.
            guard let source = source else { return } // Dead source.
            source.removeReceptor(ss)
            ss.unwatchImpl = nil
        }
    }
    ///
    /// Idempotent.
    ///
    fileprivate func unwatch() {
        unwatchImpl?()
    }




    ///
    /// Idempotent.
    ///
    private func setMappingFunctionOfBridgeToReceptor<U>(_ receptor: Channel<U>, _ map: @escaping (T) -> U) {
        let bridgeID = ObjectIdentifier(receptor)
        weak var ss = self
        weak var rr = receptor
        let bridgeFunction = { (_ originalValue: T) -> Void in
            guard let ss = ss else { return }
            guard let rr = rr else {
                ss.removeReceptorByID(bridgeID)
                return
            }
            let mappedValue = map(originalValue)
            rr.state = mappedValue
            rr.propagateState()
        }
        bridges[bridgeID] = bridgeFunction
    }

    ///
    /// Channel owns the map function.
    /// This method weakly captures `receptor`.
    ///
    /// This function is idempotent. Which means
    /// duplicated call with same parameter is no-op.
    /// As a result, supplied receptor will be registered
    /// only once regardless of number of calls to this
    /// function.
    ///
    /// Idempotent.
    ///
    private func addReceptor<U>(_ receptor: Channel<U>) {
        let receptorID = ObjectIdentifier(receptor)
        guard receptorIDs.contains(receptorID) == false else { return }
        receptorIDs.append(receptorID)
    }
    ///
    /// Idempotent.
    ///
    private func removeReceptor<U>(_ receptor: Channel<U>) {
        removeReceptorByID(ObjectIdentifier(receptor))
    }
    ///
    /// Idempotent.
    ///
    private func removeReceptorByID(_ receptorID: ObjectIdentifier) {
        receptorIDs = receptorIDs.filter({ $0 != receptorID })
        bridges[receptorID] = nil
    }
    ///
    /// Idempotent.
    ///
    private func propagateState() {
        for receptorID in receptorIDs {
            bridges[receptorID]?(state)
        }
    }
}

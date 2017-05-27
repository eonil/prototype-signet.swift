//
//  MutableBox.swift
//  TransmitterExperiment1
//
//  Created by Hoon H. on 2017/05/27.
//  Copyright © 2017 Eonil. All rights reserved.
//

final class MutableBox<T> {
    var value: T
    init(_ initialValue: T) {
        value = initialValue
    }
}

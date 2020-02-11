//
//  CollectionExtension.swift
//  MyFactures
//
//  Created by Sébastien Constant on 11/02/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation

extension Collection {
    func insertionIndex(of element: Self.Iterator.Element,
                        using areInIncreasingOrder: (Self.Iterator.Element, Self.Iterator.Element) -> Bool) -> Index {
        return firstIndex(where: { !areInIncreasingOrder($0, element) }) ?? endIndex
    }
}

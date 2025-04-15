//
//  Set+Extension.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


extension Set {
    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
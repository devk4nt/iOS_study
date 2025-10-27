//
//  Route.swift
//  ExNavigationStack
//
//  Created by Kant on 10/27/25.
//

import Foundation

enum Route: Hashable {
    case categoryList
    case itemList(String)
    case itemDetail(id: Int)
}

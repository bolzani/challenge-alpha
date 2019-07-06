//
//  RemoteSearch.swift
//  HurbChallenge
//
//  Created by Felipe Alves on 05/07/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import Promises

class RemoteSearch {
    
    private let baseUrlString: String = "https://www.hurb.com/search/api"
    private var latestPagination: Pagination? = nil
    var searchTerm: String
    
    required init(term: String) {
        searchTerm = term
    }
    
    func loadNextPage() -> Promise<Page> {
        return Promise<Page> { resolve, reject in
            let url = self.nextPageUrl()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            URLSession
                .shared
                .pageTask(with: url, completionHandler: { (page, _, error) in
                    guard let page = page, error == nil else {
                        reject(error!)
                        return
                    }
                    self.latestPagination = page.pagination
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    resolve(page)
                }).resume()
        }
    }
}

fileprivate extension RemoteSearch {
    
    func initialPageUrl() -> URL {
        let queryItems = [URLQueryItem(name: "q", value: self.searchTerm)]
        let components = NSURLComponents(string: baseUrlString)!
        components.queryItems = queryItems
        return components.url!
    }
    
    func nextPageUrl() -> URL {
        let url = self.latestPagination?.fixedNextPageUrl() ?? self.initialPageUrl()
        return url
    }
}

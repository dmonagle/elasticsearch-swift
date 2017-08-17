//
//  ESIndexer.swift
//  Elasticsearch
//
//  Created by David Monagle on 17/8/17.
//
//

/**
    Allows the indexing or deleting of ESIndexable documents
 */
public protocol ESIndexer {
    func index(_ indexable: ESIndexable, in context: ESContext?) throws
    func delete(_ indexable: ESIndexable) throws

}

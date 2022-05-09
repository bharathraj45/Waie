//
//  Cacher.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import Foundation

final public class Cacher {
    let destination: URL
    private let queue = OperationQueue()
    
    /// - temporary: stores Cachable types into the temporary folder of the OS.
    /// - atFolder: stores Cachable types into a specific folder in the OS.
    public enum CacheDestination {
        /// Stores items in NSTemporaryDirectory
        case temporary
        /// Stores items at a specific location
        case atFolder(String)
    }
    
    /// Initializes a newly created Cacher instance using the specified storage destination.
    public init(destination: CacheDestination) {
        switch destination {
        case .temporary:
            self.destination = URL(fileURLWithPath: NSTemporaryDirectory())
        case .atFolder(let folder):
            let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(folder, isDirectory: true)
        }
        
        try? FileManager.default.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
    }
    
    
    /// Store a Cachable object in the directory selected by this Cacher instance.
    public func persist(item: Cachable, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        var url: URL?
        var error: Error?
        
        // Create an operation to process the request.
        let operation = BlockOperation {
            do {
                url = try self.persist(data: item.transform(), at: self.destination.appendingPathComponent(item.fileName, isDirectory: false))
            } catch let persistError {
                error = persistError
            }
        }
        
        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            completion(url, error)
        }
        
        // Add the operation to the queue to start the work.
        queue.addOperation(operation)
    }
    
    /// Load cached data from the directory
    public func load<T: Cachable & Codable>(fileName: String) -> T? {
        guard
            let data = try? Data(contentsOf: destination.appendingPathComponent(fileName, isDirectory: false)),
            let decoded = try? JSONDecoder().decode(T.self, from: data)
            else { return nil }
        return decoded
    }
    
    // MARK: Private
    
    private func persist(data: Data, at url: URL) throws -> URL {
        do {
            try data.write(to: url, options: [.atomicWrite])
            return url
        } catch let error {
            throw error
        }
    }
}

/// A type that can persist itself into the filesystem.
public protocol Cachable {
    /// The item's name in the filesystem.
    var fileName: String { get }
    
    /// Returns a Data encoded representation of the item.
    ///
    /// Returns Data representation of the item.
    func transform() -> Data
}

extension Cachable where Self: Codable {
    public func transform() -> Data {
        do {
            let encoded = try JSONEncoder().encode(self)
            return encoded
        } catch let error {
            fatalError("Unable to encode object: \(error)")
        }
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

#if !os(watchOS)
import AVKit
#endif

import Foundation

#if !os(macOS)
import UIKit.UIImage
/// Alias for `UIImage`.
public typealias PlatformImage = UIImage
#else
import AppKit.NSImage
/// Alias for `NSImage`.
public typealias PlatformImage = NSImage
#endif

// MARK: - ImageResponse

/// An image response that contains a fetched image and some metadata.
public struct ImageResponse: @unchecked Sendable {
    /// An image container with an image and associated metadata.
    public var container: ImageContainer

    #if os(macOS)
    /// A convenience computed property that returns an image from the container.
    public var image: NSImage { container.image }
    #else
    /// A convenience computed property that returns an image from the container.
    public var image: UIImage { container.image }
    #endif

    /// The request for which the response was created.
    public var request: ImageRequest

    /// A response. `nil` unless the resource was fetched from the network or an
    /// HTTP cache.
    public var urlResponse: URLResponse?

    /// Contains a cache type in case the image was returned from one of the
    /// pipeline caches (not including any of the HTTP caches if enabled).
    public var cacheType: CacheType?

    /// Initializes the response with the given image.
    public init(container: ImageContainer, request: ImageRequest, urlResponse: URLResponse? = nil, cacheType: CacheType? = nil) {
        self.container = container
        self.request = request
        self.urlResponse = urlResponse
        self.cacheType = cacheType
    }

    func map(_ transform: (ImageContainer) throws -> ImageContainer) rethrows -> ImageResponse {
        try autoreleasepool {
            var response = self
            response.container = try transform(response.container)
            return response
        }
    }

    /// A cache type.
    public enum CacheType: Sendable {
        /// Memory cache (see `ImageCaching`)
        case memory
        /// Disk cache (see `DataCaching`)
        case disk
    }
}

// MARK: - ImageContainer

/// An image container with an image and associated metadata.
public struct ImageContainer: @unchecked Sendable {
    #if os(macOS)
    /// A fetched image.
    public var image: NSImage
    #else
    /// A fetched image.
    public var image: UIImage
    #endif

    /// An image type.
    public var type: AssetType?

    /// Returns `true` if the image in the container is a preview of the image.
    public var isPreview: Bool

    /// Contains the original image `data`, but only if the decoder decides to
    /// attach it to the image.
    ///
    /// The default decoder (`ImageDecoders.Default`) attaches data to GIFs to
    /// allow to display them using a rendering engine of your choice.
    ///
    /// - note: The `data`, along with the image container itself gets stored
    /// in the memory cache.
    public var data: Data?

    #if !os(watchOS)
    /// Represents in-memory video asset.
    public var asset: AVAsset?
    #endif

    /// An metadata provided by the user.
    public var userInfo: [UserInfoKey: Any]

    /// Initializes the container with the given image.
    public init(image: PlatformImage, type: AssetType? = nil, isPreview: Bool = false, data: Data? = nil, userInfo: [UserInfoKey: Any] = [:]) {
        self.image = image
        self.type = type
        self.isPreview = isPreview
        self.data = data
        self.userInfo = userInfo

        #if !os(watchOS)
        if type?.isVideo == true {
            self.asset = data.flatMap { AVDataAsset(data: $0, type: type) }
        }
        #endif
    }

    func map(_ closure: (PlatformImage) throws -> PlatformImage) rethrows -> ImageContainer {
        var copy = self
        copy.image = try closure(image)
        return copy
    }

    /// A key use in `userInfo`.
    public struct UserInfoKey: Hashable, ExpressibleByStringLiteral, Sendable {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            self.rawValue = value
        }

        // For internal purposes.
        static let isThumbnailKey: UserInfoKey = "com.github/kean/nuke/skip-decompression"

        /// A user info key to get the scan number (Int).
        public static let scanNumberKey: UserInfoKey = "com.github/kean/nuke/scan-number"
    }
}

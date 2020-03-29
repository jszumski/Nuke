<br/>

<p align="left"><img src="https://cloud.githubusercontent.com/assets/1567433/13918338/f8670eea-ef7f-11e5-814d-f15bdfd6b2c0.png" height="180"/>

# Powerful Image Loading System

<p align="left">
<img src="https://img.shields.io/cocoapods/v/Nuke.svg?label=version">
<img src="https://img.shields.io/badge/platforms-iOS%2C%20macOS%2C%20watchOS%2C%20tvOS-lightgrey.svg">
<img src="https://img.shields.io/badge/test%20coverage-100%25-brightgreen.svg">
<a href="https://travis-ci.org/kean/Nuke"><img src="https://img.shields.io/travis/kean/Nuke/master.svg"></a>
</p>

> Upgrading from the previous version? Use a [**Migration Guide**](https://github.com/kean/Nuke/blob/master/Documentation/Migrations).

Nuke provides a simple and efficient way to download and display images in your app. Behind its clear and concise API is an advanced architecture which enables its unique features and offers virtually unlimited possibilities for customization.

> **Fast LRU memory and disk cache** · **SwiftUI** · **Smart background decompression** · **Image processing** · **Elegant builder API** · **Resumable downloads** · **Intelligent deduplication** · **Request prioritization** · **Low data mode** · **Prefetching** · **Rate limiting** · **Progressive JPEG, HEIF, WebP, SVG, GIF** · **Alamofire** · **Combine** · **Reactive extensions**

<br/>

## Getting Started

Nuke is easy to learn and use. Here is an overview of its APIs and features:

- **Image View Extensions** ‣ [UI Extensions](#image-view-extensions) · [Table View](#in-a-table-view) · [Placeholders, Transitions](#placeholders-transitions-content-modes) · [`ImageRequest`](#imagerequest)
- **Image Processing** ‣ [`Resize`](#resize) · [`GaussianBlur`, Core Image](#gaussianblur-core-image) · [Custom Processors](#custom-processors)
- **Image Pipeline** ‣ [Load Image](#image-pipeline) · [`ImageTask`](#imagetask) · [Customize Image Pipeline](#customize-image-pipeline) · [Default Pipeline](#default-image-pipeline)
- **Caching** ‣ [LRU Memory Cache](#lru-memory-cache) · [HTTP Disk Cache](#http-disk-cache) · [Aggressive LRU Disk Cache](#aggressive-lru-disk-cache)
- **Advanced Features** ‣ [Preheat Images](#image-preheating) · [Progressive Decoding](#progressive-decoding)
- [**Extensions**](#h_plugins) ‣ [FetchImage](#fetch-image) · [Builder](#builder) · [Combine](#combine) · [RxNuke](#rxnuke) · [And More](#h_plugins) 

To learn more see a full [**API Reference**](https://kean-org.github.io/docs/nuke/reference/8.0/index.html), and check out the demo project included in the repo. When you are ready to install, follow the [**Installation Guide**](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Installation%20Guide.md). See [**Requirements**](#h_requirements) for a list of supported platforms. If you encounter any issues, the [**Troubleshooting Guide**](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Troubleshooting.md) might help. 

<img src="https://img.shields.io/badge/supports-Swift%20Package%20Manager%2C%20CocoaPods%2C%20Carthage-green.svg">

To learn more about the pipeline and the supported formats, see the dedicated guides.

- [**Image Formats**](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md) ‣ [Progressive JPEG](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md#progressive-jpeg) · [HEIF](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md#heif) · [GIF](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md#gif) · [SVG](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md#svg) · [WebP](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-formats.md#webp) 
- [**Image Pipeline**](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md) ‣ [Data Loading](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#data-loading-and-caching) · [Resumable Downloads](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#resumable-downloads) · [Memory Cache](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#memory-cache) · [Deduplication](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#deduplication) · [Decompression](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#decompression) · [Performance](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md#performance)

If you'd like to contribute to Nuke see [**Contributing**](#h_contribute).

<br/>

# Image View Extensions

<img align="right" src="https://user-images.githubusercontent.com/1567433/59150381-d34beb80-8a22-11e9-8d9a-6b1527ffc9e1.png" width="360"/>

Download and display an image in an image view with a single line of code:

```swift
Nuke.loadImage(with: url, into: imageView)
```

Nuke will check if the image exists in the memory cache, and if it does, will instantly display it. If not, the image data will be loaded, decoded, processed, and decompressed in the background.

> See [Image Pipeline Guide](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md) to learn more about how images are downloaded and processed.

### In a Table View

When you request a new image for the existing view, Nuke will prepare it for reuse and cancel any outstanding requests for the view. Mangaging images in lists has never been easier.

```swift
func tableView(_ tableView: UITableView, cellForItemAt indexPath: IndexPaths) -> UITableViewCell {
    /* Create a cell ... */
    Nuke.loadImage(with: url, into: cell.imageView)
}
```

> The requests get canceled automatically when the views are deallocated. Call `Nuke.cancelRequest(for: imageView)` to cancel the request manually.

### Placeholders, Transitions, Content Modes

Use `ImageLoadingOptions` to set a `placeholder`, select one of the built-in `transitions`, or provide a custom one.

```swift
let options = ImageLoadingOptions(
    placeholder: UIImage(named: "placeholder"),
    transition: .fadeIn(duration: 0.33)
)
Nuke.loadImage(with: url, options: options, into: imageView)
```

You can even customize content modes per image type:

```swift
let options = ImageLoadingOptions(
    placeholder: UIImage(named: "placeholder"),
    failureImage: UIImage(named: "failureImage"),
    contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center)
)
```

> In case you want all image views to have the same behavior, you can modify `ImageLoadingOptions.shared`.

Please keep in mind that the built-in extensions for image views are designed to get you up and running as quickly as possible. If you want to have more control, or use some of the advanced features, like animated images, it is recommended to use `ImagePipeline` directly in your custom views.

### `ImageRequest`

`ImageRequest` allows you to set image processors, change the request priority and more:

```swift
let request = ImageRequest(
    url: URL(string: "http://..."),
    processors: [ImageProcessor.Resize(size: imageView.bounds.size)],
    priority: .high
)
```

> Another way to apply processors is by setting the default `processors` on `ImagePipeline.Configuration`. These processors will be applied to all images loaded by the pipeline. If the request has a non-empty array of `processors`, they are going to be applied instead.

The advanced options available via `ImageRequestOptions`. For example, you can provide a `filteredURL` to be used as a key for caching in case the URL contains transient query parameters.

```swift
let request = ImageRequest(
    url: URL(string: "http://example.com/image.jpeg?token=123")!,
    options: ImageRequestOptions(
        filteredURL: "http://example.com/image.jpeg"
    )
)
```

> There are more options available, to see all of them check the inline documentation for `ImageRequestOptions`.

<br/>

# Image Processing

<img align="right" src="https://user-images.githubusercontent.com/1567433/59151404-cb944300-8a32-11e9-9c58-dbed9789080f.png" width="360"/>

Nuke features a powerful and efficient image processing infrastructure with multiple built-in processors including `ImageProcessor.Resize`, `.Circle`, `.RoundedCorners`, `.CoreImageFilter`, `.GaussianBlur`.

> This and other screenshots are from the demo project included in the repo.

### `Resize`

To resize an image, use `ImageProcessor.Resize`:

```swift
ImageRequest(url: url, processors: [
    ImageProcessor.Resize(size: imageView.bounds.size)
])
```

By default, the target size is in points. When the image is loaded, Nuke will scale it to fill the target area maintaining the aspect ratio. To crop the image set `crop` to `true`.

> There are a few other options available, see `ImageProcessor.Resize` documentation for more info.

### `GaussianBlur`, Core Image

`ImageProcessor.GaussianBlur` blurs the input image. It is powered by the native `CoreImage` framework. To apply other filters, use `ImageProcessor.CoreImageFilter`:

```swift
ImageProcessor.CoreImageFilter(name: "CISepiaTone")
```

> For a complete list of Core Image filters see [Core Image Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html).

### Custom Processors

Custom processors need to conform to `ImageProcessing` protocol:

```swift
public protocol ImageProcessing {
    var identifier: String { get }
    var hashableIdentifier: AnyHashable { get }

    func process(image: Image, context: ImageProcessingContext?) -> Image?
}
```

The `process` method is self-explanatory. `identifier: String` is used by disk caches, and `hashableIdentifier: AnyHashable` is used by memory caches for which string manipulations would be too slow.

For one-off operations, use `ImageProcessor.Anonymous` to create a processor with a closure.

<br/>

# Image Pipeline

At the core of Nuke is the `ImagePipeline` class. Use the pipeline directly to load images without displaying them:

```swift
let task = ImagePipeline.shared.loadImage(
    with: url,
    progress: { _, completed, total in
        print("progress updated")
    },
    completion: { result: Result<ImageResponse, ImagePipeline.Error> in
        print("task completed")
    }
)
```

> To download the data without doing any expensive decoding or processing, use `loadData(with:progress:completion:)`.

### `ImageTask`

When you start the request, the pipeline returns an `ImageTask` object, which can be used for cancelation and more.

```swift
task.cancel()
task.priority = .high
```

### Customize Image Pipeline

If you want to build a system that fits your specific needs, you won't be disappointed. There are a _lot of things_ to tweak. You can set custom data loaders and caches, configure image encoders and decoders, change the number of concurrent operations for each individual stage, disable and enable features like deduplication and rate limiting, and more.

> To learn more see the inline documentation for `ImagePipeline.Configuration` and [Image Pipeline Guide](https://github.com/kean/Nuke/blob/master/Documentation/Guides/image-pipeline.md).

<img align="right" src="https://user-images.githubusercontent.com/1567433/59148462-94f60280-8a09-11e9-906a-6c7209b8f8c8.png" width="360"/>

Here are the protocols which can be used for customization:

- `DataLoading` – Download (or return cached) image data
- `DataCaching` – Store image data on disk
- `ImageDecoding` – Convert data into images (see `_ImageDecoding` for new experimental decoding features)
- `ImageEncoding` - Convert images into data
- `ImageProcessing` – Apply image transformations
- `ImageCaching` – Store images into a memory cache

The entire configuration is described by the `ImagePipeline.Configuration` struct. To create a pipeline with a custom configuration either call the `ImagePipeline(configuration:)` initializer or use the convenience one:

```swift
let pipeline = ImagePipeline {
    $0.dataLoader = ...
    $0.dataLoadingQueue = ...
    $0.imageCache = ...
    ...
}
```

And then set the new pipeline as default:

```swift
ImagePipeline.shared = pipeline
```

### Default Image Pipeline

The default image pipeline is initialized with the following dependencies:

```swift
// Shared image cache with a size limit of ~20% of available RAM.
imageCache = ImageCache.shared

// Data loader with a default `URLSessionConfiguration` and a custom `URLCache`
// with memory capacity 0, and disk capacity 150 MB.
dataLoader = DataLoader()

// Custom aggressive disk cache is disabled by default.
dataCache = nil

// By default uses the decoder from the global registry and the default encoder.
makeImageDecoder = { context in ImageDecoderRegistry.shared.decoder(for: context) }
makeImageEncoder = { _ in ImageEncoders.Default() }
```

Each operation in the pipeline runs on a dedicated queue:

```swift
dataLoadingQueue.maxConcurrentOperationCount = 6
dataCachingQueue.maxConcurrentOperationCount = 2
imageDecodingQueue.maxConcurrentOperationCount = 1
imageEncodingQueue.maxConcurrentOperationCount = 1
imageProcessingQueue.maxConcurrentOperationCount = 2
imageDecompressingQueue.maxConcurrentOperationCount = 2
```

There is a list of pipeline settings which you can tweak:

```swift
// Automatically decompress images in the background by default.
isDecompressionEnabled = true

// Configure what content to store in the custom disk cache.
dataCacheOptions.storedItems = [.finalImage] // [.originalImageData]

// Avoid doing any duplicated work when loading or processing images.
isDeduplicationEnabled = true

// Rate limit the requests to prevent trashing of the subsystems.
isRateLimiterEnabled = true

// Progressive decoding is an opt-in feature because it is resource intensive.
isProgressiveDecodingEnabled = false

// If the data task is terminated (either because of a failure or a
// cancellation) and the image was partially loaded, the next load will
// resume where it was left off.
isResumableDataEnabled = true
```

And also a few global options shared between all pipelines:

```swift
// Enable to start using `os_signpost` to monitor the pipeline
// performance using Instruments.
ImagePipeline.Configuration.isSignpostLoggingEnabled = false
```

<br/>

# Caching

### LRU Memory Cache

Nuke's default `ImagePipeline` has two cache layers.

First, there is a memory cache for storing processed images which are ready for display.

```swift
// Configure cache
ImageCache.shared.costLimit = 1024 * 1024 * 100 // 100 MB
ImageCache.shared.countLimit = 100
ImageCache.shared.ttl = 120 // Invalidate image after 120 sec

// Read and write images
let request = ImageRequest(url: url)
ImageCache.shared[request] = image
let image = ImageCache.shared[request]

// Clear cache
ImageCache.shared.removeAll()
```

`ImageCache` uses the [LRU](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU)) algorithm – least recently used entries are removed first during the sweep.

### HTTP Disk Cache

Unprocessed image data is stored with `URLCache`.

```swift
// Configure cache
DataLoader.sharedUrlCache.diskCapacity = 100
DataLoader.sharedUrlCache.memoryCapacity = 0

// Read and write responses
let request = ImageRequest(url: url)
let _ = DataLoader.sharedUrlCache.cachedResponse(for: request.urlRequest)
DataLoader.sharedUrlCache.removeCachedResponse(for: request.urlRequest)

// Clear cache
DataLoader.sharedUrlCache.removeAllCachedResponses()
```

### Aggressive LRU Disk Cache

If HTTP caching is not your cup of tea, you can try using a custom LRU disk cache for fast and reliable *aggressive* data caching (ignores [HTTP cache control](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)). You can enable it using the pipeline configuration.

```swift
ImagePipeline {
    $0.dataCache = try? DataCache(name: "com.myapp.datacache")

    // Also consider disabling the native HTTP cache, see `DataLoader`.
}
```

By default, the pipeline stores only the original image data. To store downloaded and processed images instead, set `dataCacheOptions.storedItems` to `[.finalImage]`. This option is useful if you want to store processed, e.g. downsampled images, or if you want to transcode images to a more efficient format, like HEIF.

> To save disk space see `ImageEncoders.ImageIO` and a new experimental `ImageEncoder._isHEIFPreferred` option for HEIF support.

<br/>

# Advanced Features

### Image Preheating

Prefetching images in advance can dramatically improve your app's user experience.

```swift
let preheater = ImagePreheater()
preheater.startPreheating(with: urls)

// Cancels all of the preheating tasks created for the given requests.
preheater.stopPreheating(with: urls)
```

Keep in mind that prefetching takes up users' data and puts extra pressure on CPU and memory. To reduce the CPU and memory usage, you have an option to choose only the disk cache as a prefetching destination:

```swift
// The preheater with `.diskCache` destination will skip image data decoding
// entirely to reduce CPU and memory usage. It will still load the image data
// and store it in disk caches to be used later.
let preheater = ImagePreheater(destination: .diskCache)
```

> On iOS, you can use [prefetching APIs](https://developer.apple.com/reference/uikit/uitableviewdatasourceprefetching) in combination with `ImagePreheater` to automate the process.

### Progressive Decoding

To enable progressive image decoding set `isProgressiveDecodingEnabled` configuration option to `true`.

<img align="right" width="360" alt="Progressive JPEG" src="https://user-images.githubusercontent.com/1567433/59148764-3af73c00-8a0d-11e9-9d49-ded2d509380a.png">

```swift
let pipeline = ImagePipeline {
    $0.isProgressiveDecodingEnabled = true
}
```

And that's it, the pipeline will automatically do the right thing and deliver the progressive scans via `progress` closure as they arrive:

```swift
let imageView = UIImageView()
let task = ImagePipeline.shared.loadImage(
    with: url,
    progress: { response, _, _ in
        if let response = response {
            imageView.image = response.image
        }
    },
    completion: { result in
        // Display the final image
    }
)
```

<br/>

<a name="h_plugins"></a>
## Extensions

There is a variety of extensions available for Nuke:

|Name|Description|
|--|--|
|[**FetchImage**](https://github.com/kean/FetchImage)|SwiftUI integration|
|[**ImagePublisher**](https://github.com/kean/ImagePublisher)|Combine publishers for Nuke|
|[**ImageTaskBuilder**](https://github.com/kean/ImageTaskBuilder)|A fun and convenient way to use Nuke|
|[**Alamofire Plugin**](https://github.com/kean/Nuke-Alamofire-Plugin)|Replace networking layer with [Alamofire](https://github.com/Alamofire/Alamofire) and combine the power of both frameworks|
|[**RxNuke**](https://github.com/kean/RxNuke)|[RxSwift](https://github.com/ReactiveX/RxSwift) extensions for Nuke with examples of common use cases solved by Rx|
|[**WebP Plugin**](https://github.com/ryokosuge/Nuke-WebP-Plugin)| **[Community]** [WebP](https://developers.google.com/speed/webp/) support, built by [Ryo Kosuge](https://github.com/ryokosuge)|
|[**Gifu Plugin**](https://github.com/kean/Nuke-Gifu-Plugin)|Use [Gifu](https://github.com/kaishin/Gifu) to load and display animated GIFs|
|[**FLAnimatedImage Plugin**](https://github.com/kean/Nuke-AnimatedImage-Plugin)|Use [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) to load and display [animated GIFs]((https://www.youtube.com/watch?v=fEJqQMJrET4))|
|[**Xamarin NuGet**](https://github.com/roubachof/Xamarin.Forms.Nuke)| **[Community]** Makes it possible to use Nuke from Xamarin|

<br/>

<a name="fetch-image"></a>
### [`FetchImage`](https://github.com/kean/FetchImage)

[`FetchImage`](https://github.com/kean/FetchImage) is a Swift package that makes it easy to download images using Nuke and display them in SwiftUI apps. For more info, see the [introductory post](https://kean.github.io/post/introducing-fetch-image). 

> **Note**: This is an API preview, it might change in the future.

```swift
public struct ImageView: View {
    @ObservedObject var image: FetchImage

    public var body: some View {
        ZStack {
            Rectangle().fill(Color.gray)
            image.view?
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
```

**Low Data Mode**

[`FetchImage`](https://github.com/kean/FetchImage) also offers built-in support for low-data mode via a special initializer:

```swift
FetchImage(regularUrl: highQualityUrl, lowDataUrl: lowQualityUrl)
```

### Builder

Find the default API a bit boring? Try [ImageTaskBuilder](https://github.com/kean/ImageTaskBuilder), a fun and convenient way to use Nuke.

```swift
ImagePipeline.shared.image(with: URL(string: "https://")!)
    .fill(width: 320)
    .blur(radius: 10)
    .priority(.high)
    .start { result in
        print(result)
    }

// Returns `ImageTask` when started.
```

```swift
let imageView: UIImageView

ImagePipeline.shared.image(with: URL(string: "https://")!)
    .fill(width: imageView.size.width)
    .display(in: imageView)
```

### RxNuke

[RxNuke](https://github.com/kean/RxNuke) adds [RxSwift](https://github.com/ReactiveX/RxSwift) extensions for Nuke and enables common use cases: [Going from low to high resolution](https://github.com/kean/RxNuke#going-from-low-to-high-resolution) | [Loading the first available image](https://github.com/kean/RxNuke#loading-the-first-available-image) | [Showing stale image while validating it](https://github.com/kean/RxNuke#showing-stale-image-while-validating-it) | [Load multiple images, display all at once](https://github.com/kean/RxNuke#load-multiple-images-display-all-at-once) | [Auto retry on failures](https://github.com/kean/RxNuke#auto-retry) | [And more](https://github.com/kean/RxNuke#use-cases)

To get a taste of what you can do with this extension, take a look at how easy it is to load the low resolution image first and then switch to high resolution:

```swift
let pipeline = ImagePipeline.shared
Observable.concat(pipeline.loadImage(with: lowResUrl).orEmpty,
                  pipeline.loadImage(with: highResUtl).orEmpty)
    .subscribe(onNext: { imageView.image = $0 })
    .disposed(by: disposeBag)
```

### Combine

[ImagePublisher](https://github.com/kean/ImagePublisher) adds Combine publishers for Nuke and, just like [RxNuke](https://github.com/kean/RxNuke), enables a variety of powerful use cases.

<br/>

<a name="h_contribute"></a>
# Contribution

[Nuke's roadmap](https://trello.com/b/Us4rHryT/nuke) is managed in Trello and is publicly available. If you'd like to contribute, please feel free to create a PR.

<a name="h_requirements"></a>
# Requirements

| Nuke          | Swift           | Xcode           | Platforms                                         |
|---------------|-----------------|-----------------|---------------------------------------------------|
| Nuke 8.0      | Swift 5.0       | Xcode 10.2      | iOS 10.0 / watchOS 3.0 / macOS 10.12 / tvOS 10.0  |
| Nuke 7.6      | Swift 4.2       | Xcode 10.1      | iOS 10.0 / watchOS 3.0 / macOS 10.12 / tvOS 10.0  |
| Nuke 7.2      | Swift 4.0       | Xcode 9.2       | iOS 9.0 / watchOS 2.0 / macOS 10.10 / tvOS 9.0    |

# License

Nuke is available under the MIT license. See the LICENSE file for more info.

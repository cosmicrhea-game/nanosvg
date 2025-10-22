import CNanoSVG
import Foundation

/// A rasterizer for converting SVG images to pixel data.
///
/// The rasterizer can be reused to render multiple images efficiently.
/// It manages its own internal state and memory for optimal performance.
public final class SVGRasterizer {
  /// The underlying C rasterizer pointer.
  private let underlying: OpaquePointer

  /// Creates a new rasterizer instance.
  ///
  /// The rasterizer can be reused to render multiple images.
  /// - Returns: A new rasterizer instance, or nil if creation failed.
  public init?() {
    guard let rasterizer = nsvgCreateRasterizer() else {
      return nil
    }
    self.underlying = rasterizer
  }

  /// Deallocates the rasterizer and its associated memory.
  deinit {
    nsvgDeleteRasterizer(underlying)
  }

  /// Rasterizes an SVG image into pixel data.
  ///
  /// - Parameters:
  ///   - image: The SVG image to rasterize.
  ///   - x: X offset for the rasterization.
  ///   - y: Y offset for the rasterization.
  ///   - scale: Scale factor for the rasterization.
  ///   - width: Width of the output image in pixels.
  ///   - height: Height of the output image in pixels.
  /// - Returns: RGBA pixel data as a Data object, or nil if rasterization failed.
  public func rasterize(
    image: SVGImage,
    x: Float = 0,
    y: Float = 0,
    scale: Float = 1,
    width: Int,
    height: Int
  ) -> Data? {
    let bytesPerPixel = 4  // RGBA
    let stride = width * bytesPerPixel
    let bufferSize = height * stride

    let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { pixelData.deallocate() }

    nsvgRasterize(
      underlying,
      image.underlying,
      x, y, scale,
      pixelData,
      Int32(width), Int32(height), Int32(stride)
    )

    return Data(bytes: pixelData, count: bufferSize)
  }

  /// Rasterizes an SVG image at its natural size.
  ///
  /// - Parameter image: The SVG image to rasterize.
  /// - Returns: RGBA pixel data as a Data object, or nil if rasterization failed.
  public func rasterize(image: SVGImage) -> Data? {
    return rasterize(
      image: image,
      width: Int(image.width),
      height: Int(image.height)
    )
  }

  /// Rasterizes an SVG image into a 2D array of RGBA values.
  ///
  /// - Parameters:
  ///   - image: The SVG image to rasterize.
  ///   - x: X offset for the rasterization.
  ///   - y: Y offset for the rasterization.
  ///   - scale: Scale factor for the rasterization.
  ///   - width: Width of the output image in pixels.
  ///   - height: Height of the output image in pixels.
  /// - Returns: A 2D array of RGBA values, or nil if rasterization failed.
  public func rasterizeToArray(
    image: SVGImage,
    x: Float = 0,
    y: Float = 0,
    scale: Float = 1,
    width: Int,
    height: Int
  ) -> [[UInt8]]? {
    guard
      let pixelData = rasterize(
        image: image,
        x: x, y: y, scale: scale,
        width: width, height: height
      )
    else {
      return nil
    }

    var result: [[UInt8]] = []
    let bytesPerPixel = 4  // RGBA

    for row in 0..<height {
      let rowStart = row * width * bytesPerPixel
      let rowEnd = rowStart + width * bytesPerPixel
      let rowData = Array(pixelData[rowStart..<rowEnd])
      result.append(rowData)
    }

    return result
  }
}

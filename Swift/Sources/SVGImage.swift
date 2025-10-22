import CNanoSVG
import Foundation

/// A representation of an SVG image.
/// Provides access to the parsed contents of an SVG document.
public final class SVGImage {
  /// The underlying C NSVGimage pointer.
  private let underlying: UnsafeMutablePointer<NSVGimage>

  /// Private initializer to prevent copying.
  private init(underlying: UnsafeMutablePointer<NSVGimage>) {
    self.underlying = underlying
  }

  /// Deinitializer that properly cleans up the C memory.
  deinit {
    nsvgDelete(underlying)
  }

  /// The width of the SVG image in pixels.
  public var width: Float {
    return underlying.pointee.width
  }

  /// The height of the SVG image in pixels.
  public var height: Float {
    return underlying.pointee.height
  }

  /// All shapes contained within the SVG image.
  /// Returns an array of SVGShape objects representing the parsed SVG elements.
  public var shapes: [SVGShape] {
    var shapeList: [SVGShape] = []
    var currentShape = underlying.pointee.shapes

    while let shape = currentShape {
      shapeList.append(SVGShape(underlying: shape))
      currentShape = shape.pointee.next
    }

    return shapeList
  }

  /// Creates an SVG image by parsing a file from the filesystem.
  /// - Parameter filePath: The path to the SVG file to parse.
  /// - Returns: A parsed SVGImage object, or nil if parsing failed.
  public init?(contentsOfFile filePath: String) {
    guard let image = nsvgParseFromFile(filePath, "px", 96.0) else {
      return nil
    }
    self.underlying = image
  }

  /// Creates an SVG image by parsing SVG content from a string.
  /// - Parameter svgString: The SVG string content to parse.
  /// - Returns: A parsed SVGImage object, or nil if parsing failed.
  public init?(svgString: String) {
    let result = svgString.withCString { cString in
      nsvgParse(UnsafeMutablePointer(mutating: cString), "px", 96.0)
    }
    guard let image = result else {
      return nil
    }
    self.underlying = image
  }

  /// Creates an SVG image by parsing SVG content from Data.
  /// - Parameter data: The SVG data to parse.
  /// - Returns: A parsed SVGImage object, or nil if parsing failed.
  public init?(data: Data) {
    guard let svgString = String(data: data, encoding: .utf8) else {
      return nil
    }
    let result = svgString.withCString { cString in
      nsvgParse(UnsafeMutablePointer(mutating: cString), "px", 96.0)
    }
    guard let image = result else {
      return nil
    }
    self.underlying = image
  }
}

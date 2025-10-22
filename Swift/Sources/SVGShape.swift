import CNanoSVG
import Foundation

/// A shape element within an SVG image.
/// Represents a single graphical element with its styling and path data.
public final class SVGShape {
  /// The type of paint used for filling or stroking.
  public enum PaintType: Int32 {
    case undefined = -1
    case none = 0
    case color = 1
    case linearGradient = 2
    case radialGradient = 3
  }

  /// The style used for joining line segments.
  public enum LineJoin: Int32 {
    case miter = 0
    case round = 1
    case bevel = 2
  }

  /// The style used for line endpoints.
  public enum LineCap: Int32 {
    case butt = 0
    case round = 1
    case square = 2
  }

  /// The algorithm used to determine the interior of a shape.
  public enum FillRule: Int32 {
    case nonzero = 0
    case evenOdd = 1
  }

  /// The underlying C NSVGshape pointer.
  private let underlying: UnsafeMutablePointer<NSVGshape>

  /// Internal initializer to prevent copying.
  internal init(underlying: UnsafeMutablePointer<NSVGshape>) {
    self.underlying = underlying
  }

  /// The unique identifier of the shape.
  public var id: String {
    // Access the C string directly using memory layout
    return withUnsafeBytes(of: underlying.pointee.id) { bytes in
      String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
    }
  }

  /// The fill paint type for this shape.
  public var fillType: PaintType {
    return PaintType(rawValue: Int32(underlying.pointee.fill.type)) ?? .undefined
  }

  /// The stroke paint type for this shape.
  public var strokeType: PaintType {
    return PaintType(rawValue: Int32(underlying.pointee.stroke.type)) ?? .undefined
  }

  /// The opacity of the shape (0.0 to 1.0).
  public var opacity: Float {
    return underlying.pointee.opacity
  }

  /// The stroke width in pixels.
  public var strokeWidth: Float {
    return underlying.pointee.strokeWidth
  }

  /// The stroke dash offset in pixels.
  public var strokeDashOffset: Float {
    return underlying.pointee.strokeDashOffset
  }

  /// The stroke dash array pattern.
  public var strokeDashArray: [Float] {
    let count = Int(underlying.pointee.strokeDashCount)
    return withUnsafeBytes(of: underlying.pointee.strokeDashArray) { bytes in
      Array(UnsafeBufferPointer(start: bytes.bindMemory(to: Float.self).baseAddress!, count: count))
    }
  }

  /// The stroke line join style.
  public var strokeLineJoin: LineJoin {
    return LineJoin(rawValue: Int32(underlying.pointee.strokeLineJoin)) ?? .miter
  }

  /// The stroke line cap style.
  public var strokeLineCap: LineCap {
    return LineCap(rawValue: Int32(underlying.pointee.strokeLineCap)) ?? .butt
  }

  /// The miter limit for sharp corners.
  public var miterLimit: Float {
    return underlying.pointee.miterLimit
  }

  /// The fill rule algorithm used for this shape.
  public var fillRule: FillRule {
    return FillRule(rawValue: Int32(underlying.pointee.fillRule)) ?? .nonzero
  }

  /// The bounding box of the shape as [minX, minY, maxX, maxY].
  public var bounds: [Float] {
    return withUnsafeBytes(of: underlying.pointee.bounds) { bytes in
      Array(UnsafeBufferPointer(start: bytes.bindMemory(to: Float.self).baseAddress!, count: 4))
    }
  }

  /// The fill gradient identifier.
  public var fillGradient: String {
    return withUnsafeBytes(of: underlying.pointee.fillGradient) { bytes in
      String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
    }
  }

  /// The stroke gradient identifier.
  public var strokeGradient: String {
    return withUnsafeBytes(of: underlying.pointee.strokeGradient) { bytes in
      String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
    }
  }

  /// The transformation matrix for fill/stroke gradients.
  public var xform: [Float] {
    return withUnsafeBytes(of: underlying.pointee.xform) { bytes in
      Array(UnsafeBufferPointer(start: bytes.bindMemory(to: Float.self).baseAddress!, count: 6))
    }
  }

  /// All paths contained within this shape.
  public var paths: [SVGPath] {
    var pathList: [SVGPath] = []
    var currentPath = underlying.pointee.paths

    while let path = currentPath {
      pathList.append(SVGPath(underlying: path))
      currentPath = path.pointee.next
    }

    return pathList
  }
}

/// A path element within an SVG shape.
/// Contains the geometric data for drawing curves and lines.
public final class SVGPath {
  /// The underlying C NSVGpath pointer.
  private let underlying: UnsafeMutablePointer<NSVGpath>

  /// Internal initializer to prevent copying.
  internal init(underlying: UnsafeMutablePointer<NSVGpath>) {
    self.underlying = underlying
  }

  /// The control points of the path as a flat array of coordinates.
  /// Points are stored as [x0, y0, x1, y1, ...] for cubic bezier curves.
  public var points: [Float] {
    let count = Int(underlying.pointee.npts) * 2
    return Array(UnsafeBufferPointer(start: underlying.pointee.pts, count: count))
  }

  /// The number of control points in the path.
  public var pointCount: Int {
    return Int(underlying.pointee.npts)
  }

  /// Whether the path forms a closed shape.
  public var isClosed: Bool {
    return underlying.pointee.closed != 0
  }

  /// The bounding box of the path as [minX, minY, maxX, maxY].
  public var bounds: [Float] {
    return withUnsafeBytes(of: underlying.pointee.bounds) { bytes in
      Array(UnsafeBufferPointer(start: bytes.bindMemory(to: Float.self).baseAddress!, count: 4))
    }
  }
}

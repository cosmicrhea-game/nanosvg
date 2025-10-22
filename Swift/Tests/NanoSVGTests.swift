import Foundation
import Testing

@testable import NanoSVG

@Test func testSVGImageParsing() async throws {
  // Test parsing a simple SVG string
  let svgString = """
    <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
        <rect x="10" y="10" width="80" height="80" fill="red"/>
    </svg>
    """

  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  let svgImage = image!
  #expect(svgImage.width == 100.0)
  #expect(svgImage.height == 100.0)
}

@Test func testSVGImageShapes() async throws {
  let svgString = """
    <svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
        <rect x="10" y="10" width="50" height="50" fill="red" id="rect1"/>
        <circle cx="100" cy="100" r="30" fill="blue" id="circle1"/>
    </svg>
    """

  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  let shapes = image!.shapes
  #expect(shapes.count == 2)

  // Test first shape (rectangle)
  let rect = shapes[0]
  #expect(rect.id == "rect1")
  #expect(rect.fillType == .color)
  #expect(rect.strokeType == .none)

  // Test second shape (circle)
  let circle = shapes[1]
  #expect(circle.id == "circle1")
  #expect(circle.fillType == .color)
}

@Test func testSVGShapeProperties() async throws {
  let svgString = """
    <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
        <rect x="10" y="10" width="50" height="50" 
              fill="red" 
              stroke="blue" 
              stroke-width="2" 
              stroke-linejoin="round" 
              stroke-linecap="round"
              fill-rule="evenodd"
              opacity="0.8"/>
    </svg>
    """

  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  let shape = image!.shapes[0]
  #expect(shape.fillType == .color)
  #expect(shape.strokeType == .color)
  #expect(shape.strokeWidth == 2.0)
  #expect(shape.strokeLineJoin == .round)
  #expect(shape.strokeLineCap == .round)
  #expect(shape.fillRule == .evenOdd)
  #expect(shape.opacity == 0.8)
}

@Test func testSVGPathProperties() async throws {
  let svgString = """
    <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
        <path d="M10,10 L50,10 L50,50 L10,50 Z" fill="red"/>
    </svg>
    """

  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  let shape = image!.shapes[0]
  let paths = shape.paths
  #expect(paths.count == 1)

  let path = paths[0]
  #expect(path.pointCount > 0)
  #expect(path.points.count == path.pointCount * 2)
  #expect(path.isClosed == true)
}

@Test func testSVGImageParsingFromData() async throws {
  let svgString = """
    <svg width="50" height="50" xmlns="http://www.w3.org/2000/svg">
        <circle cx="25" cy="25" r="20" fill="green"/>
    </svg>
    """

  let data = svgString.data(using: .utf8)!
  let image = SVGImage(data: data)
  #expect(image != nil)

  #expect(image!.width == 50.0)
  #expect(image!.height == 50.0)
  #expect(image!.shapes.count == 1)
}

@Test func testSVGImageParsingWithUnits() async throws {
  let svgString = """
    <svg width="2in" height="2in" xmlns="http://www.w3.org/2000/svg">
        <rect x="0.5in" y="0.5in" width="1in" height="1in" fill="purple"/>
    </svg>
    """

  // Test with different units and DPI
  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  // The image should have been converted to pixels
  #expect(image!.width > 0)
  #expect(image!.height > 0)
}

@Test func testSVGImageParsingFailure() async throws {
  // Test with invalid SVG
  let invalidSVG = "not an svg"
  let image = SVGImage(svgString: invalidSVG)
  #expect(image == nil)

  // Test with empty string
  let emptyImage = SVGImage(svgString: "")
  #expect(emptyImage == nil)
}

@Test func testSVGImageBounds() async throws {
  let svgString = """
    <svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
        <rect x="50" y="50" width="100" height="100" fill="red"/>
    </svg>
    """

  let image = SVGImage(svgString: svgString)
  #expect(image != nil)

  let shape = image!.shapes[0]
  let bounds = shape.bounds
  #expect(bounds.count == 4)  // [minX, minY, maxX, maxY]
  #expect(bounds[0] == 50.0)  // minX
  #expect(bounds[1] == 50.0)  // minY
  #expect(bounds[2] == 150.0)  // maxX
  #expect(bounds[3] == 150.0)  // maxY
}

@Test func testSVGShapeEnums() async throws {
  // Test that our nested enums work correctly
  #expect(SVGShape.PaintType.color.rawValue == 1)
  #expect(SVGShape.PaintType.none.rawValue == 0)
  #expect(SVGShape.PaintType.undefined.rawValue == -1)

  #expect(SVGShape.LineJoin.round.rawValue == 1)
  #expect(SVGShape.LineJoin.miter.rawValue == 0)
  #expect(SVGShape.LineJoin.bevel.rawValue == 2)

  #expect(SVGShape.LineCap.round.rawValue == 1)
  #expect(SVGShape.LineCap.butt.rawValue == 0)
  #expect(SVGShape.LineCap.square.rawValue == 2)

  #expect(SVGShape.FillRule.nonzero.rawValue == 0)
  #expect(SVGShape.FillRule.evenOdd.rawValue == 1)
}

// MARK: - SVGRasterizer Tests

@Test func testSVGRasterizerCreation() async throws {
  // Test creating a rasterizer
  let rasterizer = SVGRasterizer()
  #expect(rasterizer != nil)
}

@Test func testSVGRasterizerBasicRasterization() async throws {
  // Test basic rasterization
  let svgString = """
    <svg width="10" height="10" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="10" height="10" fill="red"/>
    </svg>
    """

  guard let image = SVGImage(svgString: svgString) else {
    Issue.record("Failed to parse SVG")
    return
  }

  guard let rasterizer = SVGRasterizer() else {
    Issue.record("Failed to create rasterizer")
    return
  }

  let pixelData = rasterizer.rasterize(
    image: image,
    width: 10,
    height: 10
  )

  #expect(pixelData != nil)
  #expect(pixelData!.count == 400)  // 10x10x4 (RGBA)
}

@Test func testSVGRasterizerNaturalSize() async throws {
  // Test rasterization at natural size
  let svgString = """
    <svg width="5" height="5" xmlns="http://www.w3.org/2000/svg">
        <circle cx="2.5" cy="2.5" r="2" fill="blue"/>
    </svg>
    """

  guard let image = SVGImage(svgString: svgString) else {
    Issue.record("Failed to parse SVG")
    return
  }

  guard let rasterizer = SVGRasterizer() else {
    Issue.record("Failed to create rasterizer")
    return
  }

  let pixelData = rasterizer.rasterize(image: image)

  #expect(pixelData != nil)
  #expect(pixelData!.count == 100)  // 5x5x4 (RGBA)
}

@Test func testSVGRasterizerToArray() async throws {
  // Test rasterization to 2D array
  let svgString = """
    <svg width="3" height="3" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="3" height="3" fill="green"/>
    </svg>
    """

  guard let image = SVGImage(svgString: svgString) else {
    Issue.record("Failed to parse SVG")
    return
  }

  guard let rasterizer = SVGRasterizer() else {
    Issue.record("Failed to create rasterizer")
    return
  }

  let array2D = rasterizer.rasterizeToArray(
    image: image,
    width: 3,
    height: 3
  )

  #expect(array2D != nil)
  #expect(array2D!.count == 3)  // 3 rows
  #expect(array2D![0].count == 12)  // 3 columns * 4 bytes (RGBA)
}

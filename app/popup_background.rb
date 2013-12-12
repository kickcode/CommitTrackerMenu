# Drawing code for the popup panel background ported from the excellent Obj-C popup demo code
# https://github.com/shpakovski/Popup / http://blog.shpakovski.com/2011/07/cocoa-popup-window-in-status-bar.html
class PopupBackground < NSView
  ARROW_HEIGHT = 12
  ARROW_WIDTH = 15

  LINE_THICKNESS = 1
  CORNER_RADIUS = 20

  def drawRect(rect)
    return unless @arrow_x
    content_rect = NSInsetRect(self.bounds, LINE_THICKNESS, LINE_THICKNESS)
    path = NSBezierPath.bezierPath

    path.moveToPoint(NSMakePoint(@arrow_x, NSMaxY(content_rect)))
    path.lineToPoint(NSMakePoint(@arrow_x + ARROW_WIDTH / 2, NSMaxY(content_rect) - ARROW_HEIGHT))
    path.lineToPoint(NSMakePoint(NSMaxX(content_rect) - CORNER_RADIUS, NSMaxY(content_rect) - ARROW_HEIGHT))

    top_right_corner = NSMakePoint(NSMaxX(content_rect), NSMaxY(content_rect) - ARROW_HEIGHT)
    path.curveToPoint(NSMakePoint(NSMaxX(content_rect), NSMaxY(content_rect) - ARROW_HEIGHT - CORNER_RADIUS), controlPoint1: top_right_corner, controlPoint2: top_right_corner)

    path.lineToPoint(NSMakePoint(NSMaxX(content_rect), NSMinY(content_rect) + CORNER_RADIUS))

    bottom_right_corner = NSMakePoint(NSMaxX(content_rect), NSMinY(content_rect))
    path.curveToPoint(NSMakePoint(NSMaxX(content_rect) - CORNER_RADIUS, NSMinY(content_rect)), controlPoint1: bottom_right_corner, controlPoint2: bottom_right_corner)

    path.lineToPoint(NSMakePoint(NSMinX(content_rect) + CORNER_RADIUS, NSMinY(content_rect)))

    path.curveToPoint(NSMakePoint(NSMinX(content_rect), NSMinY(content_rect) + CORNER_RADIUS), controlPoint1: content_rect.origin, controlPoint2: content_rect.origin)

    path.lineToPoint(NSMakePoint(NSMinX(content_rect), NSMaxY(content_rect) - ARROW_HEIGHT - CORNER_RADIUS))

    top_left_corner = NSMakePoint(NSMinX(content_rect), NSMaxY(content_rect) - ARROW_HEIGHT)
    path.curveToPoint(NSMakePoint(NSMinX(content_rect) + CORNER_RADIUS, NSMaxY(content_rect) - ARROW_HEIGHT), controlPoint1: top_left_corner, controlPoint2: top_left_corner)

    path.lineToPoint(NSMakePoint(@arrow_x - ARROW_WIDTH / 2, NSMaxY(content_rect) - ARROW_HEIGHT))
    path.closePath

    NSColor.whiteColor.setFill
    path.fill

    NSGraphicsContext.saveGraphicsState

    clip = NSBezierPath.bezierPathWithRect(self.bounds)
    clip.appendBezierPath(path)
    clip.addClip

    path.setLineWidth(LINE_THICKNESS * 2)
    NSColor.lightGrayColor.setStroke
    path.stroke

    NSGraphicsContext.restoreGraphicsState
  end

  def setArrowX(value)
    @arrow_x = value
    self.setNeedsDisplay(true)
  end
end
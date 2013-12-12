class PopupPanel < NSPanel
  POPUP_WIDTH = 400
  POPUP_HEIGHT = 280

  def initPopup
    self.initWithContentRect([[0, 0], [POPUP_WIDTH, POPUP_HEIGHT]],
      styleMask: NSBorderlessWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    self.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    self.delegate = self
    self.setBackgroundColor(NSColor.clearColor)
    self.setOpaque(false)

    @background = PopupBackground.alloc.initWithFrame(self.frame)
    self.setContentView(@background)

    self
  end

  def showHide(sender)
    if @showing
      self.orderOut(false)
      @showing = false
    else
      event_frame = NSApp.currentEvent.window.frame
      window_frame = self.frame
      window_top_left_position = CGPointMake(event_frame.origin.x + (event_frame.size.width / 2) - (window_frame.size.width / 2), event_frame.origin.y)
      
      self.setFrameTopLeftPoint(window_top_left_position)
      @background.setArrowX(window_frame.size.width / 2)

      NSApp.activateIgnoringOtherApps(true)
      self.makeKeyAndOrderFront(self)
      @showing = true
    end
  end

  def canBecomeKeyWindow
    true
  end

  def canBecomeMainWindow
    true
  end

  def windowShouldClose(sender)
    showHide(sender)
    false
  end

  def windowDidResignKey(sender)
    @showing = false
  end

  def windowDidResignMain(sender)
    @showing = false
  end
end
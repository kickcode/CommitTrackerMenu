Commit = Struct.new(:name, :repo, :message, :avatar, :url)

class CommitView < NSView
  attr_accessor :box, :message, :avatar

  def initWithFrame(rect)
    super(NSMakeRect(rect.origin.x, rect.origin.y, PopupPanel::POPUP_WIDTH, 70))

    @box = NSBox.alloc.initWithFrame(NSInsetRect(self.bounds, 5, 3))
    self.addSubview(@box)

    @avatar = NSImageView.alloc.initWithFrame(NSMakeRect(0, 0, 40, 40))
    @box.addSubview(@avatar)

    @message = NSTextField.alloc.initWithFrame(NSMakeRect(50, 0, 320, 40))
    @message.drawsBackground = false
    @message.setEditable false
    @message.setSelectable false
    @message.setBezeled false
    @box.addSubview(@message)

    self
  end

  def setViewObject(object)
    return if object.nil?
    self.box.title = "#{object.name} - #{object.repo}"
    self.message.stringValue = object.message
    self.avatar.setImage(NSImage.alloc.initWithData(NSURL.URLWithString(object.avatar).resourceDataUsingCache(false)))
    @object = object
  end

  def mouseDown(event)
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(@object.url))
  end
end

class CommitPrototype < NSCollectionViewItem
  def loadView
    self.setView(CommitView.alloc.initWithFrame(NSZeroRect))
  end

  def setRepresentedObject(object)
    super(object)
    self.view.setViewObject(object)
  end
end
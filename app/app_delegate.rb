class AppDelegate
  SCROLL_VIEW_INSET = 3
  BUTTON_WIDTH = 100
  BUTTON_HEIGHT = 30

  CONFIG = YAML::load(NSMutableData.dataWithContentsOfURL(NSBundle.mainBundle.URLForResource("config", withExtension: "yml")).to_s)
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    buildMenu
    buildWindow

    @unseen = 0
    @github = GitHub.new(CONFIG[:github_token]) do
      self.checkForNewEvents
    end

    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
  end

  def buildMenu
    @status_menu = NSMenu.new
    @status_menu.delegate = self

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setHighlightMode(true)
    @status_item.setTitle(@app_name)
    @status_item.setTarget(self)
    @status_item.setAction('showHide:')

    @http_state = createMenuItem("Loading...", '')
    @http_state.enabled = false
    @status_menu.addItem @http_state

    @status_menu.addItem createMenuItem("About #{@app_name}", 'orderFrontStandardAboutPanel:')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def showHide(sender)
    @unseen = 0
    self.showUnseenCommits
    @window.showHide(sender)
  end

  def buildWindow
    @window = PopupPanel.alloc.initPopup

    scroll_view = NSScrollView.alloc.initWithFrame(NSInsetRect(@window.contentView.frame, PopupBackground::LINE_THICKNESS + SCROLL_VIEW_INSET, PopupBackground::ARROW_HEIGHT + SCROLL_VIEW_INSET + (BUTTON_HEIGHT / 2)))
    scroll_view.hasVerticalScroller = true
    @window.contentView.addSubview(scroll_view)

    @collection_view = NSCollectionView.alloc.initWithFrame(scroll_view.frame)
    @collection_view.setItemPrototype(CommitPrototype.new)

    scroll_view.documentView = @collection_view

    @options_button = NSButton.alloc.initWithFrame(NSMakeRect(PopupPanel::POPUP_WIDTH - BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT))
    @options_button.setTitle("Options")
    @options_button.setButtonType(NSMomentaryLightButton)
    @options_button.setBezelStyle(NSRoundedBezelStyle)
    @options_button.setTarget(self)
    @options_button.setAction('showMenu:')
    @window.contentView.addSubview(@options_button)
  end

  def showMenu(sender)
    NSMenu.popUpContextMenu(@status_menu, withEvent: NSApp.currentEvent, forView: sender)
  end

  def checkForNewEvents
    begin
      @http_state.title = "Working..."
      @github.events do |events|
        @http_state.title = "Processing..."
        unless events.empty?
          @last_commits = @commits || []
          @commits = []
          @data = []

          events.reverse.each do |event|
            next unless event["type"] == "PushEvent"
            next if event["payload"].nil? || event["payload"]["commits"].nil?

            commits = event["payload"]["commits"].select { |c| c["distinct"] }

            next if commits.length == 0

            actor = event['actor']['login']
            repo = event['repo']['name']
            avatar = event['actor']['avatar_url']

            commits.each do |commit|
              message = commit['message'].split("\n").join(" ")
              url = commit['url'].gsub("api.", "").gsub("/repos", "").gsub("/commits", "/commit")
              @commits << commit['sha']
              @data << Commit.new(actor, repo, message, avatar, url)
            end
          end

          new_commits = (@commits - @last_commits).length
          @unseen += new_commits
          self.showUnseenCommits
          self.showNotification(new_commits)
        end
        @http_state.title = "Ready"
        @collection_view.setContent(@data)
      end
    rescue
      @http_state.title = "Error, retrying again shortly"
    ensure
      NSTimer.scheduledTimerWithTimeInterval(CONFIG[:timer], target: self, selector: 'checkForNewEvents', userInfo: nil, repeats: false)
    end
  end

  def showUnseenCommits
    @status_item.setTitle("#{@unseen.zero? ? 'No' : @unseen} new #{@unseen == 1 ? 'commit' : 'commits'}")
  end

  def showNotification(new_commits)
    return unless new_commits > 0
    notification = NSUserNotification.alloc.init
    notification.title = "New commits"
    notification.informativeText = "There are #{new_commits} new commits."
    notification.soundName = NSUserNotificationDefaultSoundName
    NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
  end

  def userNotificationCenter(center, didActivateNotification: notification)
    @status_item.popUpStatusItemMenu(@status_menu)
    center.removeDeliveredNotification(notification)
  end
end
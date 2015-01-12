class Hello < Protocol
  def default

  end
end

class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
    sendMessage
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
  end

  def sendMessage
    connection = NSXPCConnection.alloc.initWithServiceName("com.sm.lapsus")
    connection.remoteObjectInterface = JGXPCInterface.interface
    connection.resume

    connection.remoteObjectProxy.sendMessage('hello boys')

    connection.invalidate
  end
end

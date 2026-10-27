import AppKit
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventTap: ScrollEventTap!
    private var mainWindow: MainWindowController!
    private var statusItem: NSStatusItem?

    private lazy var activeItem = NSMenuItem(title: "Activo", action: #selector(toggleActive), keyEquivalent: "")
    private lazy var loginItem = NSMenuItem(title: "Abrir al iniciar sesión", action: #selector(toggleLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Solo barra de menús: no Dock, no ventana al arrancar (no molesta).
        NSApp.setActivationPolicy(.accessory)

        eventTap = ScrollEventTap()
        mainWindow = MainWindowController(eventTap: eventTap) { [weak self] in
            self?.refreshMenu()
        }

        setupStatusItem()
        // Inicio al login (API oficial, reversible en Ajustes → Elementos de inicio).
        if !LoginItem.isEnabled {
            _ = LoginItem.setEnabled(true)
        }
        // Intentar inversión al arrancar (tras reinicio / login).
        tryStartInvertingQuietly()
        refreshMenu()

        // Solo si se lanza con --show (o desde el menú). En el login no molesta.
        if CommandLine.arguments.contains("--show") {
            showWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        eventTap?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            let icon = AppIconDrawing.image(size: 36)
            icon.size = NSSize(width: 18, height: 18)
            button.image = icon
            button.toolTip = "MouseScroll"
        }

        let menu = NSMenu()
        activeItem.target = self
        loginItem.target = self
        menu.addItem(activeItem)
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem.separator())

        let show = NSMenuItem(title: "Mostrar ventana…", action: #selector(showWindow), keyEquivalent: "")
        show.target = self
        menu.addItem(show)

        menu.addItem(NSMenuItem.separator())
        let quit = NSMenuItem(title: "Salir", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    private func tryStartInvertingQuietly() {
        _ = AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false
        ] as CFDictionary)
        _ = eventTap.startInverting()
    }

    func refreshMenu() {
        activeItem.state = eventTap.isActive ? .on : .off
        loginItem.state = LoginItem.isEnabled ? .on : .off
        if let button = statusItem?.button {
            button.appearsDisabled = !eventTap.isActive
        }
        mainWindow?.refresh()
    }

    @objc private func toggleActive() {
        if eventTap.isActive {
            eventTap.stop()
        } else {
            AXIsProcessTrustedWithOptions([
                kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
            ] as CFDictionary)
            if !eventTap.startInverting() {
                showWindow()
            }
        }
        refreshMenu()
    }

    @objc private func toggleLogin() {
        let want = !LoginItem.isEnabled
        if !LoginItem.setEnabled(want) {
            let alert = NSAlert()
            alert.messageText = "No se pudo cambiar el inicio de sesión"
            alert.informativeText = "Puedes gestionarlo en Ajustes → Generales → Elementos de inicio y extensión."
            alert.runModal()
        }
        refreshMenu()
    }

    @objc func showWindow() {
        NSApp.setActivationPolicy(.accessory)
        mainWindow?.showFront()
    }

    @objc private func quit() {
        eventTap.stop()
        NSApp.terminate(nil)
    }

    static func loadAppIcon() -> NSImage? {
        loadResourceImage(name: "AppIcon", ext: "icns")
    }

    /// PNG de la ventana. Busca en varias rutas porque SPM a veces no resuelve Bundle.main.
    static func loadWindowIcon() -> NSImage? {
        if let image = loadResourceImage(name: "IconUI", ext: "png") {
            image.size = NSSize(width: 80, height: 80)
            return image
        }
        return loadAppIcon()
    }

    private static func loadResourceImage(name: String, ext: String) -> NSImage? {
        var urls: [URL] = []
        if let u = Bundle.main.url(forResource: name, withExtension: ext) {
            urls.append(u)
        }
        if let exe = Bundle.main.executableURL {
            // …/App.app/Contents/MacOS/exec → …/App.app/Contents/Resources/
            let resources = exe
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Resources", isDirectory: true)
            urls.append(resources.appendingPathComponent("\(name).\(ext)"))
        }
        let bundleRoot = Bundle.main.bundleURL
        urls.append(bundleRoot.appendingPathComponent("Contents/Resources/\(name).\(ext)"))
        urls.append(bundleRoot.appendingPathComponent("Resources/\(name).\(ext)"))

        for url in urls {
            if let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}

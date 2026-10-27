import AppKit
import ApplicationServices

final class MainWindowController: NSWindowController {
    private let eventTap: ScrollEventTap
    private let onStateChange: () -> Void

    private let iconView = NSImageView()
    private let iconPlate = NSView()
    private let titleLabel = NSTextField(labelWithString: "MouseScroll")
    private let subtitleLabel = NSTextField(wrappingLabelWithString: "Trackpad natural · Ratón clásico")
    private let versionLabel = NSTextField(labelWithString: "v1.4")
    private let statusDot = NSView()
    private let statusLabel = NSTextField(labelWithString: "Desactivado")
    private let toggle = NSSwitch()
    private let toggleCaption = NSTextField(labelWithString: "Activo")
    private let loginToggle = NSSwitch()
    private let loginCaption = NSTextField(labelWithString: "Al iniciar sesión")
    private let hintLabel = NSTextField(wrappingLabelWithString: " ")
    private let hideButton = NSButton(title: "Ocultar", target: nil, action: nil)

    private let windowWidth: CGFloat = 380
    private let windowHeight: CGFloat = 440

    init(eventTap: ScrollEventTap, onStateChange: @escaping () -> Void) {
        self.eventTap = eventTap
        self.onStateChange = onStateChange

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "MouseScroll"
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor(calibratedWhite: 0.11, alpha: 1)
        window.minSize = NSSize(width: windowWidth, height: windowHeight)

        super.init(window: window)
        window.contentView = buildUI()
        centerOnMainScreen()

        eventTap.onChange = { [weak self] in
            DispatchQueue.main.async {
                self?.refresh()
                self?.onStateChange()
            }
        }
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func buildUI() -> NSView {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))

        configureIcon()
        styleLabel(titleLabel, size: 24, weight: .semibold, color: .white, center: true, wrap: false)
        styleLabel(subtitleLabel, size: 13, weight: .regular, color: NSColor(white: 0.62, alpha: 1), center: true, wrap: true)
        styleLabel(versionLabel, size: 11, weight: .regular, color: NSColor(white: 0.4, alpha: 1), center: true, wrap: false)
        styleLabel(statusLabel, size: 13, weight: .medium, color: .white, center: false, wrap: false)
        styleLabel(toggleCaption, size: 13, weight: .medium, color: .white, center: false, wrap: false)
        styleLabel(loginCaption, size: 13, weight: .medium, color: .white, center: false, wrap: false)
        styleLabel(hintLabel, size: 12, weight: .regular, color: NSColor(white: 0.48, alpha: 1), center: true, wrap: true)

        statusDot.wantsLayer = true
        statusDot.layer?.cornerRadius = 5
        statusDot.translatesAutoresizingMaskIntoConstraints = false

        toggle.target = self
        toggle.action = #selector(toggleChanged)
        loginToggle.target = self
        loginToggle.action = #selector(loginChanged)

        hideButton.bezelStyle = .rounded
        hideButton.target = self
        hideButton.action = #selector(hide)

        let statusRow = NSStackView(views: [statusDot, statusLabel])
        statusRow.orientation = .horizontal
        statusRow.spacing = 8
        statusRow.alignment = .centerY
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let switchRow = row(left: toggleCaption, right: toggle)
        let loginRow = row(left: loginCaption, right: loginToggle)

        let card = NSView()
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor(calibratedWhite: 0.16, alpha: 1).cgColor
        card.layer?.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        let cardStack = NSStackView(views: [statusRow, switchRow, loginRow])
        cardStack.orientation = .vertical
        cardStack.spacing = 16
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)

        let header = NSStackView(views: [titleLabel, versionLabel])
        header.orientation = .vertical
        header.spacing = 2
        header.alignment = .centerX

        let stack = NSStackView(views: [iconPlate, header, subtitleLabel, card, hintLabel, hideButton])
        stack.orientation = .vertical
        stack.spacing = 14
        stack.alignment = .centerX
        stack.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: root.topAnchor, constant: 28),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -24),

            iconPlate.widthAnchor.constraint(equalToConstant: 88),
            iconPlate.heightAnchor.constraint(equalToConstant: 88),
            iconView.widthAnchor.constraint(equalToConstant: 72),
            iconView.heightAnchor.constraint(equalToConstant: 72),
            iconView.centerXAnchor.constraint(equalTo: iconPlate.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconPlate.centerYAnchor),

            subtitleLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
            hintLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
            titleLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
            header.widthAnchor.constraint(equalTo: stack.widthAnchor),

            card.widthAnchor.constraint(equalTo: stack.widthAnchor),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),

            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),
            switchRow.widthAnchor.constraint(equalTo: cardStack.widthAnchor),
            loginRow.widthAnchor.constraint(equalTo: cardStack.widthAnchor),
            hideButton.widthAnchor.constraint(equalToConstant: 110)
        ])

        return root
    }

    private func configureIcon() {
        iconPlate.wantsLayer = true
        iconPlate.layer?.backgroundColor = NSColor(calibratedWhite: 0.18, alpha: 1).cgColor
        iconPlate.layer?.cornerRadius = 22
        iconPlate.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = AppIconDrawing.image(size: 160) // 2x para retina
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.imageAlignment = .alignCenter
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconPlate.addSubview(iconView)
    }

    private func styleLabel(
        _ label: NSTextField,
        size: CGFloat,
        weight: NSFont.Weight,
        color: NSColor,
        center: Bool,
        wrap: Bool
    ) {
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.alignment = center ? .center : .left
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.lineBreakMode = wrap ? .byWordWrapping : .byTruncatingTail
        label.maximumNumberOfLines = wrap ? 0 : 1
        label.usesSingleLineMode = !wrap
        if wrap {
            label.preferredMaxLayoutWidth = windowWidth - 56
        }
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func row(left: NSView, right: NSView) -> NSStackView {
        let row = NSStackView(views: [left, right])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.distribution = .equalSpacing
        left.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    func showFront() {
        centerOnMainScreen()
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        refresh()
    }

    private func centerOnMainScreen() {
        guard let window else { return }
        let visible = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        var frame = window.frame
        frame.size = NSSize(width: windowWidth, height: windowHeight)
        frame.origin.x = visible.midX - frame.width / 2
        frame.origin.y = visible.midY - frame.height / 2
        window.setFrame(frame, display: true)
    }

    func refresh() {
        let on = eventTap.isActive
        toggle.state = on ? .on : .off
        loginToggle.state = LoginItem.isEnabled ? .on : .off
        statusLabel.stringValue = on ? "Activo en segundo plano" : "Desactivado"
        statusDot.layer?.backgroundColor = (on ? NSColor.systemGreen : NSColor.systemOrange).cgColor
        hintLabel.stringValue = on
            ? "Puedes ocultar esta ventana. Sigue en la barra de menús."
            : "Activa el interruptor. Requiere Accesibilidad (solo esta app)."
        hintLabel.preferredMaxLayoutWidth = windowWidth - 56
    }

    @objc private func toggleChanged() {
        if toggle.state == .on {
            AXIsProcessTrustedWithOptions([
                kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
            ] as CFDictionary)
            if !eventTap.startInverting() {
                toggle.state = .off
                let alert = NSAlert()
                alert.messageText = "Falta Accesibilidad"
                alert.informativeText = "Añade ~/Applications/MouseScroll.app en Accesibilidad, Salir y vuelve a abrir."
                alert.addButton(withTitle: "Abrir Ajustes")
                alert.addButton(withTitle: "OK")
                if alert.runModal() == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        } else {
            eventTap.stop()
        }
        refresh()
        onStateChange()
    }

    @objc private func loginChanged() {
        let want = loginToggle.state == .on
        if !LoginItem.setEnabled(want) {
            loginToggle.state = LoginItem.isEnabled ? .on : .off
            let alert = NSAlert()
            alert.messageText = "No se pudo cambiar"
            alert.informativeText = "Ajustes → Generales → Elementos de inicio y extensión."
            alert.runModal()
        }
        refresh()
        onStateChange()
    }

    @objc private func hide() {
        window?.orderOut(nil)
    }
}

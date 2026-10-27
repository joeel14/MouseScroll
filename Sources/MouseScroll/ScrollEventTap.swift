import AppKit
import CoreGraphics
import Foundation

/// Event tap solo para scrollWheel. Invierte únicamente eventos discretos.
final class ScrollEventTap {
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var inverting = false
    private static var shared: ScrollEventTap?

    var onChange: (() -> Void)?

    var isActive: Bool { tap != nil && inverting }

    init() {
        ScrollEventTap.shared = self
    }

    @discardableResult
    func startInverting() -> Bool {
        stop()
        inverting = true

        let mask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        guard let newTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: ScrollEventTap.callback,
            userInfo: nil
        ) else {
            inverting = false
            onChange?()
            return false
        }

        tap = newTap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, newTap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: newTap, enable: true)
        onChange?()
        return true
    }

    func stop() {
        if let existing = tap {
            CGEvent.tapEnable(tap: existing, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        runLoopSource = nil
        tap = nil
        inverting = false
        onChange?()
    }

    private static let callback: CGEventTapCallBack = { _, type, event, _ in
        guard let instance = ScrollEventTap.shared else {
            return Unmanaged.passUnretained(event)
        }

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = instance.tap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        guard type == .scrollWheel, instance.inverting else {
            return Unmanaged.passUnretained(event)
        }

        // Solo ratón de rueda discreta. Trackpad (continuo) no se toca.
        let continuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0
        if !continuous {
            let d1 = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
            let d2 = event.getIntegerValueField(.scrollWheelEventDeltaAxis2)
            event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -d1)
            event.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: -d2)
        }

        return Unmanaged.passUnretained(event)
    }
}

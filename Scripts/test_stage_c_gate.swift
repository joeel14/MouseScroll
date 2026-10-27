#!/usr/bin/env swift
import Foundation

// Mini-prueba de la lógica de puerta Etapa C (sin event taps ni permisos).
// Ejecutar: swift Scripts/test_stage_c_gate.swift

struct Sample {
    let continuous: Bool
}

final class Gate {
    var continuous = 0
    var discrete = 0
    var hasDisjointEvidence: Bool { continuous > 0 && discrete > 0 }
    func append(_ s: Sample) {
        if s.continuous { continuous += 1 } else { discrete += 1 }
    }
    func report() -> String {
        if hasDisjointEvidence { return "GO" }
        if continuous == 0 && discrete == 0 { return "NO-GO-empty" }
        if continuous > 0 { return "NO-GO-continuous-only" }
        return "NO-GO-discrete-only"
    }
}

var failed = 0
func expect(_ name: String, _ cond: Bool) {
    if cond {
        print("OK  \(name)")
    } else {
        print("FAIL \(name)")
        failed += 1
    }
}

let empty = Gate()
expect("empty is NO-GO", empty.report() == "NO-GO-empty")

let onlyTrackpad = Gate()
onlyTrackpad.append(Sample(continuous: true))
expect("trackpad-only is NO-GO", onlyTrackpad.report() == "NO-GO-continuous-only")
expect("trackpad-only gate false", onlyTrackpad.hasDisjointEvidence == false)

let onlyMouse = Gate()
onlyMouse.append(Sample(continuous: false))
expect("mouse-only is NO-GO", onlyMouse.report() == "NO-GO-discrete-only")

let both = Gate()
both.append(Sample(continuous: true))
both.append(Sample(continuous: false))
expect("both is GO", both.report() == "GO")
expect("both gate true", both.hasDisjointEvidence == true)

if failed > 0 {
    print("Result: \(failed) failure(s)")
    exit(1)
}
print("Result: all gate tests passed")

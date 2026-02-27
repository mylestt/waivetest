import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @State private var engine: CHHapticEngine?
    @State private var player: CHHapticAdvancedPatternPlayer?
    @State private var isTouchingLine = false
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                // Vertical thick line
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 25)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        
                        let lineX = geometry.size.width / 2
                        let touchX = value.location.x
                        
                        if abs(touchX - lineX) < 30 {
                            if !isTouchingLine {
                                isTouchingLine = true
                                startHaptics()
                            }
                        } else {
                            stopHaptics()
                        }
                    }
                    .onEnded { _ in
                        stopHaptics()
                    }
            )
            .onAppear {
                prepareHaptics()
            }
        }
    }
    
    // MARK: - Core Haptics Setup
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }
    
    func startHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        // Long continuous vibration
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 10 // long duration (we stop it manually)
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine?.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    func stopHaptics() {
        isTouchingLine = false
        try? player?.stop(atTime: 0)
    }
}

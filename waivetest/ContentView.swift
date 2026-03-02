import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    // Stores the Core Haptics engine that powers vibration feedback
    @State private var engine: CHHapticEngine?
    
    // Stores the haptic player used to start and stop the vibration pattern
    @State private var player: CHHapticAdvancedPatternPlayer?
    
    // Tracks whether the user's finger is currently touching the line area
    @State private var isTouchingLine = false
    
    var body: some View {
        // GeometryReader gives access to the screen size so we can center the line
        GeometryReader { geometry in
            
            // ZStack layers views on top of each other
            ZStack {
                
                // White background that fills the entire screen
                Color.white
                    .ignoresSafeArea()
                
                // Draws a thick vertical black line in the center of the screen
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 25)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            // Adds a drag gesture so touch movement can be tracked
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        
                        // X position of the center line
                        let lineX = geometry.size.width / 2
                        
                        // Current X position of the user's touch
                        let touchX = value.location.x
                        
                        // If the finger is close enough to the line, start haptics
                        if abs(touchX - lineX) < 30 {
                            
                            // Only start haptics once when first entering the line area
                            if !isTouchingLine {
                                isTouchingLine = true
                                startHaptics()
                            }
                        } else {
                            // If the finger moves away from the line, stop haptics
                            stopHaptics()
                        }
                    }
                    .onEnded { _ in
                        // When the user lifts their finger, stop haptics
                        stopHaptics()
                    }
            )
            .onAppear {
                // Prepare the haptic engine when the view appears
                prepareHaptics()
            }
        }
    }
    
    // MARK: - Core Haptics Setup
    
    func prepareHaptics() {
        // Make sure the current device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            // Create the haptic engine
            engine = try CHHapticEngine()
            
            // Start the engine so it is ready to play haptic patterns
            try engine?.start()
        } catch {
            // Print an error if the engine could not be created or started
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }
    
    func startHaptics() {
        // Make sure the current device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        // Sets the strength of the vibration
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        
        // Sets how sharp/crisp the vibration feels
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        // Creates one long continuous vibration event
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 10 // Plays for up to 10 seconds unless stopped sooner
        )
        
        do {
            // Build a haptic pattern from the event
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            // Create an advanced player so the pattern can be started and stopped manually
            player = try engine?.makeAdvancedPlayer(with: pattern)
            
            // Start the haptic pattern immediately
            try player?.start(atTime: 0)
        } catch {
            // Print an error if the haptic pattern fails to play
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    func stopHaptics() {
        // Reset the tracking state so haptics can be started again later
        isTouchingLine = false
        
        // Stop the current haptic pattern immediately
        try? player?.stop(atTime: 0)
    }
}

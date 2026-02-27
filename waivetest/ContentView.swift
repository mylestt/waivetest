import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var isTouchingLine = false
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        
                        let lineY = geometry.size.height / 2
                        let touchY = value.location.y
                        
                        if abs(touchY - lineY) < 20 {
                            if !isTouchingLine {
                                isTouchingLine = true
                                
                                // Modern haptic (no UIKit needed)
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        } else {
                            isTouchingLine = false
                        }
                    }
                    .onEnded { _ in
                        isTouchingLine = false
                    }
            )
        }
    }
}

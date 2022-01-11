//
//  ContentView.swift
//  Game of Life
//
//  Created by Anton Heestand on 2022-01-11.
//

import SwiftUI
import RenderKit
import PixelKit

class GameOfLife: ObservableObject {
    
    let polygonPix = PolygonPIX(at: .square(2000))
    var sourcePix: (PIX & NODEOut)!
    let feedbackPix = FeedbackPIX()
    let metalEffectPix = MetalEffectPIX()
    let transformPix = TransformPIX()
    
    let blendPix = BlendPIX()
    let finalPix: PIX!
    
    
    init() {
        
        polygonPix.radius = 1.0 / 3.0
        
        sourcePix = polygonPix
        
        feedbackPix.input = sourcePix
        feedbackPix.viewInterpolation = .nearest
        
        metalEffectPix.input = feedbackPix
        metalEffectPix.code = """
        bool center = tex.sample(s, uv).r > 0.5;
        bool topLeft = tex.sample(s, float2(u - wu, v - hv)).r > 0.5;
        bool top = tex.sample(s, float2(u, v - hv)).r > 0.5;
        bool topRight = tex.sample(s, float2(u + wu, v - hv)).r > 0.5;
        bool right = tex.sample(s, float2(u + wu, v)).r > 0.5;
        bool bottomRight = tex.sample(s, float2(u + wu, v + hv)).r > 0.5;
        bool bottom = tex.sample(s, float2(u, v + hv)).r > 0.5;
        bool bottomLeft = tex.sample(s, float2(u - wu, v + hv)).r > 0.5;
        bool left = tex.sample(s, float2(u - wu, v)).r > 0.5;
        int neighbours = 0;
        if (topLeft) { neighbours += 1; }
        if (top) { neighbours += 1; }
        if (topRight) { neighbours += 1; }
        if (right) { neighbours += 1; }
        if (bottomRight) { neighbours += 1; }
        if (bottom) { neighbours += 1; }
        if (bottomLeft) { neighbours += 1; }
        if (left) { neighbours += 1; }
        bool alive = center;
        if (alive) {
            if (neighbours < 2) {
                alive = false;
            } else if (neighbours > 3) {
                alive = false;
            }
        } else {
            if (neighbours == 3) {
                alive = true;
            }
        }
        return float4(float3(alive), 1.0);
        """
        
        transformPix.input = metalEffectPix
        transformPix.scale = 1.01
        
        blendPix.blendMode = .difference
        blendPix.inputA = transformPix
        blendPix.inputB = sourcePix
        
        feedbackPix.feedbackInput = blendPix
        
        finalPix = metalEffectPix// + sourcePix * 0.1
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.polygonPix.rotation += 0.002
        }
    }
    
}

struct ContentView: View {
    
    @StateObject var gameOfLife = GameOfLife()
    
    var body: some View {
        PixelView(pix: gameOfLife.finalPix)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

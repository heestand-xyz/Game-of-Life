//
//  ContentView.swift
//  Game of Life
//
//  Created by Anton Heestand on 2022-01-11.
//

import SwiftUI
import RenderKit
import PixelKit

struct ContentView: View {
    
    @StateObject var polygonPix = PolygonPIX(at: .square(1000))
    @StateObject var feedbackPix = FeedbackPIX()
    @StateObject var metalEffectPix = MetalEffectPIX()
    @StateObject var crossPix = CrossPIX()
    var finalPix: PIX { metalEffectPix }
    
    var body: some View {
        PixelView(pix: finalPix)
            .onAppear {
                polygonPix.radius = 0.05
                
                feedbackPix.input = polygonPix
                feedbackPix.viewInterpolation = .nearest
                
                metalEffectPix.input = feedbackPix
                metalEffectPix.code = """
                //float2 pos = float2(v, u);
                return 1;//tex.sample(s, pos);
                """
                
                crossPix.fraction = 0.5
                crossPix.inputA = polygonPix
                crossPix.inputB = metalEffectPix
                
                feedbackPix.feedbackInput = crossPix
                
//                polygonPix.render()
//                metalEffectPix.render()
//                crossPix.render()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

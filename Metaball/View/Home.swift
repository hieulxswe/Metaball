//
//  Home.swift
//  Metaball
//
//  Created by Hieu Xuan Leu on 10/6/2023.
//

import SwiftUI

struct Home: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    @State private var scrollProgress:CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        let isHavingNotch = safeArea.bottom != 0
        ScrollView(.vertical, showsIndicators: true){
            VStack(spacing: 12){
                Image("hieu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    
                    .frame(width: 130 - (75 * scrollProgress), height: 130 - (75 * scrollProgress))
                    .opacity(1 - scrollProgress)
                    .blur(radius: scrollProgress * 10, opaque: true)
                    .clipShape(Circle())
                    .anchorPreference(key: AnchorKey.self, value: .bounds, transform: {
                        return ["HEADER": $0]
                    })
                    .padding(.top, safeArea.top + 15)
                    .offsetExtractor(coordinateSpace: "ScrollView"){scrollRect in
                        guard isHavingNotch else {return}
                        let progress = -scrollRect.minY / 25
                        scrollProgress = min(max(progress, 0), 1)
                    }
//                
//                Text("HIEU X. LEU")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.gray)
//                    .padding(.vertical, 15)
                
                SampleRows()
            }

            .frame(maxWidth: .infinity)
        }
        .backgroundPreferenceValue(AnchorKey.self, { pref in
            GeometryReader{ proxy in
                if let anchor = pref["HEADER"], isHavingNotch{
                    let frameRect = proxy[anchor]
                    let isHavingDynamicIsland = safeArea.top > 51
                    let capsuleHeight = isHavingDynamicIsland ? 37 : (safeArea.top - 15)
                    Canvas{ out, size in
                        out.addFilter(.alphaThreshold(min: 0.5))
                        out.addFilter(.blur(radius: 12))
                        
                        out.drawLayer{ ctx in
                            if let headerView = out.resolveSymbol(id: 0){
                                ctx.draw(headerView, in: frameRect)
                            }
                            if let dynamicIsland = out.resolveSymbol(id: 1){
                                let rect = CGRect(x: (size.width - 120)/2, y: isHavingDynamicIsland ? 11 : 0, width: 120, height: capsuleHeight)
                                ctx.draw(dynamicIsland, in: rect)
                            }
                        }
                    } symbols: {
                        HeaderView(frameRect)
                            .tag(0)
                            .id(0)
                        DynamicIslandCapsule(capsuleHeight)
                            .tag(1)
                            .id(1)
                    }
                }
            }
            .overlay(alignment: .top){
                Rectangle()
                    .fill(colorScheme == .dark ? .black : .white)
                    .frame(height: 15)
            }
        })
        .coordinateSpace(name: "ScrollView")
    }
}

@ViewBuilder
func HeaderView(_ frameRect: CGRect) -> some View {
    Circle()
        .fill(.black)
        .frame(width: frameRect.width, height: frameRect.height)
}

@ViewBuilder
func DynamicIslandCapsule(_ height: CGFloat = 37) -> some View{
    Capsule()
        .fill(.black)
        .frame(width: 120, height: height)
}


@ViewBuilder
func SampleRows() -> some View{
    VStack{
        ForEach(1...20, id: \.self){ _ in
            VStack(alignment: .leading, spacing: 6){
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(.gray.opacity(0.1))
                    .frame(height: 55)
//                RoundedRectangle(cornerRadius: 5, style: .continuous)
//                    .fill(.gray.opacity(0.15))
//                    .frame(height: 15)
//                    .padding(.trailing, 50)
//                RoundedRectangle(cornerRadius: 5, style: .continuous)
//                    .fill(.gray.opacity(0.15))
//                    .padding(.trailing, 150)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

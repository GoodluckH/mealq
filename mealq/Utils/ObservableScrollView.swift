//
//  ObservableScrollView.swift
//  mealq
//
//  Created by Xipu Li on 1/6/22.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value += nextValue()}
}

struct ObservableScrollView<Content> : View where Content : View {
    let content: () -> Content
    let onOffsetChange: (CGFloat) -> Void

    init(@ViewBuilder content: @escaping () -> Content, onOffsetChange: @escaping (CGFloat) -> Void) {
        self.content = content
        self.onOffsetChange = onOffsetChange
    }
    var body: some View {
      ScrollView {
          
        content()
          // 👈🏻 places the real content as if our `offsetReader` was not there.
          offsetReader
      }
      .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: onOffsetChange)
    }

    var offsetReader: some View {
      GeometryReader { proxy in
        Color.clear
          .preference(
            key: ScrollOffsetPreferenceKey.self,
            value: proxy.frame(in: .named("frameLayer")).maxY
          )
      }
      .frame(height: 0) // 👈🏻 make sure that the reader doesn't affect the content height
    }
}

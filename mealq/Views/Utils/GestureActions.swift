//
//  GestureActions.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import Foundation
import SwiftUI

// Resigns the keyboard when scroll gesture is detected.
extension UIApplication {
    func endEditing(_ force: Bool) {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
       keyWindow?.endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

// Allows customized `NavigationLink` views to have the swipe back gesture.
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


struct PopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let content: () -> PopoverContent

    func body(content: Content) -> some View {
        content
            .background(
                Popover(
                    isPresented: self.$isPresented,
                    onDismiss: self.onDismiss,
                    content: self.content
                )
            )
    }
}

extension View {
    func popover<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        ModifiedContent(
            content: self,
            modifier: PopoverViewModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

struct Popover<Content: View> : UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> Content

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, content: self.content())
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.host.rootView = self.content()
        if self.isPresented, uiViewController.presentedViewController == nil {
            let host = context.coordinator.host
            host.preferredContentSize = host.sizeThatFits(in: CGSize(width: Int.max, height: Int.max))
            host.modalPresentationStyle = UIModalPresentationStyle.popover
            host.popoverPresentationController?.delegate = context.coordinator
            host.popoverPresentationController?.sourceView = uiViewController.view
            host.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            uiViewController.present(host, animated: true, completion: nil)
        }
    }

    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
            let host: UIHostingController<Content>
            private let parent: Popover

            init(parent: Popover, content: Content) {
                self.parent = parent
                self.host = UIHostingController(rootView: content)
            }

            func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
                self.parent.isPresented = false
                if let onDismiss = self.parent.onDismiss {
                    onDismiss()
                }
            }

            func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
                return .none
            }
        }
    }
      

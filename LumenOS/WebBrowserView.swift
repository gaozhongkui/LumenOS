import SwiftUI
import WebKit

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct WebBrowserView: View {
    let title: String
    let url: URL

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            WebViewRepresentable(url: url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
}

private struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

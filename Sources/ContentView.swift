import SwiftUI
import WebKit

// MARK: - Weak Script Message Proxy (Prevents WKUserContentController retain cycle)
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

struct ContentView: View {
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var hasLoadedOnce = false
    @State private var reloadToken = UUID()
    @State private var estimatedProgress: Double = 0.0

    private let targetURL = URL(string: "https://reels.buongloi.loc.cc")!
    private let bgColor = Color(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 15.0 / 255.0) // #0a0a0f

    var body: some View {
        ZStack(alignment: .top) {
            // Nền tối #0a0a0f tràn viền chống chớp trắng
            bgColor
                .ignoresSafeArea(.all)

            WebViewContainer(
                url: targetURL,
                isLoading: $isLoading,
                loadFailed: $loadFailed,
                hasLoadedOnce: $hasLoadedOnce,
                progress: $estimatedProgress,
                reloadToken: reloadToken
            )
            .ignoresSafeArea(.all)

            // Thanh tiến trình gradient tím-hồng phía trên theo KVO estimatedProgress
            if isLoading && estimatedProgress < 1.0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0),
                                    Color(red: 168.0 / 255.0, green: 85.0 / 255.0, blue: 247.0 / 255.0),
                                    Color(red: 236.0 / 255.0, green: 72.0 / 255.0, blue: 153.0 / 255.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(estimatedProgress), height: 3)
                        .animation(.linear(duration: 0.2), value: estimatedProgress)
                }
                .frame(height: 3)
            }

            // Màn hình Splash tải lần đầu
            if isLoading && estimatedProgress < 0.3 && !hasLoadedOnce {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0),
                                        Color(red: 236.0 / 255.0, green: 72.0 / 255.0, blue: 153.0 / 255.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .shadow(color: Color(red: 168.0 / 255.0, green: 85.0 / 255.0, blue: 247.0 / 255.0).opacity(0.4), radius: 16, x: 0, y: 6)

                        Image(systemName: "waveform")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("Reels Audio")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 168.0 / 255.0, green: 85.0 / 255.0, blue: 247.0 / 255.0)))
                        .scaleEffect(1.1)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgColor)
                .ignoresSafeArea(.all)
                .transition(.opacity)
            }

            // Màn hình mất mạng toàn trang CHỈ khi chưa tải được trang lần nào
            if loadFailed && !hasLoadedOnce {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 236.0 / 255.0, green: 72.0 / 255.0, blue: 153.0 / 255.0))

                    Text("Không thể kết nối máy chủ")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Vui lòng kiểm tra kết nối mạng Internet của bạn rồi thử lại.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.68))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        loadFailed = false
                        isLoading = true
                        reloadToken = UUID()
                    }) {
                        Label("Thử lại ngay", systemImage: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0),
                                        Color(red: 236.0 / 255.0, green: 72.0 / 255.0, blue: 153.0 / 255.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: Color.purple.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgColor)
                .ignoresSafeArea(.all)
                .transition(.opacity)
            } else if loadFailed && hasLoadedOnce {
                // Banner nhỏ không che khuất ứng dụng khi rớt mạng lúc đang dùng
                HStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundColor(Color(red: 236.0 / 255.0, green: 72.0 / 255.0, blue: 153.0 / 255.0))
                    Text("Mất kết nối mạng")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Button("Thử lại") {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        loadFailed = false
                        reloadToken = UUID()
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0),
                                Color(red: 168.0 / 255.0, green: 85.0 / 255.0, blue: 247.0 / 255.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.top, 54)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - UIViewRepresentable WKWebView
struct WebViewContainer: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool
    @Binding var hasLoadedOnce: Bool
    @Binding var progress: Double
    let reloadToken: UUID

    private static let appHost = "reels.buongloi.loc.cc"

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Weak proxy avoids memory retain cycle between WKUserContentController and Coordinator
        let userContentController = WKUserContentController()
        let proxy = WeakScriptMessageHandler(context.coordinator)
        userContentController.add(proxy, name: "haptic")
        userContentController.add(proxy, name: "shareFile")
        config.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        // Tràn viền hoàn toàn không để khoảng trắng top / bottom
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        // KVO Observer cho tiến trình tải trang
        context.coordinator.observation = webView.observe(\.estimatedProgress, options: [.new]) { _, change in
            DispatchQueue.main.async {
                self.progress = change.newValue ?? 0.0
            }
        }

        context.coordinator.webView = webView
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            if uiView.url != nil {
                uiView.reload()
            } else {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
                uiView.load(request)
            }
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "haptic")
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "shareFile")
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebViewContainer
        weak var webView: WKWebView?
        var observation: NSKeyValueObservation?
        var lastReloadToken: UUID?

        init(_ parent: WebViewContainer) {
            self.parent = parent
            self.lastReloadToken = parent.reloadToken
        }

        deinit {
            observation?.invalidate()
        }

        // MARK: - WKNavigationDelegate
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let targetUrl = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if let scheme = targetUrl.scheme?.lowercased(),
               scheme != "http" && scheme != "https" && scheme != "blob" && scheme != "data" && scheme != "about" {
                UIApplication.shared.open(targetUrl)
                decisionHandler(.cancel)
                return
            }

            if navigationAction.navigationType == .linkActivated,
               let host = targetUrl.host?.lowercased(),
               host != WebViewContainer.appHost {
                UIApplication.shared.open(targetUrl)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.loadFailed = false
            }
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
                self.parent.hasLoadedOnce = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
                self.parent.hasLoadedOnce = true
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = true
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        // MARK: - WKUIDelegate (External Popups + Native JS Alert/Confirm/Prompt)
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let url = navigationAction.request.url {
                if let host = url.host?.lowercased(), host == WebViewContainer.appHost {
                    webView.load(navigationAction.request)
                } else {
                    UIApplication.shared.open(url)
                }
            }
            return nil
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            guard let vc = Self.topViewController() else {
                completionHandler()
                return
            }
            let alert = UIAlertController(title: "Reels Audio", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Đóng", style: .default) { _ in completionHandler() })
            vc.present(alert, animated: true)
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            guard let vc = Self.topViewController() else {
                completionHandler(false)
                return
            }
            let alert = UIAlertController(title: "Reels Audio", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "Đồng ý", style: .default) { _ in completionHandler(true) })
            vc.present(alert, animated: true)
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            guard let vc = Self.topViewController() else {
                completionHandler(nil)
                return
            }
            let alert = UIAlertController(title: "Reels Audio", message: prompt, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = defaultText
            }
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(nil) })
            alert.addAction(UIAlertAction(title: "Đồng ý", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })
            vc.present(alert, animated: true)
        }

        // MARK: - Script Message Handlers
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "haptic":
                if let styleStr = message.body as? String {
                    triggerHaptic(styleStr: styleStr)
                } else if let dict = message.body as? [String: Any], let styleStr = dict["style"] as? String {
                    triggerHaptic(styleStr: styleStr)
                } else {
                    triggerHaptic(styleStr: "medium")
                }

            case "shareFile":
                handleShareFile(message.body)

            default:
                break
            }
        }

        private func triggerHaptic(styleStr: String) {
            DispatchQueue.main.async {
                switch styleStr.lowercased() {
                case "light":
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                case "medium":
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                case "heavy":
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                case "success":
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)
                case "error":
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.error)
                case "selection":
                    let generator = UISelectionFeedbackGenerator()
                    generator.prepare()
                    generator.selectionChanged()
                default:
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
        }

        private func handleShareFile(_ body: Any) {
            guard let dict = body as? [String: Any],
                  let rawUrlStr = dict["url"] as? String,
                  let resolvedUrl = URL(string: rawUrlStr, relativeTo: parent.url)?.absoluteURL,
                  let scheme = resolvedUrl.scheme?.lowercased(),
                  scheme == "https" || scheme == "http" else {
                return
            }

            let rawName = (dict["filename"] as? String) ?? resolvedUrl.lastPathComponent
            let sanitizedName = (rawName as NSString).lastPathComponent
            let safeName = sanitizedName.isEmpty ? "reels-audio.mp3" : sanitizedName

            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                var request = URLRequest(url: resolvedUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)

                if let targetHost = resolvedUrl.host?.lowercased() {
                    let matchingCookies = cookies.filter { cookie in
                        let domain = cookie.domain.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
                        return targetHost == domain || targetHost.hasSuffix("." + domain)
                    }
                    let cookieHeaders = HTTPCookie.requestHeaderFields(with: matchingCookies)
                    for (headerField, headerValue) in cookieHeaders {
                        request.setValue(headerValue, forHTTPHeaderField: headerField)
                    }
                }

                let task = URLSession.shared.downloadTask(with: request) { tempLocalUrl, response, error in
                    guard error == nil, let tempLocalUrl = tempLocalUrl else { return }
                    if let httpResponse = response as? HTTPURLResponse,
                       !(200...299).contains(httpResponse.statusCode) {
                        return
                    }

                    let destinationUrl = FileManager.default.temporaryDirectory.appendingPathComponent(safeName)
                    do {
                        if FileManager.default.fileExists(atPath: destinationUrl.path) {
                            try FileManager.default.removeItem(at: destinationUrl)
                        }
                        try FileManager.default.moveItem(at: tempLocalUrl, to: destinationUrl)
                    } catch {
                        return
                    }

                    DispatchQueue.main.async {
                        guard let topVC = Self.topViewController() else { return }
                        let activityVC = UIActivityViewController(activityItems: [destinationUrl], applicationActivities: nil)
                        if let popover = activityVC.popoverPresentationController {
                            popover.sourceView = topVC.view
                            popover.sourceRect = CGRect(
                                x: topVC.view.bounds.midX,
                                y: topVC.view.bounds.midY,
                                width: 0,
                                height: 0
                            )
                            popover.permittedArrowDirections = []
                        }
                        topVC.present(activityVC, animated: true)
                    }
                }
                task.resume()
            }
        }

        private static func topViewController() -> UIViewController? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
            guard let rootVC = (windowScene?.windows.first(where: { $0.isKeyWindow }) ?? windowScene?.windows.first)?.rootViewController else {
                return nil
            }
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            return topVC
        }
    }
}

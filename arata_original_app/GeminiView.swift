import SwiftUI

// チャットメッセージのデータモデル
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct GeminiView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "こんにちは！何かお手伝いできることはありますか？", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    
    // Google AI Studio で取得したAPIキーを入力してください
    private let apiKey: String = "YOUR_GEMINI_API_KEY"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // メッセージリストエリア
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                            
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(10)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // 入力エリア
                HStack(spacing: 10) {
                    TextField("Geminiにメッセージを送信...", text: $inputText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .disabled(isLoading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading ? .gray : .blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("Gemini 3.7 Flash")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // メッセージ送信関数
    private func sendMessage() {
        let userText = inputText.trimmingCharacters(in: .whitespaces)
        guard !userText.isEmpty else { return }
        
        let userMessage = ChatMessage(text: userText, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        // APIキーが未設定の場合はダミー応答
        if apiKey == "YOUR_GEMINI_API_KEY" || apiKey.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                let reply = ChatMessage(text: "「\(userText)」ですね！APIキーを設定すると、実際のGeminiからの回答が表示されます。", isUser: false)
                messages.append(reply)
                isLoading = false
            }
        } else {
            fetchGeminiInteractionsAPI(prompt: userText)
        }
    }
    
    // Gemini Interactions API（REST）の呼び出し
    private func fetchGeminiInteractionsAPI(prompt: String) {
        // Interactions APIのエンドポイント
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/interactions?key=\(apiKey)") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Pythonコードに対応するパラメータ（model: "gemini-3.7-flash"）
        let jsonBody: [String: Any] = [
            "model": "gemini-3.7-flash",
            "input": prompt
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody) else {
            isLoading = false
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data, error == nil else {
                    let errorMessage = ChatMessage(text: "エラーが発生しました。通信環境を確認してください。", isUser: false)
                    messages.append(errorMessage)
                    return
                }
                
                // Interactions API のレスポンスから output_text を取得
                if let responseObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let outputText = responseObj["output_text"] as? String {
                    let reply = ChatMessage(text: outputText, isUser: false)
                    messages.append(reply)
                } else if let responseString = String(data: data, encoding: .utf8) {
                    // デバッグ用フォールバック
                    let reply = ChatMessage(text: "応答の解析に失敗しました: \(responseString)", isUser: false)
                    messages.append(reply)
                }
            }
        }.resume()
    }
}

// チャット吹き出しコンポーネント
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

#Preview {
    GeminiView()
}

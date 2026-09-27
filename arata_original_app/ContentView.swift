import SwiftUI

struct ContentView: View {
    // 現在選択されているタブを管理する状態変数
    @State private var selectedTab = 0
    @StateObject private var taskStore = TaskStore()
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 1つ目の画面
            GeminiView()
                .tabItem {
                    Image(systemName: "message")
                    Text("ジェミニ")
                }
                .tag(0)
            
            // 2つ目の画面
            CalenderView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
                .tag(1)
            
            // 3つ目の画面
            TodayView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("今日の予定")
                }
                .tag(2)
            
            // 4つ目の画面
            TaskView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("タスク")
                }
                .tag(3)
        }
        .environmentObject(taskStore)
    }
}







#Preview {
    ContentView()
}

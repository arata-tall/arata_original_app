

import SwiftUI
import Combine

// 1. タスクのデータ構造
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: String
}

/// カレンダーとタスク一覧で共通して使用するタスクの保存先です。
final class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = [
        TaskItem(title: "プログラミングの学習", dueDate: "2026/06/28"),
        TaskItem(title: "買い物（牛乳、卵）", dueDate: "2026/06/29"),
        TaskItem(title: "部屋の掃除", dueDate: "2026/06/30"),
        TaskItem(title: "読書（30ページ読む）", dueDate: "2026/07/01")
    ]

    func addTask(title: String, dueDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd"
        tasks.append(TaskItem(title: title, dueDate: formatter.string(from: dueDate)))
    }
}

struct TaskView: View {
    @EnvironmentObject private var taskStore: TaskStore
    
    @State private var isShowingAddSheet = false
    @State private var newTaskTitle = ""
    @State private var newTaskDate = Date()
    
    // ★ 検索キーワードを保持する状態変数
    @State private var searchText = ""
    // ★ 検索バーを表示中かどうかを管理（フォーカス制御用）
    @State private var isSearchFocused: Bool = false
    // ★ 検索キーワードでフィルタリングされたタスクリスト
    var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return taskStore.tasks
        } else {
            return taskStore.tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // ★ filteredTasks を表示するように変更
                List {
                    ForEach(filteredTasks, id: \.id) { task in
                        HStack(alignment: .top, spacing: 16) {
                            // タスク完了ボタン（タップで自動消去）
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                                .onTapGesture {
                                    withAnimation {
                                        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                                            taskStore.tasks.remove(at: index)
                                        }
                                    }
                                }
                            
                            // タスク名と期限
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.body)
                                
                                Text("期限: \(task.dueDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteTask)
                }
                .scrollContentBackground(.hidden)
                
                // 検索結果が空の時の見た目（お好みで）
                if filteredTasks.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .navigationTitle("タスク一覧")
            // ★ iOS標準の検索バーを組み込み（ツールバーと連動）
            .searchable(text: $searchText, isPresented: $isSearchFocused, prompt: "タスクを検索")
            // ★ 画面右上に「検索」と「追加」のボタンを並べる
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // 検索ボタン（虫眼鏡）
                    Button(action: {
                        isSearchFocused = true // タップで検索バーにフォーカスを当てる
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .bold()
                    }
                    
                    // 追加ボタン（プラス）
                    Button(action: {
                        isShowingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .bold()
                    }
                }
            }
            // 追加用画面のポップアップ
            .sheet(isPresented: $isShowingAddSheet) {
                NavigationStack {
                    Form {
                        TextField("タスク名を入力", text: $newTaskTitle)
                        DatePicker("期限", selection: $newTaskDate, displayedComponents: .date)
                    }
                    .navigationTitle("新しいタスク")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("キャンセル") { isShowingAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("追加") {
                                addTask()
                                isShowingAddSheet = false
                            }
                            .disabled(newTaskTitle.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    // タスク追加
    private func addTask() {
        taskStore.addTask(title: newTaskTitle, dueDate: newTaskDate)
        
        newTaskTitle = ""
        newTaskDate = Date()
    }
    
    // スワイプ削除用（filteredTasksのインデックスから元の配列の要素を特定して削除）
    private func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let itemToRemove = filteredTasks[index]
            if let originalIndex = taskStore.tasks.firstIndex(where: { $0.id == itemToRemove.id }) {
                taskStore.tasks.remove(at: originalIndex)
            }
        }
    }
}

#Preview {
    TaskView()
        .environmentObject(TaskStore())
}

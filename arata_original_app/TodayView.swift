import SwiftUI

// 1. カラーの定義（Enum）
enum CalendarColor: String, CaseIterable, Identifiable {
    case wine = "ワイン", rose = "ローズ", flamingo = "フラミンゴ", tomato = "トマト", mikan = "ミカン"
    case kabocha = "カボチャ", mango = "マンゴー", banana = "バナナ", lemon = "レモン", avocado = "アボカド"
    case pistachio = "ピスタチオ", basil = "バジル", sage = "セージ", peacock = "ピーコック", cobalt = "コバルト"
    
    var id: String { self.rawValue }
    var color: Color {
        switch self {
        case .wine: return Color(red: 0.72, green: 0.07, blue: 0.32); case .rose: return Color(red: 0.90, green: 0.08, blue: 0.44)
        case .flamingo: return Color(red: 0.94, green: 0.53, blue: 0.47); case .tomato: return Color(red: 0.89, green: 0.12, blue: 0.06)
        case .mikan: return Color(red: 0.96, green: 0.41, blue: 0.14); case .kabocha: return Color(red: 0.96, green: 0.53, blue: 0.05)
        case .mango: return Color(red: 0.96, green: 0.65, blue: 0.08); case .banana: return Color(red: 0.97, green: 0.79, blue: 0.22)
        case .lemon: return Color(red: 0.92, green: 0.81, blue: 0.29); case .avocado: return Color(red: 0.73, green: 0.82, blue: 0.22)
        case .pistachio: return Color(red: 0.51, green: 0.77, blue: 0.32); case .basil: return Color(red: 0.03, green: 0.56, blue: 0.31)
        case .sage: return Color(red: 0.24, green: 0.72, blue: 0.51); case .peacock: return Color(red: 0.04, green: 0.65, blue: 0.88)
        case .cobalt: return Color(red: 0.29, green: 0.53, blue: 0.95)
        }
    }
}

// 2. 予定のデータ構造
struct DailyEvent: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var location: String
    var startDate: Date
    var endDate: Date
    var calColor: CalendarColor
    let imageName: String?
    var isAllDay: Bool
}

// 3. メインのスケジュール画面
struct TodayView: View {
    @State private var events: [DailyEvent] = [
        DailyEvent(title: "プロジェクト進捗報告会", location: "会議室A", startDate: createDate(hour: 10, minute: 0), endDate: createDate(hour: 10, minute: 30), calColor: .peacock, imageName: nil, isAllDay: false),
        DailyEvent(title: "プレゼンの仕上げ", location: "デスク", startDate: createDate(hour: 10, minute: 30), endDate: createDate(hour: 11, minute: 30), calColor: .tomato, imageName: "checkmark.circle", isAllDay: false)
    ]
    
    @State private var showAddEventSheet = false
    @State private var newEvent = DailyEvent(title: "", location: "", startDate: Date(), endDate: Date().addingTimeInterval(3600), calColor: .peacock, imageName: nil, isAllDay: false)
    
    // 今日の「日」を取得（例: "29"）
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
    
    // 今日の「曜日」を取得（例: "土"）
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(alignment: .top, spacing: 16) {
                    // 現在の日付と連動するヘッダー表示
                    VStack(spacing: 4) {
                        Text(dayString)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                        
                        Text(weekdayString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    
                    VStack(spacing: 12) {
                        ForEach($events) { $event in
                            NavigationLink(destination: EditEventView(event: $event, allEvents: $events)) {
                                EventBlockView(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("今日のスケジュール")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let randomColor = CalendarColor.allCases.randomElement() ?? .peacock
                        newEvent = DailyEvent(title: "", location: "", startDate: Date(), endDate: Date().addingTimeInterval(3600), calColor: randomColor, imageName: nil, isAllDay: false)
                        showAddEventSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddEventSheet) {
                NavigationStack {
                    AddEventView(event: $newEvent, allEvents: $events, isPresented: $showAddEventSheet)
                }
            }
        }
    }
}

// 4. 編集画面
struct EditEventView: View {
    @Binding var event: DailyEvent
    @Binding var allEvents: [DailyEvent]
    
    @State private var showColorPicker = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("予定の編集")) {
                TextField("タイトル", text: $event.title)
                TextField("場所", text: $event.location)
            }
            
            Section(header: Text("時間の設定")) {
                HStack {
                    Image(systemName: "clock").foregroundColor(.secondary)
                    Toggle("終日", isOn: $event.isAllDay)
                }
                
                if !event.isAllDay {
                    DatePicker("開始", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    
                    DatePicker("終了", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
            }
            
            Section {
                Button(action: { showColorPicker = true }) {
                    HStack {
                        Image(systemName: "paintpalette").foregroundColor(.secondary)
                        Text("色").foregroundColor(.primary)
                        Spacer()
                        Circle().fill(event.calColor.color).frame(width: 14, height: 14)
                        Text(event.calColor.rawValue).foregroundColor(.secondary)
                        Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                Button(action: { showDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash").foregroundColor(.red)
                        Text("イベントを削除").foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("予定の変更")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .alert("", isPresented: $showDeleteConfirmation) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                if let index = allEvents.firstIndex(where: { $0.id == event.id }) {
                    allEvents.remove(at: index)
                }
                dismiss()
            }
        } message: { Text("この予定を削除してもよろしいですか？") }
        .sheet(isPresented: $showColorPicker) {
            NavigationStack {
                List(CalendarColor.allCases) { calColor in
                    Button(action: {
                        event.calColor = calColor
                        showColorPicker = false
                    }) {
                        HStack {
                            Image(systemName: "circle.fill").foregroundColor(calColor.color)
                            Text(calColor.rawValue).foregroundColor(.primary)
                            Spacer()
                            if event.calColor == calColor {
                                Image(systemName: "checkmark").foregroundColor(.blue).fontWeight(.bold)
                            }
                        }
                    }
                }
                .navigationTitle("色を選択")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// 5. 新規予定追加画面
struct AddEventView: View {
    @Binding var event: DailyEvent
    @Binding var allEvents: [DailyEvent]
    @Binding var isPresented: Bool
    
    @State private var showColorPicker = false
    
    var body: some View {
        Form {
            Section(header: Text("予定の入力")) {
                TextField("タイトル", text: $event.title)
                TextField("場所", text: $event.location)
            }
            
            Section(header: Text("時間の設定")) {
                HStack {
                    Image(systemName: "clock").foregroundColor(.secondary)
                    Toggle("終日", isOn: $event.isAllDay)
                }
                
                if !event.isAllDay {
                    DatePicker("開始", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    
                    DatePicker("終了", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
            }
            
            Section {
                Button(action: { showColorPicker = true }) {
                    HStack {
                        Image(systemName: "paintpalette").foregroundColor(.secondary)
                        Text("色").foregroundColor(.primary)
                        Spacer()
                        Circle().fill(event.calColor.color).frame(width: 14, height: 14)
                        Text(event.calColor.rawValue).foregroundColor(.secondary)
                        Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("予定の追加")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") { isPresented = false }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("追加") {
                    allEvents.append(event)
                    isPresented = false
                }
                .fontWeight(.bold)
                .disabled(event.title.isEmpty)
            }
        }
        .sheet(isPresented: $showColorPicker) {
            NavigationStack {
                List(CalendarColor.allCases) { calColor in
                    Button(action: {
                        event.calColor = calColor
                        showColorPicker = false
                    }) {
                        HStack {
                            Image(systemName: "circle.fill").foregroundColor(calColor.color)
                            Text(calColor.rawValue).foregroundColor(.primary)
                            Spacer()
                            if event.calColor == calColor {
                                Image(systemName: "checkmark").foregroundColor(.blue).fontWeight(.bold)
                            }
                        }
                    }
                }
                .navigationTitle("色を選択")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// 6. 表示用（カード表示）
struct EventBlockView: View {
    let event: DailyEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 左側のアクセントライン
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calColor.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HStack(spacing: 6) {
                        if event.imageName == "checkmark.circle" {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.secondary)
                        }
                        Text(event.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if let img = event.imageName, img != "checkmark.circle" {
                        Image(systemName: img)
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(event.isAllDay ? "終日" : formatTimeRange(start: event.startDate, end: event.endDate))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                if !event.location.isEmpty {
                    Text(event.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "h:mm"
        
        let ampm = DateFormatter()
        ampm.locale = Locale(identifier: "en_US")
        ampm.dateFormat = " a"
        
        return "\(formatter.string(from: start))〜\(formatter.string(from: end))\(ampm.string(from: end))"
    }
}

func createDate(hour: Int, minute: Int) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components) ?? Date()
}

#Preview {
    TodayView()
}

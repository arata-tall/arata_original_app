import SwiftUI

// MARK: - 1. データモデルの定義（重複を防ぐため、プロジェクト内でここだけに記述します）
enum ProjectCalendarColor: String, CaseIterable, Identifiable {
    case wine = "ワイン", rose = "ローズ", flamingo = "フラミンゴ", tomato = "トマト", mikan = "ミカン"
    case kabocha = "カボチャ", mango = "マンゴー", banana = "バナナ", lemon = "レモン", avocado = "アボカド"
    case pistachio = "ピスタチオ", basil = "バジル", sage = "セージ", peacock = "ピーコック", cobalt = "コバルト"
    
    var id: String { self.rawValue }
    var color: Color {
        switch self {
        case .wine: return Color(red: 0.72, green: 0.07, blue: 0.32)
        case .rose: return Color(red: 0.90, green: 0.08, blue: 0.44)
        case .flamingo: return Color(red: 0.94, green: 0.53, blue: 0.47)
        case .tomato: return Color(red: 0.89, green: 0.12, blue: 0.06)
        case .mikan: return Color(red: 0.96, green: 0.41, blue: 0.14)
        case .kabocha: return Color(red: 0.96, green: 0.53, blue: 0.05)
        case .mango: return Color(red: 0.96, green: 0.65, blue: 0.08)
        case .banana: return Color(red: 0.97, green: 0.79, blue: 0.22)
        case .lemon: return Color(red: 0.92, green: 0.81, blue: 0.29)
        case .avocado: return Color(red: 0.73, green: 0.82, blue: 0.22)
        case .pistachio: return Color(red: 0.51, green: 0.77, blue: 0.32)
        case .basil: return Color(red: 0.03, green: 0.56, blue: 0.31)
        case .sage: return Color(red: 0.24, green: 0.72, blue: 0.51)
        case .peacock: return Color(red: 0.04, green: 0.65, blue: 0.88)
        case .cobalt: return Color(red: 0.29, green: 0.53, blue: 0.95)
        }
    }
}

struct ProjectAppointment: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var location: String
    var date: Date
    var startTime: String
    var endTime: String
    var calColor: ProjectCalendarColor
}

// MARK: - 2. メインのカレンダー画面
struct CalenderView: View {
    @State private var currentMonth: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }()
    
    @State private var selectedDate: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 13
        return calendar.date(from: components) ?? Date()
    }()
    
    @State private var isShowingAddEvent = false
    @State private var editingAppointment: ProjectAppointment? = nil
    
    @State private var appointments: [ProjectAppointment] = [
        ProjectAppointment(title: "プロジェクト進捗報告会", location: "会議室A", date: Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 13))!, startTime: "10:00", endTime: "10:30", calColor: .cobalt),
        ProjectAppointment(title: "プレゼンの仕上げ", location: "デスク", date: Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 13))!, startTime: "10:30", endTime: "11:30", calColor: .tomato)
    ]
    
    private let calendar = Calendar.current
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // カレンダーヘッダー
                HStack {
                    Text(formatYearMonth(currentMonth))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    HStack(spacing: 24) {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                        }
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // 曜日ラベル
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { weekday in
                        Text(weekday)
                            .font(.system(size: 12, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                
                // カレンダーグリッド
                let days = generateDaysInMonth(for: currentMonth)
                let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<days.count, id: \.self) { index in
                        if let dayDate = days[index] {
                            let dayNum = calendar.component(.day, from: dayDate)
                            let isSelected = calendar.isDate(dayDate, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(dayDate)
                            
                            Button(action: {
                                selectedDate = dayDate
                            }) {
                                Text("\(dayNum)")
                                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(isSelected ? Color.red.opacity(0.15) : Color.clear)
                                    )
                                    .foregroundColor(isSelected ? .red : (isToday ? .blue : .primary))
                            }
                        } else {
                            Text("")
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                Divider()
                    .padding(.top, 20)
                
                // スケジュール表示エリア
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("今日のスケジュール")
                            .font(.system(size: 22, weight: .bold))
                        Spacer()
                        Text(formatSelectedDate(selectedDate))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    let filteredAppointments = appointments.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
                    
                    if filteredAppointments.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Text("予定がありません")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            Button(action: { isShowingAddEvent = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("予定を追加")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredAppointments) { app in
                                    Button(action: { editingAppointment = app }) {
                                        HStack(spacing: 0) {
                                            Image(systemName: "checkmark.circle")
                                                .font(.system(size: 18))
                                                .foregroundColor(.white)
                                                .padding(.leading, 16)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(app.title)
                                                    .font(.system(size: 16, weight: .bold))
                                                Text("\(app.startTime) 〜 \(app.endTime)")
                                                    .font(.system(size: 13))
                                                Text(app.location)
                                                    .font(.system(size: 13))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.leading, 12)
                                            
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(app.calColor.color)
                                        .cornerRadius(16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddEvent = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddEvent) {
                let randomInitialColor = ProjectCalendarColor.allCases.randomElement() ?? .sage
                ProjectAddEventView(selectedDate: selectedDate, initialColor: randomInitialColor) { newApp in
                    appointments.append(newApp)
                }
            }
            .sheet(item: $editingAppointment) { app in
                ProjectEditEventView(appointment: app, allAppointments: $appointments)
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func formatYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return "選択された日: \(formatter.string(from: date))"
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let numberOfBlankSpaces = weekdayOfFirst - 1
        var days: [Date?] = Array(repeating: nil, count: numberOfBlankSpaces)
        for day in 1...range.count {
            if let dateComponent = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(dateComponent)
            }
        }
        return days
    }
}

// MARK: - 3. 予定追加画面
struct ProjectAddEventView: View {
    @Environment(\.dismiss) var dismiss
    var selectedDate: Date
    var initialColor: ProjectCalendarColor
    var onSave: (ProjectAppointment) -> Void
    
    @State private var title = ""
    @State private var location = ""
    
    @State private var isAllDay = false
    @State private var startDateTime = Date()
    @State private var endDateTime = Date()
    
    @State private var calColor: ProjectCalendarColor = .sage
    @State private var showColorPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("予定の追加")) {
                    TextField("タイトル（例: 店舗オープニング）", text: $title)
                    TextField("場所（例: 渋谷店）", text: $location)
                }
                
                Section(header: Text("時間の設定")) {
                    Toggle(isOn: $isAllDay.animation()) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("終日")
                        }
                    }
                    
                    DatePicker(
                        "開始",
                        selection: $startDateTime,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    
                    DatePicker(
                        "終了",
                        selection: $endDateTime,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
                
                Section {
                    Button(action: { showColorPicker = true }) {
                        HStack {
                            Image(systemName: "paintpalette").foregroundColor(.secondary)
                            Text("色").foregroundColor(.primary)
                            Spacer()
                            Circle().fill(calColor.color).frame(width: 14, height: 14)
                            Text(calColor.rawValue).foregroundColor(.secondary)
                            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("予定の追加")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                calColor = initialColor
                let calendar = Calendar.current
                let now = Date()
                if let start = calendar.date(bySettingHour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now), second: 0, of: selectedDate) {
                    startDateTime = start
                    endDateTime = calendar.date(byAdding: .hour, value: 1, to: start) ?? start
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let newApp = ProjectAppointment(
                            title: title,
                            location: location,
                            date: selectedDate,
                            startTime: isAllDay ? "終日" : formatTime(startDateTime),
                            endTime: isAllDay ? "終日" : formatTime(endDateTime),
                            calColor: calColor
                        )
                        onSave(newApp)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showColorPicker) {
                ProjectColorPickerView(selectedColor: $calColor)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 4. 予定の編集 ＆ 削除画面
struct ProjectEditEventView: View {
    @Environment(\.dismiss) var dismiss
    @State var appointment: ProjectAppointment
    @Binding var allAppointments: [ProjectAppointment]
    
    @State private var isAllDay = false
    @State private var startDateTime = Date()
    @State private var endDateTime = Date()
    
    @State private var showColorPicker = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("予定の編集")) {
                    TextField("タイトル", text: $appointment.title)
                    TextField("場所", text: $appointment.location)
                }
                
                Section(header: Text("時間の設定")) {
                    Toggle(isOn: $isAllDay.animation()) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("終日")
                        }
                    }
                    
                    DatePicker(
                        "開始",
                        selection: $startDateTime,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    
                    DatePicker(
                        "終了",
                        selection: $endDateTime,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
                
                Section {
                    Button(action: { showColorPicker = true }) {
                        HStack {
                            Image(systemName: "paintpalette").foregroundColor(.secondary)
                            Text("色").foregroundColor(.primary)
                            Spacer()
                            Circle().fill(appointment.calColor.color).frame(width: 14, height: 14)
                            Text(appointment.calColor.rawValue).foregroundColor(.secondary)
                            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: { showDeleteAlert = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                            Text("削除")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .navigationTitle("予定の変更")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isAllDay = (appointment.startTime == "終日")
                startDateTime = parseTime(isAllDay ? "00:00" : appointment.startTime, date: appointment.date)
                endDateTime = parseTime(isAllDay ? "23:59" : appointment.endTime, date: appointment.date)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        appointment.startTime = isAllDay ? "終日" : formatTime(startDateTime)
                        appointment.endTime = isAllDay ? "終日" : formatTime(endDateTime)
                        
                        if let index = allAppointments.firstIndex(where: { $0.id == appointment.id }) {
                            allAppointments[index] = appointment
                        }
                        dismiss()
                    }
                    .disabled(appointment.title.isEmpty)
                }
            }
            .alert("削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    allAppointments.removeAll(where: { $0.id == appointment.id })
                    dismiss()
                }
            } message: {
                Text("この予定を削除してもよろしいですか？")
            }
            .sheet(isPresented: $showColorPicker) {
                ProjectColorPickerView(selectedColor: $appointment.calColor)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func parseTime(_ timeString: String, date: Date) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let timeDate = formatter.date(from: timeString) else { return date }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = calendar.component(.hour, from: timeDate)
        components.minute = calendar.component(.minute, from: timeDate)
        return calendar.date(from: components) ?? date
    }
}

// MARK: - 5. カラー選択リスト画面
struct ProjectColorPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedColor: ProjectCalendarColor
    
    var body: some View {
        NavigationStack {
            List(ProjectCalendarColor.allCases) { calColor in
                Button(action: {
                    selectedColor = calColor
                    dismiss()
                }) {
                    HStack {
                        Circle().fill(calColor.color).frame(width: 16, height: 16)
                        Text(calColor.rawValue).foregroundColor(.primary)
                        Spacer()
                        if selectedColor == calColor {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("色を選択")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    CalenderView()
}

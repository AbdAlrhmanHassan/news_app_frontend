import WidgetKit
import SwiftUI

// 1. TIMELINE PROVIDER
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Your Daily Audio Mix", summary: "Tap to listen to today's top stories")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Your Daily Audio Mix", summary: "Tap to listen to today's top stories")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.abdalrhman.newsapp")
        
        let titleData = userDefaults?.string(forKey: "news_title") ?? "Discover News"
        let summaryData = userDefaults?.string(forKey: "news_summary") ?? "Tap to open your daily mix"
        
        let entry = SimpleEntry(date: Date(), title: titleData, summary: summaryData)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let summary: String
}

// 2. THE ELEGANT UI MANAGER
struct Daily_News_ListEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    let primaryColor = Color(red: 149/255, green: 39/255, blue: 29/255)

    var body: some View {
        // The ENTIRE widget is the deep link.
        Link(destination: URL(string: "newsapp://play")!) {
            Group {
                switch family {
                case .systemSmall:
                    SmallWidgetView(entry: entry, primaryColor: primaryColor)
                case .systemMedium:
                    MediumWidgetView(entry: entry, primaryColor: primaryColor)
                // 🚀 REMOVED: Large Widget Case
                default:
                    SmallWidgetView(entry: entry, primaryColor: primaryColor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

// ---------------------------------------------------------
// 🎨 SMALL WIDGET: Minimalist & Clean
// ---------------------------------------------------------
struct SmallWidgetView: View {
    var entry: Provider.Entry
    var primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("DAILY NEWS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(primaryColor)
                Spacer()
                Image(systemName: "waveform")
                    .foregroundColor(primaryColor.opacity(0.6))
            }
            
            Spacer()
            
            Text(entry.title)
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding(.bottom, 6)
            
            // 🚀 THE PROFESSIONAL AFFORDANCE (Apple-style Pill)
            HStack(spacing: 4) {
                Text("LISTEN NOW")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                Image(systemName: "play.fill")
                    .font(.system(size: 8))
            }
            .foregroundColor(primaryColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(primaryColor.opacity(0.12))
            .clipShape(Capsule())
        }
        .padding(4)
    }
}

// ---------------------------------------------------------
// 🎨 MEDIUM WIDGET: Podcast Card Style
// ---------------------------------------------------------
struct MediumWidgetView: View {
    var entry: Provider.Entry
    var primaryColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.8), primaryColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Image(systemName: "waveform")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white)
            }
            .frame(width: 75)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AUDIO MIX")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                    .tracking(1.2)
                
                Text(entry.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 2)
                    .padding(.bottom, 4)
                
                // 🚀 THE PROFESSIONAL AFFORDANCE
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 12))
                    Text("Tap to play")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundColor(primaryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(primaryColor.opacity(0.12))
                .clipShape(Capsule())
            }
            Spacer(minLength: 0)
        }
        .padding(4)
    }
}

// 3. MAIN CONFIGURATION
@main
struct Daily_News_List: Widget {
    let kind: String = "DailyNewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Daily_News_ListEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Audio News")
        .description("Your personalized morning mix.")
        // 🚀 THE FIX: Removed .systemLarge from the supported families!
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
//
//  ComplicationWidget.swift
//  ComplicationWidget
//
//  Created by Craig Hockenberry on 9/28/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
	func recommendations() -> [IntentRecommendation<SelectStyleIntent>] {
		[true, false].map { value in
			let intent = SelectStyleIntent()
			intent.style = (value ? .withText : .withoutText)
			let description = (value ? Text("With Text") : Text("Without Text"))
			return IntentRecommendation(intent: intent, description: description)
		}
	}
	
    func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date.distantPast, showingText: true)
    }

	func getSnapshot(for configuration: SelectStyleIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let showingText: Bool = (configuration.style == .withText)
		
		let entry = SimpleEntry(date: Date.distantPast, showingText: showingText)
        completion(entry)
    }

    func getTimeline(for configuration: SelectStyleIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		let showingText: Bool = (configuration.style == .withText)

		let entry = SimpleEntry(date: Date.distantPast, showingText: showingText)
		let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
	let showingText: Bool
}

struct Complication: View {
	var entry: Provider.Entry

	@Environment(\.widgetFamily) var widgetFamily
	@Environment(\.widgetRenderingMode) var widgetRenderingMode

	let circleInset = CGFloat(1) // to fix some edge anti-aliasing caused by the complication's clip geometry

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				AccessoryWidgetBackground()
				Image(systemName: "play.fill")
					.resizable()
					.frame(width: (geometry.size.width / 2) - 4, height: (geometry.size.height / 2) - 4)
					.padding([.leading], 4) // to visually center the arrow
					.foregroundColor(Color("AccentColor"))
					.unredacted()
				if widgetFamily == .accessoryCircular {
					Circle()
						.strokeBorder(.white, lineWidth: 2)
						.frame(width: geometry.size.width - circleInset, height: geometry.size.height - circleInset)
						.widgetAccentable()
				}
				else {
					Circle()
						.strokeBorder(Color("AccentColor"), lineWidth: 2.5)
						.frame(width: geometry.size.width - circleInset, height: geometry.size.height - circleInset)
				}
			}
			.widgetLabel {
				if entry.showingText {
					Text("Now Playing")
						.unredacted()
				}
			}
		}
	}
}

class IntentHandler: INExtension, SelectStyleIntentHandling {
	func resolveSelectType(for intent: SelectStyleIntent, with completion: @escaping (SelectStyleIntentResponse) -> Void) {
		intent.style = .withText
		completion(SelectStyleIntentResponse(code: .success, userActivity: nil))
	}
}

@main
struct ComplicationWidget: Widget {
    let kind: String = "ComplicationWidget"

	//com.iconfactory.NowPlayingPlus.watchkitapp.IntentsExtension
	
    var body: some WidgetConfiguration {
		IntentConfiguration(
			kind: "com.iconfactory.NowPlayingPlus.watchkitapp.IntentsExtension",
			intent: SelectStyleIntent.self,
			provider: Provider()
		) { entry in
			Complication(entry: entry)
		}
        .configurationDisplayName("NowPlaying+")
        .description("This complication gives you quick access to audio controls.")
		.supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct ComplicationWidget_Previews: PreviewProvider {
    static var previews: some View {
		let withTextEntry = SimpleEntry(date: Date(), showingText: true)
		Complication(entry: withTextEntry)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
		Complication(entry: withTextEntry)
			.previewContext(WidgetPreviewContext(family: .accessoryCorner))

		let withoutTextEntry = SimpleEntry(date: Date(), showingText: false)
		Complication(entry: withoutTextEntry)
			.previewContext(WidgetPreviewContext(family: .accessoryCircular))
		Complication(entry: withoutTextEntry)
			.previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}

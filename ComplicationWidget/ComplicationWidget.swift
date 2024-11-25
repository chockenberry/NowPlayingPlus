//
//  ComplicationWidget.swift
//  ComplicationWidget
//
//  Created by Craig Hockenberry on 9/28/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		// from now to eternity
		let entries = [
			SimpleEntry(date: Date()),
			SimpleEntry(date: .distantFuture)
		]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Complication: View {
	@Environment(\.widgetFamily) var widgetFamily
	@Environment(\.widgetRenderingMode) var widgetRenderingMode

	let circleInset = CGFloat(1) // to fix some edge anti-aliasing caused by the complication's clip geometry

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				AccessoryWidgetBackground()
				Image(systemName: "play.fill")
					.resizable()
					.aspectRatio(1, contentMode: .fit)
					.frame(width: (geometry.size.width / 2) - 4, height: (geometry.size.height / 2) - 4)
					.padding([.leading], 4) // to visually center the arrow
					.foregroundColor(Color("AccentColor"))
					.widgetAccentable()
					.unredacted()
				if widgetFamily == .accessoryCircular {
					Circle()
						.strokeBorder(.white, lineWidth: 2)
						.frame(width: geometry.size.width - circleInset, height: geometry.size.height - circleInset)
						.widgetAccentable()
				}
				else {
					Circle()
						.strokeBorder(Color("AccentColor"), lineWidth: 4)
						.frame(width: geometry.size.width - circleInset, height: geometry.size.height - circleInset)
				}
			}
			.widgetLabel {
				Text("Now Playing")
					.unredacted()
			}
		}
	}
}

struct ComplicationContainer: View {
	var body: some View {
		//if #available(watchOS 10.0, *) {
		if #available(watchOSApplicationExtension 10.0, *) {
			Complication()
				.containerBackground(.clear, for: .widget)
		} else {
			// fallback on earlier versions
			Complication()
		}
	}
}

@main
struct ComplicationWidget: Widget {
    let kind: String = "ComplicationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
			ComplicationContainer()
        }
        .configurationDisplayName("Now Playing+")
        .description("This complication gives you quick access to audio controls.")
		.supportedFamilies([.accessoryCircular, .accessoryCorner])
		.containerBackgroundRemovable(false)
    }
}

#Preview(as: .accessoryCircular) {
	ComplicationWidget()
		//.previewContext(WidgetPreviewContext(family: .accessoryCircular))
} timeline: {
	SimpleEntry(date: .now)
}

#Preview(as: .accessoryCorner) {
	ComplicationWidget()
		//.previewContext(WidgetPreviewContext(family: .accessoryCorner))
} timeline: {
	SimpleEntry(date: .now)
}

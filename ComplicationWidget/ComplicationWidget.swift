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
						.widgetAccentable()
				}
				else {
					Circle()
						.strokeBorder(Color("AccentColor"), lineWidth: 2)
				}
			}
			.widgetLabel {
				Text("Now Playing")
					.unredacted()
			}
		}
	}
}

@main
struct ComplicationWidget: Widget {
    let kind: String = "ComplicationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
			Complication()
        }
        .configurationDisplayName("NowPlaying+")
        .description("This complication gives you quick access to audio controls.")
		.supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct ComplicationWidget_Previews: PreviewProvider {
    static var previews: some View {
		Complication()
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
		Complication()
			.previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}

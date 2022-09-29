//
//  ContentView.swift
//  NowPlayingPlus Watch App
//
//  Created by Craig Hockenberry on 9/28/22.
//

import SwiftUI

import WatchKit

class Navigation: ObservableObject {
	@Published var path = NavigationPath()
	
	func showHelp() {
		path = NavigationPath()
	}
	
	func showNowPlaying() {
		path.append("")
	}
}

struct RootView: View {
	@AppStorage ("seenHelp") var seenHelp = false

	@EnvironmentObject var navigation: Navigation

	var body: some View {
		ScrollView {
			VStack (spacing: 0) {
				Text("This app can be set up as a circular or corner complication for easy access to audio controls.")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.caption)
				Spacer()
					.frame(height: 10)
				Button {
					seenHelp = true
					navigation.showNowPlaying()
				} label: {
					HStack {
						Text("Show Now Playing")
							.multilineTextAlignment(.leading)
						Spacer()
						Image(systemName: "chevron.forward")
					}
					.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity)
				.cornerRadius(10)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(10)
		}
	}
}

struct ContentView: View {
	@AppStorage ("seenHelp") var seenHelp = false
	
	@ObservedObject var navigation = Navigation()
	
	var body: some View {
		NavigationStack(path: $navigation.path) {
			ZStack {
				Rectangle()
					.ignoresSafeArea()
					.foregroundColor(Color("BackgroundColor"))
				RootView()
					.navigationDestination(for: String.self) { text in
						NowPlayingView()
							.navigationTitle(text)
							.navigationBarTitleDisplayMode(.inline)
							.toolbarBackground(.clear, for: .navigationBar)
					}
					.onAppear {
						if seenHelp {
							navigation.showNowPlaying()
						}
					}
					.navigationTitle("Now Playing+")
					.navigationBarTitleDisplayMode(.inline)
					.toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
			}
		}
		.environmentObject(navigation)
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

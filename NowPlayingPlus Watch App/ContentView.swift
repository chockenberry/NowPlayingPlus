//
//  ContentView.swift
//  NowPlayingPlus Watch App
//
//  Created by Craig Hockenberry on 9/28/22.
//

import SwiftUI

import WatchKit

enum Pages: Hashable {
	case nowPlaying
}

extension Bundle {
	var appVersion: String { info(for: "CFBundleShortVersionString") }
	var appBuild: String { info(for: "CFBundleVersion") }
	var copyright: String { info(for: "NSHumanReadableCopyright") }

	fileprivate func info(for str: String) -> String { infoDictionary?[str] as? String ?? "" }
}

struct RootView: View {
	@Binding var path: NavigationPath
	
	@AppStorage("seenHelp") var seenHelp = false
	@AppStorage("showAutomatically") var showAutomatically = false

	var body: some View {
		ScrollView {
			VStack (spacing: 0) {
				Button {
					seenHelp = true
					path.append(Pages.nowPlaying)
				} label: {
					HStack {
						Text("Show Now Playing")
							.multilineTextAlignment(.leading)
						Spacer()
						Image(systemName: "chevron.forward")
					}
					.padding([.leading, .trailing], 10)
					.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity)
				
				Spacer(minLength: 10)
				
				Text("This app can be set up as a circular or corner complication for easy access to audio controls.")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.footnote)
				
				Spacer(minLength: 20)
				
				VStack(spacing: 0) {
					Toggle(isOn: $showAutomatically) {
						Text("Show Automatically")
					}
					.tint(Color.accentColor)
					Text("Tapping the complication will automatically show the playback controls.")
						.foregroundStyle(.secondary)
						.font(.footnote)
				}
				
				Spacer(minLength: 20)
				
				Text("VERSION \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
					.font(.footnote)
					.foregroundColor(Color("AccentColor").opacity(0.5))
					.onLongPressGesture(minimumDuration: 3.0) {
						print("reset seenHelp")
						seenHelp = false
					}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(10)
		}
	}
}

struct ContentView: View {
	@AppStorage("seenHelp") var seenHelp = false
	@AppStorage("showAutomatically") var showAutomatically = false

	@Environment(\.scenePhase) var scenePhase
	
	@State var path = NavigationPath()
//	@State private var hasAppeared = false
	
	var body: some View {
		NavigationStack(path: $path) {
			ZStack {
				Rectangle()
					.fill(Color("BackgroundColorNew").gradient)
					.ignoresSafeArea()

				RootView(path: $path)
					.navigationDestination(for: Pages.self) { page in
						switch page {
						case .nowPlaying:
							NowPlayingView()
								.navigationBarTitleDisplayMode(.inline)
								.toolbarBackground(.clear, for: .navigationBar)
						}
					}
//					.onAppear {
//						print("onAppear: hasAppeared = \(hasAppeared)")
//						if !hasAppeared && seenHelp && showAutomatically {
//							path.append(Pages.nowPlaying)
//						}
//						hasAppeared = true
//					}
					.onChange(of: scenePhase, { oldValue, newValue in
						print("scenePhase: \(oldValue) -> \(newValue)")
						if newValue == .active {
							if seenHelp && showAutomatically {
								path = NavigationPath()
								path.append(Pages.nowPlaying)
							}
						}
					})
					.navigationTitle("Now Playing+")
					.navigationBarTitleDisplayMode(.inline)
					.toolbarBackground(Color("BackgroundColor"), for: .navigationBar)
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

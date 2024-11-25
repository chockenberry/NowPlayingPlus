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

extension Bundle {
	var appVersion: String { info(for: "CFBundleShortVersionString") }
	var appBuild: String { info(for: "CFBundleVersion") }
	var copyright: String { info(for: "NSHumanReadableCopyright") }

	fileprivate func info(for str: String) -> String { infoDictionary?[str] as? String ?? "" }
}

struct RootView: View {
	@AppStorage("seenHelp") var seenHelp = false
	@AppStorage("showAtLaunch") var showAtLaunch = false

	@EnvironmentObject var navigation: Navigation

	var body: some View {
		ScrollView {
			VStack (spacing: 0) {
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
					.padding([.leading, .trailing], 10)
					.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity)

				Spacer()
					.frame(height: 10)

				Text("This app can be set up as a circular or corner complication for easy access to audio controls.")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.footnote)

				Spacer()
					.frame(height: 50) // to push the version number below the fold

				VStack(spacing: 20) {
					Toggle(isOn: $showAtLaunch) {
						Text("Show at Launch")
					}
					.tint(Color.accentColor)
					
					Text("VERSION \(Bundle.main.appVersion) (\(Bundle.main.appBuild))")
						.font(.footnote)
						.foregroundColor(Color("AccentColor").opacity(0.5))
						.onLongPressGesture(minimumDuration: 3.0) {
							print("reset seenHelp")
							seenHelp = false
						}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(10)
		}
	}
}

struct ContentView: View {
	@AppStorage("seenHelp") var seenHelp = false
	@AppStorage("showAtLaunch") var showAtLaunch = false

	@ObservedObject var navigation = Navigation()
	
	@State private var hasAppeared = false
	
	var body: some View {
		NavigationStack(path: $navigation.path) {
			ZStack {
				if #available(watchOS 10.0, *) {
					Rectangle()
						.fill(Color("BackgroundColorNew").gradient)
						.ignoresSafeArea()
				}
				else {
					// Fallback on earlier versions
					Rectangle()
						.fill(Color("BackgroundColor"))
						.ignoresSafeArea()
				}
				RootView()
					.navigationDestination(for: String.self) { text in
						NowPlayingView()
							.navigationTitle(text)
							.navigationBarTitleDisplayMode(.inline)
							.toolbarBackground(.clear, for: .navigationBar)
					}
					.onAppear {
						print("onAppear: hasAppeared = \(hasAppeared)")
						if !hasAppeared && seenHelp && showAtLaunch {
							navigation.showNowPlaying()
						}
						hasAppeared = true
					}
//					.task {
//						print("task: hasAppeared = \(hasAppeared)")
//						if !hasAppeared {
//							if showAtLaunch && seenHelp {
//								try? await Task.sleep(nanoseconds: 1_000_000)
//								navigation.showNowPlaying()
//							}
//						}
//					}
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

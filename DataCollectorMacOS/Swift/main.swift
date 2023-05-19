import AppKit
import Cocoa




var writtenLinesSet = Set<String>()
var AppleAppSet = Set<String>()

func initializeWrittenLinesSet() {
	let currentDirectory = FileManager.default.currentDirectoryPath
	let csvURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent("app_launch_data.csv")
	
//	let home = FileManager.default.homeDirectoryForCurrentUser
//	let csvURL = home.appendingPathComponent("app_launch_data.csv")

	do {
		if FileManager.default.fileExists(atPath: csvURL.path) {
			let csvContent = try String(contentsOf: csvURL, encoding: .utf8)
			let csvLines = csvContent.components(separatedBy: .newlines)
			for line in csvLines where !line.isEmpty {
				writtenLinesSet.insert(line)
			}
		}
	} catch {
		print("Error reading CSV file: \(error)")
	}
}

func appendToCSVFile(appName: String,bundleID:String, timestamp: Date) {
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
	let formattedTimestamp = dateFormatter.string(from: timestamp)
	let csvLine = "\(appName),\(bundleID),\(formattedTimestamp)"
	if bundleID=="unknown" || appName=="caphost"{
		return
	}
	
	if bundleID.contains("com.apple") && !AppleAppSet.contains(bundleID) {
			return
		}
	
	if bundleID.contains("com.adguard"){
		return
	}
	
	
	if writtenLinesSet.contains(csvLine) {
		return
	}
	
	
	print("Name: \(appName)")
	print("Bundle ID: \(bundleID)")
	print("Launch Date: \(timestamp)")
	

	writtenLinesSet.insert(csvLine)
	let csvLineWithNewLine = csvLine + "\n"

	let currentDirectory = FileManager.default.currentDirectoryPath
	let csvURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent("app_launch_data.csv")
	
//	let home = FileManager.default.homeDirectoryForCurrentUser
//	let csvURL = home.appendingPathComponent("app_launch_data.csv")
//
	do {
		if !FileManager.default.fileExists(atPath: csvURL.path) {
			try "App_Name,Bundle_ID,Timestamp\n".write(to: csvURL, atomically: true, encoding: .utf8)
		}
		let fileHandle = try FileHandle(forWritingTo: csvURL)
		fileHandle.seekToEndOfFile()
		fileHandle.write(csvLineWithNewLine.data(using: .utf8)!)
		fileHandle.closeFile()
	} catch {
		print("Error writing to CSV file: \(error)")
	}
}

// Initialize writtenLinesSet
initializeWrittenLinesSet()

// Set excluded app names
AppleAppSet = ["com.apple.Photos","com.apple.iCal","com.apple.reminders","com.apple.TV","com.apple.Notes","com.apple.MobileSMS","com.apple.dt.Xcode","com.apple.iWork.Numbers","com.apple.Safari","com.apple.calculator"]

class AppObserver: NSObject {
	@objc func applicationDidLaunch(notification: NSNotification) {
		guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
			  let appName = app.localizedName,
			  let bundleID = app.bundleIdentifier,
			  let launchDate = app.launchDate else {
			return
		}
		appendToCSVFile(appName: appName, bundleID: bundleID, timestamp: launchDate)
	}
}

let observer = AppObserver()
let workspace = NSWorkspace.shared
workspace.notificationCenter.addObserver(observer, selector: #selector(AppObserver.applicationDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
RunLoop.current.run()  // Run the runloop indefinitely to keep receiving notifications

//

//while true {
//	let workspace = NSWorkspace.shared
//	let runningApps = workspace.runningApplications
//	for app in runningApps {
//
//		appendToCSVFile(appName: (app.localizedName ?? "unknown"), bundleID: (app.bundleIdentifier ?? "unknown"), timestamp: (app.launchDate ?? Date()))
//	}
//
//}


//LAUNCHING

//
//let workspace = NSWorkspace.shared
//let bundleIdentifier = "com.apple.calculator" // replace with your bundle identifier
//
//if let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
//	do {
//		try workspace.launchApplication(at: url, options: [], configuration: [:])
//	} catch {
//		print("Failed to launch application: \(error)")
//	}
//} else {
//	print("Application not found")
//}

import Foundation
import SwiftUI

@MainActor
class VersionService: ObservableObject {
    @Published var currentVersion: String = "Unknown"
    @Published var latestVersion: String?
    @Published var hasUpdate: Bool = true
    @Published var isCheckingForUpdate: Bool = false
    @Published var lastUpdateCheck: Date?
    @Published var hasError: Bool = false
    @Published var errorMessage: String?
    
    private let githubRepo = "bhrigu123/TimeCraft"
    private let updateCheckInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadCurrentVersion()
        loadCachedUpdateInfo()
        
        // Check for updates if it's been more than 24 hours since last check
        if shouldCheckForUpdate() {
            Task {
                await checkForUpdates()
            }
        }
    }
    
    private func loadCurrentVersion() {
        // Get version from app bundle
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            currentVersion = version
            hasError = false
            errorMessage = nil
        } else if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            currentVersion = version
            hasError = false
            errorMessage = nil
        } else {
            currentVersion = "Unknown"
            hasError = true
            errorMessage = "Unable to find version information in app bundle"
        }
    }
    
    private func loadCachedUpdateInfo() {
        latestVersion = userDefaults.string(forKey: "CachedLatestVersion")
        lastUpdateCheck = userDefaults.object(forKey: "LastUpdateCheck") as? Date
        
        if let latest = latestVersion {
            hasUpdate = isVersionNewer(latest, than: currentVersion)
        }
    }
    
    private func shouldCheckForUpdate() -> Bool {
        guard let lastCheck = lastUpdateCheck else { return true }
        return Date().timeIntervalSince(lastCheck) > updateCheckInterval
    }
    
    func checkForUpdates() async {
        isCheckingForUpdate = true
        
        do {
            let latest = try await fetchLatestVersionFromGitHub()
            
            // Cache the results
            userDefaults.set(latest, forKey: "CachedLatestVersion")
            userDefaults.set(Date(), forKey: "LastUpdateCheck")
            
            latestVersion = latest
            hasUpdate = isVersionNewer(latest, than: currentVersion)
            lastUpdateCheck = Date()
            
            // Clear any previous network/update check errors (but keep bundle errors)
            if hasError && errorMessage?.contains("bundle") == false {
                hasError = false
                errorMessage = nil
            }
            
        } catch {
            print("Failed to check for updates: \(error)")
            hasError = true
            
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    errorMessage = "No internet connection available"
                case .cannotFindHost:
                    errorMessage = "Cannot reach GitHub servers"
                case .timedOut:
                    errorMessage = "Update check timed out"
                case .badServerResponse:
                    errorMessage = "Invalid response from GitHub"
                default:
                    errorMessage = "Network error while checking for updates"
                }
            } else {
                errorMessage = "Error checking for updates: \(error.localizedDescription)"
            }
        }
        
        isCheckingForUpdate = false
    }
    
    private func fetchLatestVersionFromGitHub() async throws -> String {
        guard let url = URL(string: "https://api.github.com/repos/\(githubRepo)/releases/latest") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check for HTTP errors
        if let httpResponse = response as? HTTPURLResponse {
            guard 200...299 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }
        }
        
        struct GitHubRelease: Codable {
            let tag_name: String
            let name: String?
        }
        
        do {
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            
            // Remove 'v' prefix if present (e.g., "v1.0.2" -> "1.0.2")
            let version = release.tag_name.hasPrefix("v") ? 
                String(release.tag_name.dropFirst()) : release.tag_name
            
            return version
        } catch {
            throw error
        }
    }
    
    private func isVersionNewer(_ version1: String, than version2: String) -> Bool {
        // test
        return true
        /*
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        // Pad with zeros to make arrays same length
        let maxCount = max(v1Components.count, v2Components.count)
        let paddedV1 = v1Components + Array(repeating: 0, count: maxCount - v1Components.count)
        let paddedV2 = v2Components + Array(repeating: 0, count: maxCount - v2Components.count)
        
        for i in 0..<maxCount {
            if paddedV1[i] > paddedV2[i] {
                return true
            } else if paddedV1[i] < paddedV2[i] {
                return false
            }
        }
        
        return false // Versions are equal
        */
    }
    
    func openReleasesPage() {
        let url = URL(string: "https://github.com/\(githubRepo)/releases/latest")!
        NSWorkspace.shared.open(url)
    }
    
    func manualCheckForUpdates() {
        Task {
            await checkForUpdates()
        }
    }
} 
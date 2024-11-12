//
//  CacheManager.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//

import Foundation

public class CacheManager {
    let cacheDir: URL
    let fileManager = FileManager.default
    
    public init(cacheDir: URL? = nil) throws {
        if let cacheDir {
            self.cacheDir = cacheDir
        } else {
#if os(macOS)
            self.cacheDir = URL(fileURLWithPath: Constants.hfHubCache.expandingTildeInPath).standardized
            if !self.cacheDir.isDirectory() {
                throw CacheManagerError.notFound(self.cacheDir)
            }
#else
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.cacheDir = documents.appending(component: "huggingface/hub")
#endif
        }
    }
    
    public func scanCacheDir() throws -> HFCacheInfo {
        var repos = Set<CachedRepoInfo>()
        var warnings = [Error]()
        
        let repoURLs = try fileManager.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        
        for repoURL in repoURLs {
            if repoURL.lastPathComponent == ".locks" {
                continue
            }
            
            do {
                try repos.insert(scanCachedRepo(repoURL))
            } catch {
                warnings.append(error)
            }
        }
                   
        return HFCacheInfo(
            sizeOnDisk: repos.reduce(0) { $0 + $1.sizeOnDisk },
            repos: repos,
            warnings: warnings
        )
    }
    
    func scanRefsByHash(_ repoURL: URL) throws -> [String: Set<String>] {
        let refsPath = repoURL.appendingPathComponent("refs")
        var refsByHash: [String: Set<String>] = [:]
        if refsPath.exists() {
            if refsPath.isFile() {
                throw CacheManagerError.corrupted("Refs directory cannot be a file: \(refsPath.path)")
            }
            
            if let enumerator = fileManager.enumerator(
                at: refsPath,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                while let refURL = enumerator.nextObject() as? URL {
                    let resourceValues = try refURL.resourceValues(forKeys: [.isDirectoryKey])
                    guard let isDirectory = resourceValues.isDirectory, !isDirectory else { continue }
                    let refName = refURL.path.replacingOccurrences(of: refsPath.path + "/", with: "")
                    let commitHash = try String(contentsOf: refURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                    refsByHash[commitHash, default: []].insert(refName)
                }
            }
        }
        
        return refsByHash
    }
    
    func scanCachedRepo(_ repoURL: URL) throws -> CachedRepoInfo {
        if !repoURL.hasDirectoryPath {
            throw CacheManagerError.corrupted("Repo path is not a directory: \(repoURL.path)")
        }
        
        let (repoType, repoId) = try Self.parseRepo(repoURL)
        
        var blobStats = [URL: [FileAttributeKey: Any]]()
        
        let snapshotsPath = repoURL.appendingPathComponent("snapshots")
        
        guard snapshotsPath.isDirectory() else {
            throw CacheManagerError.corrupted("Snapshots dir doesn't exist in cached repo: \(snapshotsPath.path)")
        }
        
        var refsByHash = try scanRefsByHash(repoURL)
        
        var cachedRevisions = Set<CachedRevisionInfo>()
        
        let snapshotURLs = try fileManager.contentsOfDirectory(
            at: snapshotsPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        for revisionURL in snapshotURLs {
            if Constants.filesToIgnore.contains(revisionURL.lastPathComponent) {
                continue
            }
            
            if revisionURL.isFile() {
                throw CacheManagerError.corrupted("Snapshots folder corrupted. Found a file: \(revisionURL.path)")
            }
            
            var cachedFiles = Set<CachedFileInfo>()
            
            if let enumerator = fileManager.enumerator(
                at: revisionURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) {
                while let fileURL = enumerator.nextObject() as? URL {
                    if fileURL.isDirectory() {
                        continue
                    }
                    
                    let blobURL = fileURL.resolvingSymlinksInPath()
                    guard blobURL.exists() else {
                        throw CacheManagerError.corrupted("Blob missing (broken symlink): \(blobURL.path)")
                    }
                    
                    if blobStats[blobURL] == nil {
                        blobStats[blobURL] = try fileManager.attributesOfItem(atPath: blobURL.path)
                    }
                    
                    cachedFiles.insert(
                        CachedFileInfo(
                            fileName: fileURL.lastPathComponent,
                            filePath: fileURL,
                            blobPath: blobURL,
                            sizeOnDisk: blobStats[blobURL]?[.size] as? Int ?? 0,
                            blobLastAccessed: blobStats[blobURL]?[.creationDate] as? TimeInterval ?? 0,
                            blobLastModified: blobStats[blobURL]?[.modificationDate] as? TimeInterval ?? 0
                        )
                    )
                }
            }
            
            let revisionLastModified: TimeInterval = if cachedFiles.isEmpty {
                if let attributes = try? fileManager.attributesOfItem(atPath: revisionURL.path),
                   let modDate = attributes[.modificationDate] as? Date
                {
                    modDate.timeIntervalSince1970
                } else {
                    0
                }
            } else {
                cachedFiles.map(\.blobLastModified).max() ?? 0
            }
            
            cachedRevisions.insert(
                CachedRevisionInfo(
                    commitHash: revisionURL.lastPathComponent,
                    snapshotPath: revisionURL,
                    sizeOnDisk: cachedFiles.reduce(0) { $0 + $1.sizeOnDisk },
                    files: cachedFiles,
                    refs: refsByHash.removeValue(forKey: revisionURL.lastPathComponent) ?? [],
                    lastModified: revisionLastModified
                )
            )
        }
        
        guard refsByHash.isEmpty else {
            throw CacheManagerError.corrupted("Reference(s) refer to missing commit hashes: \(refsByHash) (\(repoURL.path)).")
        }
        
        let (repoLastAccessed, repoLastModified): (TimeInterval, TimeInterval)
        if !blobStats.isEmpty {
            repoLastAccessed = blobStats.values.compactMap { $0[.creationDate] as? Date }.map(\.timeIntervalSince1970).max() ?? 0
            repoLastModified = blobStats.values.compactMap { $0[.modificationDate] as? Date }.map(\.timeIntervalSince1970).max() ?? 0
        } else {
            if let attributes = try? fileManager.attributesOfItem(atPath: repoURL.path) {
                repoLastAccessed = (attributes[.creationDate] as? Date)?.timeIntervalSince1970 ?? 0
                repoLastModified = (attributes[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
            } else {
                repoLastAccessed = 0
                repoLastModified = 0
            }
        }
        
        return CachedRepoInfo(
            repoId: repoId,
            repoType: repoType,
            repoPath: repoURL,
            sizeOnDisk: blobStats.values.reduce(0) { $0 + Int(($1[.size] as? Int64) ?? 0) },
            nbFiles: blobStats.count,
            revisions: cachedRevisions,
            lastAccessed: repoLastAccessed,
            lastModified: repoLastModified
        )
    }
    
    static func parseRepo(_ repoURL: URL) throws -> (RepoType, String) {
        let repoName = repoURL.lastPathComponent

        guard let separatorRange = repoName.range(of: "--") else {
            throw CacheManagerError.corrupted("Repo path is not a valid HuggingFace cache directory: \(repoURL.path)")
        }
        
        var repoType = String(repoName[..<separatorRange.lowerBound])
        if repoType.hasSuffix("s") {
            repoType.removeLast()
        }
        
        let repoId = repoName[separatorRange.upperBound...].replacingOccurrences(of: "--", with: "/")
        
        guard let repoType = RepoType(rawValue: repoType) else {
            throw CacheManagerError.corrupted("Repo type must be `dataset`, `model` or `space`, found `\(repoURL.path)` (\(repoURL.path)")
        }
            
        return (repoType, repoId)
    }
}

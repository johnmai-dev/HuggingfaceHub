//
//  HFCacheInfo.swift
//  HuggingfaceHub
//
//  Created by John Mai on 2024/11/11.
//


import Foundation

public struct HFCacheInfo {
    let sizeOnDisk: Int
    let repos: Set<CachedRepoInfo>
    let warnings: [Error]

    var sizeOnDiskStr: String {
        return ""
    }

//    func deleteRevisions(_ revisions: String...) -> DeleteCacheStrategy {
//        var hashesToDelete = Set(revisions)
//        var reposWithRevisions = [CachedRepoInfo: Set<CachedRevisionInfo>]()
//
//        for repo in repos {
//            for revision in repo.revisions {
//                if hashesToDelete.contains(revision.commitHash) {
//                    reposWithRevisions[repo, default: []].insert(revision)
//                    hashesToDelete.remove(revision.commitHash)
//                }
//            }
//        }
//
//        if !hashesToDelete.isEmpty {
//            print("Revision(s) not found - cannot delete them: \(hashesToDelete.joined(separator: ", "))")
//        }
//
//        var deleteStrategyBlobs = Set<URL>()
//        var deleteStrategyRefs = Set<URL>()
//        var deleteStrategyRepos = Set<URL>()
//        var deleteStrategySnapshots = Set<URL>()
//        var deleteStrategyExpectedFreedSize = 0
//
//        for (affectedRepo, revisionsToDelete) in reposWithRevisions {
//            let otherRevisions = affectedRepo.revisions.subtracting(revisionsToDelete)
//
//            if otherRevisions.isEmpty {
//                deleteStrategyRepos.insert(affectedRepo.repoPath)
//                deleteStrategyExpectedFreedSize += affectedRepo.sizeOnDisk
//                continue
//            }
//
//            for revisionToDelete in revisionsToDelete {
//                deleteStrategySnapshots.insert(revisionToDelete.snapshotPath)
//
//                for ref in revisionToDelete.refs {
//                    deleteStrategyRefs.insert(affectedRepo.repoPath.appendingPathComponent("refs").appendingPathComponent(ref))
//                }
//
//                for file in revisionToDelete.files {
//                    if !deleteStrategyBlobs.contains(file.blobPath) {
//                        var isFileAlone = true
//                        for revision in otherRevisions {
//                            if revision.files.contains(where: { $0.blobPath == file.blobPath }) {
//                                isFileAlone = false
//                                break
//                            }
//                        }
//
//                        if isFileAlone {
//                            deleteStrategyBlobs.insert(file.blobPath)
//                            deleteStrategyExpectedFreedSize += file.sizeOnDisk
//                        }
//                    }
//                }
//            }
//        }
//
//        return DeleteCacheStrategy(
//            blobs: deleteStrategyBlobs,
//            refs: deleteStrategyRefs,
//            repos: deleteStrategyRepos,
//            snapshots: deleteStrategySnapshots,
//            expectedFreedSize: deleteStrategyExpectedFreedSize
//        )
//    }
//
//    func exportAsTable(verbosity: Int = 0) -> String {
//        if verbosity == 0 {
//            let rows = repos.sorted { $0.repoPath < $1.repoPath }.map { repo in
//                [
//                    repo.repoId,
//                    repo.repoType,
//                    String(format: "%12@", repo.sizeOnDiskStr),
//                    "\(repo.nbFiles)",
//                    repo.lastAccessedStr,
//                    repo.lastModifiedStr,
//                    repo.refs.sorted().joined(separator: ", "),
//                    repo.repoPath.path
//                ]
//            }
//            return tabulate(rows: rows, headers: ["REPO ID", "REPO TYPE", "SIZE ON DISK", "NB FILES", "LAST_ACCESSED", "LAST_MODIFIED", "REFS", "LOCAL PATH"])
//        } else {
//            let rows = repos.sorted { $0.repoPath < $1.repoPath }.flatMap { repo in
//                repo.revisions.sorted { $0.commitHash < $1.commitHash }.map { revision in
//                    [
//                        repo.repoId,
//                        repo.repoType,
//                        revision.commitHash,
//                        String(format: "%12@", revision.sizeOnDiskStr),
//                        "\(revision.nbFiles)",
//                        revision.lastModifiedStr,
//                        revision.refs.sorted().joined(separator: ", "),
//                        revision.snapshotPath.path
//                    ]
//                }
//            }
//            return tabulate(rows: rows, headers: ["REPO ID", "REPO TYPE", "REVISION", "SIZE ON DISK", "NB FILES", "LAST_MODIFIED", "REFS", "LOCAL PATH"])
//        }
//    }
}

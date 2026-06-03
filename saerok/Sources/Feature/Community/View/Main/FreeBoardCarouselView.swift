//
//  FreeBoardCarouselView.swift
//  saerok
//

import SwiftUI
import UIKit

// MARK: - UIViewRepresentable

struct FreeBoardInfiniteCarouselView: UIViewRepresentable {

    let posts: [Local.FreeBoardPostSummary]
    @Binding var displayIndex: Int
    let onPostTap: (Int) -> Void
    let onCTATap: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Const.spacing
        layout.itemSize = CGSize(width: Const.cardWidth, height: Const.itemHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: Const.leadingInset, bottom: 0, right: Const.trailingInset)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.clipsToBounds = false
        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator
        cv.register(Cell.self, forCellWithReuseIdentifier: Cell.id)
        context.coordinator.cv = cv
        return cv
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        let coord = context.coordinator
        coord.parent = self

        let newIds = posts.map(\.id)
        let oldIds = coord.posts.map(\.id)
        guard !coord.didSetup || newIds != oldIds else { return }

        coord.didSetup = true
        coord.posts = posts
        coord.buildItems()
        uiView.reloadData()
        DispatchQueue.main.async {
            coord.scrollToStart(animated: false)
            coord.startTimer()
        }
    }

    // MARK: - Constants
    enum Const {
        static let cardWidth: CGFloat = 300
        static let cardHeight: CGFloat = 83
        static let shadowPad: CGFloat = 10
        static let itemHeight: CGFloat = cardHeight + shadowPad * 2
        static let spacing: CGFloat = 9
        static let leadingInset: CGFloat = 14 + spacing
        static let trailingInset: CGFloat = 200
        static let bufferCount = 2
        static var snapUnit: CGFloat { cardWidth + spacing }
    }
}

// MARK: - Coordinator

extension FreeBoardInfiniteCarouselView {

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        var parent: FreeBoardInfiniteCarouselView
        var posts: [Local.FreeBoardPostSummary] = []
        weak var cv: UICollectionView?
        var didSetup = false
        private(set) var allItems: [Item] = []
        private var timer: Timer?
        private var isAdvancing = false

        enum Item {
            case post(Local.FreeBoardPostSummary)
            case cta
        }

        private let bufferCount = Const.bufferCount
        private let snapUnit = Const.snapUnit

        init(_ parent: FreeBoardInfiniteCarouselView) {
            self.parent = parent
        }

        var actualCount: Int {
            guard allItems.count > bufferCount * 2 else { return allItems.count }
            return allItems.count - bufferCount * 2
        }

        func buildItems() {
            let actual = posts.prefix(5).map { Item.post($0) } + [Item.cta]
            guard actual.count >= 2 else { allItems = actual; return }
            allItems = Array(actual.suffix(bufferCount)) + actual + Array(actual.prefix(bufferCount))
        }

        func scrollToStart(animated: Bool) {
            guard actualCount > 1 else { return }
            cv?.setContentOffset(CGPoint(x: CGFloat(bufferCount) * snapUnit, y: 0), animated: animated)
        }

        // MARK: Timer

        func startTimer() {
            guard actualCount > 1 else { return }
            stopTimer()
            timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
                self?.advance()
            }
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        private func advance() {
            guard let cv else { return }
            isAdvancing = true
            let nextX = cv.contentOffset.x + snapUnit
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
                cv.contentOffset.x = nextX
            } completion: { [weak self] _ in
                guard let self else { return }
                self.isAdvancing = false
                self.correctBoundaryIfNeeded()
            }
        }

        private func correctBoundaryIfNeeded() {
            guard let cv else { return }
            let x = cv.contentOffset.x
            let count = actualCount
            guard count > 1 else { return }

            if x >= CGFloat(bufferCount + count) * snapUnit {
                cv.setContentOffset(CGPoint(x: x - CGFloat(count) * snapUnit, y: 0), animated: false)
            } else if x <= CGFloat(bufferCount - 1) * snapUnit {
                cv.setContentOffset(CGPoint(x: x + CGFloat(count) * snapUnit, y: 0), animated: false)
            }
        }

        // MARK: DataSource

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            allItems.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.id, for: indexPath) as! Cell
            cell.clipsToBounds = false
            cell.contentView.clipsToBounds = false
            cell.configure(item: allItems[indexPath.item], onPostTap: parent.onPostTap, onCTATap: parent.onCTATap)
            return cell
        }

        // MARK: Infinite Scroll

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let x = scrollView.contentOffset.x
            let count = actualCount
            guard count > 1 else { return }

            // 자동 advance 중에는 보정하지 않는다. (애니메이션 완료 후 correctBoundaryIfNeeded가 처리)
            if !isAdvancing {
                if x >= CGFloat(bufferCount + count) * snapUnit {
                    scrollView.layer.removeAllAnimations()
                    scrollView.setContentOffset(CGPoint(x: CGFloat(bufferCount) * snapUnit, y: 0), animated: false)
                } else if x <= CGFloat(bufferCount - 1) * snapUnit {
                    scrollView.layer.removeAllAnimations()
                    scrollView.setContentOffset(CGPoint(x: CGFloat(bufferCount + count - 1) * snapUnit, y: 0), animated: false)
                }
            }

            let nearest = Int(round(x / snapUnit))
            let adjusted = nearest - bufferCount
            let wrapped = ((adjusted % count) + count) % count
            if parent.displayIndex != wrapped { parent.displayIndex = wrapped }
        }

        // MARK: Snap (one card per swipe)

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            let currentIndex = scrollView.contentOffset.x / snapUnit
            let target: CGFloat
            if velocity.x > 0.3 {
                target = ceil(currentIndex)
            } else if velocity.x < -0.3 {
                target = floor(currentIndex)
            } else {
                let proposed = round(targetContentOffset.pointee.x / snapUnit)
                target = max(floor(currentIndex), min(ceil(currentIndex), proposed))
            }
            targetContentOffset.pointee.x = target * snapUnit
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isAdvancing = false
            stopTimer()
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { startTimer() }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            startTimer()
        }
    }
}

// MARK: - Cell

extension FreeBoardInfiniteCarouselView {

    final class Cell: UICollectionViewCell {
        static let id = "FreeBoardCarouselCell"

        func configure(
            item: Coordinator.Item,
            onPostTap: @escaping (Int) -> Void,
            onCTATap: @escaping () -> Void
        ) {
            contentConfiguration = UIHostingConfiguration {
                Group {
                    switch item {
                    case .post(let post):
                        FreeBoardPostCarouselCard(post: post, onTap: { onPostTap(post.id) })
                    case .cta:
                        FreeBoardCTACarouselCard(onTap: onCTATap)
                    }
                }
                .padding(.vertical, FreeBoardInfiniteCarouselView.Const.shadowPad)
            }
            .margins(.all, 0)
            backgroundColor = .clear
        }
    }
}

// MARK: - Card Views

struct FreeBoardPostCarouselCard: View {
    let post: Local.FreeBoardPostSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    ReactiveAsyncImage(
                        url: post.thumbnailProfileImageUrl ?? "",
                        scale: .small,
                        size: .init(width: 20, height: 20),
                        downsampling: true
                    )
                    .srAvatarStyle_2()
                    Text(post.nickname)
                        .font(.SRFontSet.caption1)
                        .lineLimit(1)
                    Spacer()
                    Text(post.createdAt.carouselRelativeString)
                        .font(.SRFontSet.caption3)
                        .foregroundStyle(.srGray)
                }
                .padding(.bottom, 10)
                Text(post.content.allowLineBreaking())
                    .font(.SRFontSet.caption3)
                    .lineLimit(2)
                    .foregroundStyle(.srDarkGray)
                    .multilineTextAlignment(.leading)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 300, height: 83)
            .background(Color.srWhite)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(Color.whiteGray, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct FreeBoardCTACarouselCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 17) {
                Text("자유게시판에 글을 남겨보세요!")
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.srGray)
                Image(systemName: "arrow.right")
                    .foregroundStyle(.srWhite)
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .background(.whiteGray)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 300, height: 83)
            .background(Color.srWhite)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private extension Date {
    var carouselRelativeString: String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.unitsStyle = .abbreviated
        return f.localizedString(for: self, relativeTo: .now)
    }
}

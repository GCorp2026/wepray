import SwiftUI
import Combine

class PrayerCircleViewModel: ObservableObject {
    @Published var circles: [PrayerCircle] = []
    @Published var myCircles: [PrayerCircle] = []
    @Published var searchText = ""
    @Published var selectedCategory: CircleCategory?
    @Published var isLoading = false

    private let circlesKey = "prayerCircles"

    init() {
        loadCircles()
    }

    // MARK: - Computed Properties

    var filteredCircles: [PrayerCircle] {
        var result = circles

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var joinedCircles: [PrayerCircle] {
        circles.filter { $0.isJoined }
    }

    var circlesWithUpcomingMeetings: [PrayerCircle] {
        circles.filter { $0.nextMeeting?.isUpcoming == true }
            .sorted { ($0.nextMeeting?.scheduledDate ?? .distantFuture) < ($1.nextMeeting?.scheduledDate ?? .distantFuture) }
    }

    var totalPrayerRequests: Int {
        joinedCircles.reduce(0) { $0 + $1.prayerRequests.count }
    }

    // MARK: - Circle Management

    func createCircle(_ circle: PrayerCircle) {
        var newCircle = circle
        newCircle.isJoined = true
        circles.append(newCircle)
        saveCircles()
    }

    func joinCircle(_ circle: PrayerCircle) {
        guard let index = circles.firstIndex(where: { $0.id == circle.id }) else { return }
        circles[index].isJoined = true
        circles[index].memberCount += 1
        saveCircles()
    }

    func leaveCircle(_ circle: PrayerCircle) {
        guard let index = circles.firstIndex(where: { $0.id == circle.id }) else { return }
        circles[index].isJoined = false
        circles[index].memberCount = max(0, circles[index].memberCount - 1)
        saveCircles()
    }

    func deleteCircle(_ circle: PrayerCircle) {
        circles.removeAll { $0.id == circle.id }
        saveCircles()
    }

    // MARK: - Meeting Management

    func scheduleMeeting(for circleId: UUID, meeting: CircleMeeting) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[index].nextMeeting = meeting
        saveCircles()
    }

    func cancelMeeting(for circleId: UUID) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[index].nextMeeting = nil
        saveCircles()
    }

    func joinMeeting(_ meeting: CircleMeeting, circleId: UUID, userName: String) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              var currentMeeting = circles[circleIndex].nextMeeting else { return }

        if !currentMeeting.attendees.contains(userName) {
            currentMeeting.attendees.append(userName)
            circles[circleIndex].nextMeeting = currentMeeting
            saveCircles()
        }
    }

    // MARK: - Prayer Request Management

    func addPrayerRequest(to circleId: UUID, request: CirclePrayerRequest) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[index].prayerRequests.insert(request, at: 0)
        saveCircles()
    }

    func markAsPrayed(requestId: UUID, in circleId: UUID) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let requestIndex = circles[circleIndex].prayerRequests.firstIndex(where: { $0.id == requestId }) else { return }

        circles[circleIndex].prayerRequests[requestIndex].hasPrayed = true
        circles[circleIndex].prayerRequests[requestIndex].prayerCount += 1
        saveCircles()
    }

    func updateRequestStatus(requestId: UUID, in circleId: UUID, status: RequestStatus) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let requestIndex = circles[circleIndex].prayerRequests.firstIndex(where: { $0.id == requestId }) else { return }

        circles[circleIndex].prayerRequests[requestIndex].status = status
        saveCircles()
    }

    func addResponse(to requestId: UUID, in circleId: UUID, response: CirclePrayerResponse) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let requestIndex = circles[circleIndex].prayerRequests.firstIndex(where: { $0.id == requestId }) else { return }

        circles[circleIndex].prayerRequests[requestIndex].responses.append(response)
        saveCircles()
    }

    // MARK: - Member Management

    func addMember(to circleId: UUID, member: CircleMember) {
        guard let index = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[index].members.append(member)
        circles[index].memberCount += 1
        saveCircles()
    }

    func removeMember(memberId: UUID, from circleId: UUID) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }) else { return }
        circles[circleIndex].members.removeAll { $0.id == memberId }
        circles[circleIndex].memberCount = max(0, circles[circleIndex].memberCount - 1)
        saveCircles()
    }

    func updateMemberRole(memberId: UUID, in circleId: UUID, role: MemberRole) {
        guard let circleIndex = circles.firstIndex(where: { $0.id == circleId }),
              let memberIndex = circles[circleIndex].members.firstIndex(where: { $0.id == memberId }) else { return }

        circles[circleIndex].members[memberIndex] = CircleMember(
            id: circles[circleIndex].members[memberIndex].id,
            name: circles[circleIndex].members[memberIndex].name,
            initials: circles[circleIndex].members[memberIndex].initials,
            role: role,
            joinedAt: circles[circleIndex].members[memberIndex].joinedAt,
            prayerCount: circles[circleIndex].members[memberIndex].prayerCount
        )
        saveCircles()
    }

    // MARK: - Persistence

    private func loadCircles() {
        if let data = UserDefaults.standard.data(forKey: circlesKey),
           let decoded = try? JSONDecoder().decode([PrayerCircle].self, from: data) {
            circles = decoded
        } else {
            circles = PrayerCircle.sampleCircles
            saveCircles()
        }
    }

    private func saveCircles() {
        if let encoded = try? JSONEncoder().encode(circles) {
            UserDefaults.standard.set(encoded, forKey: circlesKey)
        }
    }

    func refreshCircles() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadCircles()
            self?.isLoading = false
        }
    }
}

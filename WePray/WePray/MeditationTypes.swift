//
//  MeditationTypes.swift
//  WePray - Guided Meditation & Prayer Data Models
//

import Foundation
import SwiftUI

// MARK: - Meditation Session Model
struct MeditationSession: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let duration: Int // in minutes
    let category: MeditationCategory
    let difficulty: MeditationDifficulty
    let scriptText: String
    let backgroundMusic: MeditationMusic
    let iconName: String
    var isFavorite: Bool = false
    var completionCount: Int = 0
    var lastCompleted: Date?

    var formattedDuration: String { "\(duration) min" }
}

// MARK: - Meditation Category
enum MeditationCategory: String, CaseIterable, Codable {
    case morning = "Morning Prayer"
    case evening = "Evening Prayer"
    case peace = "Finding Peace"
    case gratitude = "Gratitude"
    case healing = "Healing Prayer"
    case forgiveness = "Forgiveness"
    case strength = "Strength & Courage"
    case guidance = "Divine Guidance"
    case sleep = "Sleep & Rest"
    case stress = "Stress Relief"

    var icon: String {
        switch self {
        case .morning: return "sun.horizon.fill"
        case .evening: return "moon.stars.fill"
        case .peace: return "leaf.fill"
        case .gratitude: return "heart.fill"
        case .healing: return "cross.fill"
        case .forgiveness: return "hand.raised.fill"
        case .strength: return "bolt.fill"
        case .guidance: return "signpost.right.fill"
        case .sleep: return "bed.double.fill"
        case .stress: return "wind"
        }
    }

    var color: Color {
        switch self {
        case .morning: return .orange
        case .evening: return .indigo
        case .peace: return .green
        case .gratitude: return .pink
        case .healing: return .red
        case .forgiveness: return .purple
        case .strength: return .blue
        case .guidance: return .teal
        case .sleep: return .cyan
        case .stress: return .mint
        }
    }
}

// MARK: - Meditation Difficulty
enum MeditationDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Background Music
enum MeditationMusic: String, CaseIterable, Codable {
    case silence = "Silence"
    case nature = "Nature Sounds"
    case piano = "Soft Piano"
    case ambient = "Ambient"
    case choral = "Choral"
    case bells = "Church Bells"

    var icon: String {
        switch self {
        case .silence: return "speaker.slash"
        case .nature: return "leaf.circle"
        case .piano: return "pianokeys"
        case .ambient: return "waveform"
        case .choral: return "music.quarternote.3"
        case .bells: return "bell.fill"
        }
    }
}

// MARK: - Meditation Progress
struct MeditationProgress: Codable {
    var totalMinutes: Int = 0
    var sessionsCompleted: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var favoriteCategory: String?
    var lastSessionDate: Date?
    var weeklyGoal: Int = 30 // minutes per week
    var weeklyProgress: Int = 0

    var streakStatus: String {
        if currentStreak == 0 { return "Start your streak!" }
        if currentStreak == 1 { return "1 day streak" }
        return "\(currentStreak) day streak"
    }
}

// MARK: - Player State
enum PlayerState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case completed
}

// MARK: - Default Sessions
extension MeditationSession {
    static let defaultSessions: [MeditationSession] = [
        MeditationSession(
            title: "Morning Gratitude",
            description: "Start your day with thankfulness and praise to God.",
            duration: 5,
            category: .morning,
            difficulty: .beginner,
            scriptText: """
            Welcome to this morning gratitude prayer. Find a comfortable position and close your eyes.

            Take a deep breath in... and slowly exhale. Feel God's presence surrounding you.

            As we begin this new day, let us give thanks to our Heavenly Father.

            Lord, thank You for this new day You have given me. Thank You for the breath in my lungs and the beating of my heart.

            I am grateful for Your love that never fails, Your mercy that is new every morning.

            Help me to see Your blessings throughout this day. Open my eyes to the beauty around me.

            Guide my steps today. Let my words bring glory to You and encouragement to others.

            I surrender this day to You, knowing that You hold my future in Your loving hands.

            In Jesus' name, Amen.
            """,
            backgroundMusic: .piano,
            iconName: "sun.horizon.fill"
        ),
        MeditationSession(
            title: "Evening Peace",
            description: "Release the worries of the day and rest in God's peace.",
            duration: 10,
            category: .evening,
            difficulty: .beginner,
            scriptText: """
            As the day comes to an end, let us find peace in God's presence.

            Take a slow, deep breath. Release any tension you're holding.

            Lord, thank You for walking with me through this day. You have been faithful in every moment.

            I release my worries to You now. Every concern, every anxiety, I lay at Your feet.

            Your Word says, "Cast all your anxiety on Him because He cares for you."

            I trust in Your care tonight. Guard my mind and heart as I rest.

            Fill me with Your perfect peace that surpasses all understanding.

            May Your angels watch over me through the night.

            I rest in Your everlasting arms. Goodnight, Lord.

            In Jesus' name, Amen.
            """,
            backgroundMusic: .ambient,
            iconName: "moon.stars.fill"
        ),
        MeditationSession(
            title: "Finding Inner Peace",
            description: "Calm your spirit and find peace in God's presence.",
            duration: 15,
            category: .peace,
            difficulty: .intermediate,
            scriptText: """
            Welcome. Today we seek the peace that only God can give.

            Settle into stillness. Let your breathing slow and deepen.

            Jesus said, "Peace I leave with you; my peace I give you. I do not give as the world gives."

            Breathe in God's peace... breathe out your anxiety.

            Picture yourself by still waters, as described in Psalm 23.

            The Lord is your shepherd. You lack nothing.

            He leads you beside quiet waters. He refreshes your soul.

            Even when you walk through the darkest valley, you will fear no evil, for He is with you.

            His rod and staff, they comfort you.

            Rest in this truth. You are safe. You are loved. You are at peace.

            Carry this peace with you as you return to your day.

            In Jesus' name, Amen.
            """,
            backgroundMusic: .nature,
            iconName: "leaf.fill"
        ),
        MeditationSession(
            title: "Healing Prayer",
            description: "Invite God's healing presence into your body, mind, and spirit.",
            duration: 12,
            category: .healing,
            difficulty: .intermediate,
            scriptText: """
            Heavenly Father, we come before You seeking Your healing touch.

            You are the Great Physician, the One who heals all our diseases.

            By Your stripes, we are healed. This is Your promise to us.

            I invite Your healing presence into every part of my being.

            Heal my body where there is pain or illness.

            Heal my mind where there is confusion or worry.

            Heal my heart where there is brokenness or grief.

            Heal my spirit where there is doubt or despair.

            Lord, I trust in Your timing and Your ways.

            Whether healing comes instantly or gradually, I believe You are working.

            I declare Your goodness over my life. I receive Your healing love.

            In Jesus' mighty name, Amen.
            """,
            backgroundMusic: .choral,
            iconName: "cross.fill"
        ),
        MeditationSession(
            title: "Strength for Today",
            description: "Draw courage and strength from the Lord.",
            duration: 8,
            category: .strength,
            difficulty: .beginner,
            scriptText: """
            The Lord is your strength and your shield. Draw near to Him now.

            Isaiah 40:31 says, "Those who hope in the Lord will renew their strength."

            Feel God's power flowing into you with each breath.

            You are not alone in your struggles. The Almighty God stands with you.

            He will give you strength for every challenge you face today.

            Be strong and courageous. Do not be afraid, for the Lord your God goes with you.

            He will never leave you nor forsake you.

            Rise up in His strength. You can do all things through Christ who strengthens you.

            Go forth in confidence, knowing that greater is He who is in you than he who is in the world.

            In Jesus' name, Amen.
            """,
            backgroundMusic: .bells,
            iconName: "bolt.fill"
        )
    ]
}

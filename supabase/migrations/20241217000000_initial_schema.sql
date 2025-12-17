-- WePray Database Schema
-- Migration: Initial Schema
-- Created: 2024-12-17

-- Note: gen_random_uuid() is built into Postgres 13+ (used by Supabase)

-- ENUMS

CREATE TYPE prayer_frequency AS ENUM ('daily', 'weekly', 'custom');
CREATE TYPE prayer_theme AS ENUM ('gratitude', 'healing', 'forgiveness', 'guidance', 'peace', 'strength', 'family', 'protection');
CREATE TYPE journal_mood AS ENUM ('grateful', 'peaceful', 'hopeful', 'joyful', 'reflective', 'anxious', 'struggling', 'seeking');
CREATE TYPE journal_tag AS ENUM ('prayer', 'praise', 'confession', 'thanksgiving', 'intercession', 'worship', 'healing', 'guidance');
CREATE TYPE prayer_request_category AS ENUM ('health', 'family', 'relationships', 'financial', 'career', 'spiritual', 'grief', 'anxiety', 'guidance', 'thanksgiving', 'other');
CREATE TYPE prayer_urgency AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE prayer_warrior_level AS ENUM ('beginner', 'faithful', 'devoted', 'warrior', 'intercessor');
CREATE TYPE meditation_category AS ENUM ('morning', 'evening', 'peace', 'gratitude', 'healing', 'forgiveness', 'strength', 'guidance', 'sleep', 'stress');
CREATE TYPE meditation_difficulty AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE meditation_music AS ENUM ('silence', 'nature', 'piano', 'ambient', 'choral', 'bells');
CREATE TYPE devotional_category AS ENUM ('faith', 'hope', 'love', 'peace', 'wisdom', 'strength', 'gratitude', 'forgiveness', 'purpose', 'prayer');
CREATE TYPE plan_category AS ENUM ('beginner', 'gospels', 'psalms', 'newTestament', 'oldTestament', 'wholeBible', 'topical', 'seasonal');
CREATE TYPE verse_category AS ENUM ('faith', 'hope', 'love', 'peace', 'strength', 'wisdom', 'comfort', 'salvation', 'praise', 'guidance');
CREATE TYPE verse_difficulty AS ENUM ('easy', 'medium', 'hard');
CREATE TYPE mastery_level AS ENUM ('new', 'learning', 'familiar', 'confident', 'mastered');
CREATE TYPE circle_category AS ENUM ('family', 'healing', 'career', 'relationships', 'faith', 'community', 'youth', 'seniors', 'missions', 'gratitude');
CREATE TYPE recurrence_type AS ENUM ('daily', 'weekly', 'biweekly', 'monthly');
CREATE TYPE request_status AS ENUM ('active', 'answered', 'ongoing');
CREATE TYPE member_role AS ENUM ('leader', 'moderator', 'member');
CREATE TYPE subscription_tier AS ENUM ('free', 'standard', 'premium');
CREATE TYPE subscription_status AS ENUM ('active', 'inactive', 'trialing', 'canceled', 'past_due');
CREATE TYPE ai_service_type AS ENUM ('openai', 'claude', 'deepseek');
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'premium', 'user');

-- TABLES

-- Languages
CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    native_name TEXT NOT NULL,
    flag TEXT,
    is_custom BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Christian Denominations
CREATE TABLE christian_denominations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    is_custom BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Profiles (linked to Supabase Auth)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    language_id UUID REFERENCES languages(id),
    denomination_id UUID REFERENCES christian_denominations(id),
    role user_role DEFAULT 'user',
    is_admin BOOLEAN DEFAULT FALSE,
    preferred_voice TEXT DEFAULT 'nova',
    playback_speed REAL DEFAULT 1.0,
    realtime_voice_enabled BOOLEAN DEFAULT FALSE,
    prayer_friend_name TEXT DEFAULT 'Prayer Friend',
    avatar_url TEXT,
    bio TEXT,
    about_me TEXT,
    skills TEXT[],
    profession TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat Messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_from_user BOOLEAN NOT NULL,
    audio_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Featured Prayers
CREATE TABLE featured_prayers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    prayer_text TEXT NOT NULL,
    denomination TEXT,
    icon_name TEXT,
    gradient_colors TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Articles
CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    gradient_colors TEXT[],
    link TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scripture Verses
CREATE TABLE scripture_verses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book TEXT NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    text TEXT NOT NULL,
    version TEXT NOT NULL DEFAULT 'ESV',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(book, chapter, verse, version)
);

-- Prayer Plans
CREATE TABLE prayer_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    themes prayer_theme[],
    frequency prayer_frequency DEFAULT 'daily',
    duration_days INTEGER NOT NULL,
    prayers_per_day INTEGER DEFAULT 1,
    start_date DATE NOT NULL,
    completed_days DATE[] DEFAULT '{}',
    is_shared BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journal Entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    verse_id UUID REFERENCES scripture_verses(id),
    reflection TEXT,
    prayer TEXT,
    gratitude TEXT,
    growth_rating INTEGER CHECK (growth_rating >= 1 AND growth_rating <= 5),
    mood journal_mood,
    tags journal_tag[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prayer Requests
CREATE TABLE prayer_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    title TEXT NOT NULL,
    description TEXT,
    category prayer_request_category DEFAULT 'other',
    urgency prayer_urgency DEFAULT 'medium',
    prayer_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    expires_at TIMESTAMPTZ,
    is_answered BOOLEAN DEFAULT FALSE,
    answered_at TIMESTAMPTZ,
    testimony_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prayer Responses (encouragement messages)
CREATE TABLE prayer_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES prayer_requests(id) ON DELETE CASCADE,
    author_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users who prayed for requests
CREATE TABLE prayer_request_prayers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES prayer_requests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(request_id, user_id)
);

-- Meditation Sessions (template)
CREATE TABLE meditation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER NOT NULL,
    category meditation_category,
    difficulty meditation_difficulty DEFAULT 'beginner',
    script_text TEXT,
    background_music meditation_music DEFAULT 'silence',
    icon_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Meditation Progress
CREATE TABLE user_meditation_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES meditation_sessions(id) ON DELETE CASCADE,
    is_favorite BOOLEAN DEFAULT FALSE,
    completion_count INTEGER DEFAULT 0,
    last_completed TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, session_id)
);

-- Daily Devotionals
CREATE TABLE daily_devotionals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    devotional_date DATE NOT NULL,
    scripture_book TEXT NOT NULL,
    scripture_chapter INTEGER NOT NULL,
    scripture_verse_start INTEGER NOT NULL,
    scripture_verse_end INTEGER,
    scripture_text TEXT NOT NULL,
    reflection TEXT,
    prayer TEXT,
    application TEXT,
    author TEXT,
    category devotional_category,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Devotional Progress
CREATE TABLE user_devotional_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    devotional_id UUID NOT NULL REFERENCES daily_devotionals(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, devotional_id)
);

-- Reading Plans
CREATE TABLE reading_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    duration_days INTEGER NOT NULL,
    category plan_category,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading Plan Readings
CREATE TABLE reading_plan_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES reading_plans(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    passages JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Reading Plan Progress
CREATE TABLE user_reading_plan_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES reading_plans(id) ON DELETE CASCADE,
    start_date DATE,
    current_day INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT FALSE,
    completed_readings UUID[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, plan_id)
);

-- Memory Verses
CREATE TABLE memory_verses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    reference TEXT NOT NULL,
    text TEXT NOT NULL,
    translation TEXT DEFAULT 'NIV',
    category verse_category,
    difficulty verse_difficulty DEFAULT 'medium',
    date_added DATE DEFAULT CURRENT_DATE,
    last_reviewed DATE,
    next_review DATE,
    review_count INTEGER DEFAULT 0,
    correct_count INTEGER DEFAULT 0,
    mastery_level mastery_level DEFAULT 'new',
    is_favorite BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prayer Circles
CREATE TABLE prayer_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category circle_category,
    icon_name TEXT,
    gradient_colors TEXT[],
    is_private BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Circle Members
CREATE TABLE circle_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES prayer_circles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    prayer_count INTEGER DEFAULT 0,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(circle_id, user_id)
);

-- Circle Meetings
CREATE TABLE circle_meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES prayer_circles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    scheduled_date TIMESTAMPTZ NOT NULL,
    duration INTEGER DEFAULT 30,
    meeting_link TEXT,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_type recurrence_type,
    host_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Circle Meeting Attendees
CREATE TABLE circle_meeting_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID NOT NULL REFERENCES circle_meetings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(meeting_id, user_id)
);

-- Circle Prayer Requests
CREATE TABLE circle_prayer_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES prayer_circles(id) ON DELETE CASCADE,
    author_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    content TEXT NOT NULL,
    status request_status DEFAULT 'active',
    prayer_count INTEGER DEFAULT 0,
    is_urgent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    tier subscription_tier DEFAULT 'free',
    status subscription_status DEFAULT 'active',
    start_date DATE,
    end_date DATE,
    stripe_customer_id TEXT,
    stripe_subscription_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Admin Settings
CREATE TABLE admin_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Follows
CREATE TABLE user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);

-- Feed Posts
CREATE TABLE feed_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feed Post Likes
CREATE TABLE feed_post_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES feed_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Groups
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    gradient_colors TEXT[],
    is_private BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Group Members
CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(group_id, user_id)
);

-- INDEXES

CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX idx_prayer_plans_user_id ON prayer_plans(user_id);
CREATE INDEX idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX idx_journal_entries_date ON journal_entries(entry_date DESC);
CREATE INDEX idx_prayer_requests_author_id ON prayer_requests(author_id);
CREATE INDEX idx_prayer_requests_created_at ON prayer_requests(created_at DESC);
CREATE INDEX idx_prayer_requests_category ON prayer_requests(category);
CREATE INDEX idx_prayer_responses_request_id ON prayer_responses(request_id);
CREATE INDEX idx_meditation_sessions_category ON meditation_sessions(category);
CREATE INDEX idx_daily_devotionals_date ON daily_devotionals(devotional_date DESC);
CREATE INDEX idx_memory_verses_user_id ON memory_verses(user_id);
CREATE INDEX idx_memory_verses_next_review ON memory_verses(next_review);
CREATE INDEX idx_prayer_circles_category ON prayer_circles(category);
CREATE INDEX idx_circle_members_circle_id ON circle_members(circle_id);
CREATE INDEX idx_circle_members_user_id ON circle_members(user_id);
CREATE INDEX idx_circle_meetings_circle_id ON circle_meetings(circle_id);
CREATE INDEX idx_circle_meetings_scheduled ON circle_meetings(scheduled_date);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_feed_posts_user_id ON feed_posts(user_id);
CREATE INDEX idx_feed_posts_created_at ON feed_posts(created_at DESC);
CREATE INDEX idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following ON user_follows(following_id);

-- ROW LEVEL SECURITY (RLS)

-- User Profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view all profiles" ON user_profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Chat Messages
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own messages" ON chat_messages FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own messages" ON chat_messages FOR DELETE USING (auth.uid() = user_id);

-- Prayer Plans
ALTER TABLE prayer_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own and shared plans" ON prayer_plans FOR SELECT USING (auth.uid() = user_id OR is_shared = true);
CREATE POLICY "Users can insert own plans" ON prayer_plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own plans" ON prayer_plans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own plans" ON prayer_plans FOR DELETE USING (auth.uid() = user_id);

-- Journal Entries
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own entries" ON journal_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own entries" ON journal_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own entries" ON journal_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own entries" ON journal_entries FOR DELETE USING (auth.uid() = user_id);

-- Prayer Requests (public by default)
ALTER TABLE prayer_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view non-anonymous requests" ON prayer_requests FOR SELECT USING (true);
CREATE POLICY "Users can insert requests" ON prayer_requests FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Authors can update own requests" ON prayer_requests FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Authors can delete own requests" ON prayer_requests FOR DELETE USING (auth.uid() = author_id);

-- Memory Verses
ALTER TABLE memory_verses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own verses" ON memory_verses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own verses" ON memory_verses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own verses" ON memory_verses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own verses" ON memory_verses FOR DELETE USING (auth.uid() = user_id);

-- Subscriptions
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own subscription" ON subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own subscription" ON subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own subscription" ON subscriptions FOR UPDATE USING (auth.uid() = user_id);

-- Public tables (no RLS needed, all can view)
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view languages" ON languages FOR SELECT USING (true);

ALTER TABLE christian_denominations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view denominations" ON christian_denominations FOR SELECT USING (true);

ALTER TABLE featured_prayers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active prayers" ON featured_prayers FOR SELECT USING (is_active = true);

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active articles" ON articles FOR SELECT USING (is_active = true);

ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view sessions" ON meditation_sessions FOR SELECT USING (true);

ALTER TABLE daily_devotionals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view devotionals" ON daily_devotionals FOR SELECT USING (true);

ALTER TABLE reading_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view plans" ON reading_plans FOR SELECT USING (true);

ALTER TABLE scripture_verses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view verses" ON scripture_verses FOR SELECT USING (true);

-- FUNCTIONS

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_prayer_plans_updated_at BEFORE UPDATE ON prayer_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_journal_entries_updated_at BEFORE UPDATE ON journal_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_prayer_requests_updated_at BEFORE UPDATE ON prayer_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_memory_verses_updated_at BEFORE UPDATE ON memory_verses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_feed_posts_updated_at BEFORE UPDATE ON feed_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Increment prayer count function
CREATE OR REPLACE FUNCTION increment_prayer_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE prayer_requests SET prayer_count = prayer_count + 1 WHERE id = NEW.request_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER increment_prayer_request_count AFTER INSERT ON prayer_request_prayers FOR EACH ROW EXECUTE FUNCTION increment_prayer_count();

-- Auto-promote first 2 users to admin
CREATE OR REPLACE FUNCTION promote_first_users()
RETURNS TRIGGER AS $$
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM user_profiles;

  IF user_count <= 2 THEN
    NEW.role = 'admin';
    NEW.is_admin = TRUE;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER promote_first_users_trigger
BEFORE INSERT ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION promote_first_users();

-- Get total users count
CREATE OR REPLACE FUNCTION get_total_users()
RETURNS INTEGER AS $$
DECLARE
  total_users INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_users FROM user_profiles;
  RETURN total_users;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has specific role
CREATE OR REPLACE FUNCTION user_has_role(check_user_id UUID, check_role user_role)
RETURNS BOOLEAN AS $$
DECLARE
  has_role BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM user_profiles WHERE id = check_user_id AND role = check_role) INTO has_role;
  RETURN has_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is admin or super_admin
CREATE OR REPLACE FUNCTION is_admin_user(check_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  is_admin BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM user_profiles WHERE id = check_user_id AND role IN ('admin', 'super_admin')) INTO is_admin;
  RETURN is_admin;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SEED DATA

-- Insert default languages
INSERT INTO languages (code, name, native_name, flag, is_custom) VALUES
('pt-BR', 'Brazilian Portuguese', 'Português Brasileiro', '🇧🇷', false),
('zh', 'Chinese', '中文', '🇨🇳', false),
('en', 'English', 'English', '🇺🇸', false),
('fr', 'French', 'Français', '🇫🇷', false),
('ru', 'Russian', 'Русский', '🇷🇺', false),
('es', 'Spanish', 'Español', '🇪🇸', false);

-- Insert default denominations
INSERT INTO christian_denominations (name, description, is_custom) VALUES
('Anglican', 'Anglican/Episcopal tradition', false),
('Baptist', 'Baptist tradition', false),
('Catholic', 'Roman Catholic tradition', false),
('Lutheran', 'Lutheran tradition', false),
('Methodist', 'Methodist/Wesleyan tradition', false),
('Non-denominational', 'Non-denominational Protestant', false),
('Orthodox', 'Eastern Orthodox tradition', false),
('Pentecostal', 'Pentecostal/Charismatic tradition', false),
('Presbyterian', 'Presbyterian/Reformed tradition', false),
('Protestant', 'General Protestant tradition', false);

-- Insert default admin settings
INSERT INTO admin_settings (key, value) VALUES
('chat_api_service', '"claude"'),
('voice_api_service', '"openai"'),
('prayer_friend_api_service', '"claude"');

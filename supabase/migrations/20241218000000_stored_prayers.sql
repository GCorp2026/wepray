-- Migration: Add stored_prayers table for AI training and denomination-specific prayers
-- Created: 2024-12-18

-- Create stored_prayers table
CREATE TABLE IF NOT EXISTS stored_prayers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    denomination VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    language VARCHAR(50) NOT NULL DEFAULT 'English',
    is_approved BOOLEAN DEFAULT false,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_stored_prayers_denomination ON stored_prayers(denomination);
CREATE INDEX IF NOT EXISTS idx_stored_prayers_language ON stored_prayers(language);
CREATE INDEX IF NOT EXISTS idx_stored_prayers_user_id ON stored_prayers(user_id);
CREATE INDEX IF NOT EXISTS idx_stored_prayers_category ON stored_prayers(category);
CREATE INDEX IF NOT EXISTS idx_stored_prayers_approved ON stored_prayers(is_approved);

-- Enable RLS
ALTER TABLE stored_prayers ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read approved prayers
CREATE POLICY "Anyone can read approved prayers" ON stored_prayers
    FOR SELECT
    USING (is_approved = true);

-- Policy: Authenticated users can read their own prayers
CREATE POLICY "Users can read own prayers" ON stored_prayers
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Authenticated users can insert prayers
CREATE POLICY "Authenticated users can insert prayers" ON stored_prayers
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Users can update their own prayers
CREATE POLICY "Users can update own prayers" ON stored_prayers
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy: Service role can manage all prayers (for admin operations)
CREATE POLICY "Service role can manage all prayers" ON stored_prayers
    FOR ALL
    USING (auth.role() = 'service_role');

-- Insert default prayers for each denomination
INSERT INTO stored_prayers (content, denomination, category, language, is_approved) VALUES
-- Catholic prayers
('Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.', 'Catholic', 'traditional', 'English', true),
('Our Father, who art in heaven, hallowed be Thy name. Thy kingdom come, Thy will be done, on earth as it is in heaven. Give us this day our daily bread, and forgive us our trespasses, as we forgive those who trespass against us. And lead us not into temptation, but deliver us from evil. Amen.', 'Catholic', 'traditional', 'English', true),
('Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.', 'Catholic', 'traditional', 'English', true),

-- Orthodox prayers
('Lord Jesus Christ, Son of God, have mercy on me, a sinner.', 'Orthodox', 'jesus_prayer', 'English', true),
('O Heavenly King, Comforter, Spirit of Truth, who art everywhere present and fillest all things, Treasury of good things and Giver of life: Come and dwell in us, and cleanse us from every stain, and save our souls, O Good One.', 'Orthodox', 'traditional', 'English', true),
('Holy God, Holy Mighty, Holy Immortal, have mercy on us.', 'Orthodox', 'trisagion', 'English', true),

-- Protestant prayers
('Dear Lord, thank You for this day. Guide my steps and fill me with Your peace. Help me to walk in Your ways and to share Your love with everyone I meet. In Jesus'' name, Amen.', 'Protestant', 'daily', 'English', true),
('Heavenly Father, I come before You with a humble heart seeking Your wisdom and guidance. Open my eyes to see Your will for my life. Grant me courage to follow where You lead. Amen.', 'Protestant', 'guidance', 'English', true),
('Lord, help me to trust in Your plan and walk in faith each day. When doubts arise, remind me of Your faithfulness. When fears come, fill me with Your peace. Amen.', 'Protestant', 'faith', 'English', true),

-- Baptist prayers
('Father God, I surrender my life to You today. Use me for Your glory. Fill me with Your Spirit and guide me in all truth. Help me to be a faithful witness of Your grace. Amen.', 'Baptist', 'surrender', 'English', true),
('Lord Jesus, thank You for saving me by Your grace through faith. Help me share Your love with others and lead them to the saving knowledge of You. Amen.', 'Baptist', 'evangelism', 'English', true),
('Dear Lord, fill me with Your Holy Spirit and guide me in truth. Give me boldness to proclaim Your gospel and compassion to serve those in need. Amen.', 'Baptist', 'spirit', 'English', true),

-- Pentecostal prayers
('Holy Spirit, fill me afresh today. Let Your fire burn within me. Ignite my passion for worship and service. Use me as a vessel for Your glory. Amen.', 'Pentecostal', 'spirit_filled', 'English', true),
('Lord, I invite Your presence to move powerfully in my life today. Let Your gifts flow through me to bless others and build Your church. Amen.', 'Pentecostal', 'gifts', 'English', true),
('Father, release Your gifts through me for the building of Your kingdom. Let signs and wonders follow those who believe. In Jesus'' mighty name, Amen.', 'Pentecostal', 'power', 'English', true),

-- Methodist prayers
('Lord, grant me the serenity to accept the things I cannot change, the courage to change the things I can, and the wisdom to know the difference. Help me to spread Your love wherever I go. Amen.', 'Methodist', 'serenity', 'English', true),
('Gracious God, form within me a heart of perfect love. Help me to love You with all my heart, soul, mind, and strength, and to love my neighbor as myself. Amen.', 'Methodist', 'love', 'English', true),

-- Presbyterian prayers
('Sovereign Lord, I acknowledge Your supreme authority over all creation. Grant me humility to submit to Your will and wisdom to discern Your purposes. Amen.', 'Presbyterian', 'sovereignty', 'English', true),
('Eternal God, You have chosen us before the foundation of the world. Help us to live worthy of our calling and to glorify You in all we do. Amen.', 'Presbyterian', 'election', 'English', true),

-- Lutheran prayers
('Almighty God, grant that I may hear Your Word and keep it. Help me to live by grace through faith, trusting in Your promises alone. Amen.', 'Lutheran', 'grace', 'English', true),
('Lord Jesus, You are my righteousness. I trust not in my works but in Your finished work on the cross. Thank You for Your free gift of salvation. Amen.', 'Lutheran', 'justification', 'English', true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_stored_prayers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_stored_prayers_updated_at
    BEFORE UPDATE ON stored_prayers
    FOR EACH ROW
    EXECUTE FUNCTION update_stored_prayers_updated_at();

-- Grant permissions
GRANT SELECT ON stored_prayers TO anon;
GRANT ALL ON stored_prayers TO authenticated;

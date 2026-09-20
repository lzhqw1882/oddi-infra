-- ============================================================================
-- 🚀 오디 (ODDI) 글로벌 PostgreSQL DDL Schema
-- 대상 DB: oddi-postgres (PostgreSQL 16/17 + PostGIS)
-- 최종 수정일: 2026-09-20 (seed.sql 및 최신 엔티티 명세 동기화)
-- ============================================================================

-- 0. 확장 플러그인 설정
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";          -- PostGIS 기본 공간 연산/함수
CREATE EXTENSION IF NOT EXISTS "postgis_topology"; -- 토폴로지 지원

-- ============================================================================
-- 1. 테이블 생성 (Tables)
-- ============================================================================

-- 1.1 일일 환율 정보 테이블 (exchange_rates) - 1 USD 기준 환율
CREATE TABLE IF NOT EXISTS public.exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    currency_code VARCHAR(10) NOT NULL UNIQUE, -- e.g., 'KRW', 'JPY', 'EUR', 'THB', 'VND', 'CNY', 'GBP'
    rate_to_usd NUMERIC(15, 6) NOT NULL,       -- 1 USD당 해당 통화 금액 (예: 1350.500000 KRW)
    currency_name VARCHAR(100) NOT NULL,       -- e.g., '대한민국 원', '일본 엔', '태국 바트'
    symbol VARCHAR(10) NOT NULL,               -- e.g., '₩', '¥', '฿', '$', '€'
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.2 사용자 프로필 테이블 (users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    avatar_url TEXT,
    kakao_social_id VARCHAR(255) UNIQUE, -- 카카오 소셜 고유 ID
    google_social_id VARCHAR(255) UNIQUE, -- 구글 소셜 고유 ID
    apple_social_id VARCHAR(255) UNIQUE,  -- 애플 소셜 고유 ID
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.3 회원 탈퇴 이력 테이블 (user_withdrawals)
CREATE TABLE IF NOT EXISTS public.user_withdrawals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    provider VARCHAR(20) NOT NULL CHECK (provider IN ('KAKAO', 'GOOGLE', 'APPLE')),
    hashed_social_id VARCHAR(255) NOT NULL,
    reason TEXT,
    withdrawn_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.4 도시 핵심 테이블 (destinations)
CREATE TABLE IF NOT EXISTS public.destinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    city_name_ko VARCHAR(100) NOT NULL,
    city_name_en VARCHAR(100) NOT NULL,
    country_name_ko VARCHAR(100) NOT NULL,
    country_code VARCHAR(10) NOT NULL,             -- ISO 2자리 국가 코드 (예: 'JP', 'TH', 'VN')
    continent VARCHAR(50) NOT NULL,                -- 대륙 구분 (예: 'Asia', 'SE_Asia', 'Europe')
    summary TEXT,                                  -- 도시 한 줄 요약/소개
    thumbnail_urls TEXT[] DEFAULT '{}',            -- 다중 썸네일 이미지 URL 배열
    safety_score INT NOT NULL DEFAULT 75,          -- 안전 점수 (1~100)
    best_months INT[] DEFAULT '{}',                -- 여행 최적 월 (예: [3, 4, 5, 10, 11])
    how_to_get_there TEXT,                         -- 공항에서 시내 가는 법 요약
    initial_revisit_rate NUMERIC(5, 2) NOT NULL DEFAULT 80.00, -- 초기 재방문 희망률 (%)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.5 세부 물가지수 테이블 (local_costs)
CREATE TABLE IF NOT EXISTS public.local_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE UNIQUE,
    cost_dining_budget INT NOT NULL DEFAULT 0,     -- 가성비 식사 비용 (KRW 환산 기준)
    cost_dining_luxury INT NOT NULL DEFAULT 0,     -- 고급 식사 비용
    cost_coffee INT NOT NULL DEFAULT 0,            -- 커피 1잔 비용
    cost_beer INT NOT NULL DEFAULT 0,              -- 맥주 1잔/캔 비용
    cost_bigmac INT NOT NULL DEFAULT 0,            -- 빅맥 세트 비용
    cost_taxi_base INT NOT NULL DEFAULT 0,         -- 택시 기본요금
    cost_taxi_per_km INT NOT NULL DEFAULT 0,       -- 택시 km당 요금
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.6 월별 숙박비 테이블 (hotel_prices - 1월~12월 3성/4성/5성 평균가)
CREATE TABLE IF NOT EXISTS public.hotel_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    price_3star INT NOT NULL DEFAULT 0,            -- 3성급 1박 평균가 (KRW)
    price_4star INT NOT NULL DEFAULT 0,            -- 4성급 1박 평균가 (KRW)
    price_5star INT NOT NULL DEFAULT 0,            -- 5성급 1박 평균가 (KRW)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT uq_hotel_prices_dest_month UNIQUE (destination_id, month)
);

-- 1.7 리뷰 및 재방문 의사(Y/N) 테이블 (reviews)
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    content TEXT NOT NULL,
    image_urls TEXT[] DEFAULT '{}',
    revisit_intent BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 1.8 찜하기 목록 테이블 (user_bookmarks)
CREATE TABLE IF NOT EXISTS public.user_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT uq_user_bookmarks UNIQUE (user_id, destination_id)
);

-- 1.9 다녀온 여행지 스탬프 및 퀵 평가 테이블 (user_visited)
CREATE TABLE IF NOT EXISTS public.user_visited (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5) DEFAULT 5,
    will_revisit BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT uq_user_visited UNIQUE (user_id, destination_id)
);

-- ============================================================================
-- 2. 성능 인덱스 (Indexes)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_exchange_rates_code ON public.exchange_rates (currency_code);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users (email);
CREATE INDEX IF NOT EXISTS idx_users_nickname ON public.users (nickname);
CREATE INDEX IF NOT EXISTS idx_users_kakao_id ON public.users (kakao_social_id);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON public.users (google_social_id);
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON public.users (apple_social_id);

CREATE INDEX IF NOT EXISTS idx_destinations_city_ko ON public.destinations (city_name_ko);
CREATE INDEX IF NOT EXISTS idx_destinations_city_en ON public.destinations (city_name_en);
CREATE INDEX IF NOT EXISTS idx_destinations_country_code ON public.destinations (country_code);
CREATE INDEX IF NOT EXISTS idx_destinations_continent ON public.destinations (continent);
CREATE INDEX IF NOT EXISTS idx_destinations_safety ON public.destinations (safety_score);

CREATE INDEX IF NOT EXISTS idx_hotel_prices_dest_month ON public.hotel_prices (destination_id, month);
CREATE INDEX IF NOT EXISTS idx_local_costs_dest ON public.local_costs (destination_id);
CREATE INDEX IF NOT EXISTS idx_reviews_dest ON public.reviews (destination_id);
CREATE INDEX IF NOT EXISTS idx_user_bookmarks_user ON public.user_bookmarks (user_id);
CREATE INDEX IF NOT EXISTS idx_user_visited_user ON public.user_visited (user_id);

-- ============================================================================
-- 3. 실시간 도시별 통계 뷰 (v_destination_stats)
-- ============================================================================

CREATE OR REPLACE VIEW public.v_destination_stats AS
SELECT 
    d.id AS destination_id,
    d.city_name_ko,
    d.city_name_en,
    d.country_name_ko,
    d.country_code,
    d.continent,
    d.safety_score,
    d.initial_revisit_rate,
    COUNT(v.id) AS total_visited_count,
    ROUND(COALESCE(AVG(v.rating), 5.0), 2) AS average_rating,
    CASE 
        WHEN COUNT(v.id) = 0 THEN d.initial_revisit_rate
        ELSE ROUND((SUM(CASE WHEN v.will_revisit THEN 1 ELSE 0 END)::NUMERIC / COUNT(v.id)) * 100, 2)
    END AS live_revisit_rate_percent,
    (SELECT COUNT(*) FROM public.user_bookmarks b WHERE b.destination_id = d.id) AS bookmark_count
FROM public.destinations d
LEFT JOIN public.user_visited v ON d.id = v.destination_id
GROUP BY d.id;

-- ============================================================================
-- 4. Updated_at 자동 갱신 트리거
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_exchange_rates_updated_at BEFORE UPDATE ON public.exchange_rates FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER tr_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER tr_destinations_updated_at BEFORE UPDATE ON public.destinations FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER tr_hotel_prices_updated_at BEFORE UPDATE ON public.hotel_prices FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER tr_local_costs_updated_at BEFORE UPDATE ON public.local_costs FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER tr_reviews_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

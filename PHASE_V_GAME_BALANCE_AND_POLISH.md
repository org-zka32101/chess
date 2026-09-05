# PHASE V: GAME BALANCE & POLISH

**Phase Status**: Gameplay Refinement  
**Start Date**: 2026-10-16  
**Target Completion**: 2026-11-20  
**Duration**: 5 weeks  
**Effort Level**: Medium-High  
**Owner**: Game Design & Product  
**Stakeholders**: Engineering, Analytics, Content, Creator Operations

---

## Executive Summary

Following resolution of critical issues (Phase T) and major balance problems (Phase U), Phase V addresses the 8 game balance and polish issues that impact gameplay experience, creator satisfaction, and marketplace health. These are not fatal issues but significantly improve product quality and player/creator retention.

**Phase Objective**: Polish game mechanics, balance creator economics, and improve marketplace health to deliver a cohesive, engaging product experience at launch.

**Success Criteria**:
- ✅ Difficulty curve smoothed (no mid-range gaps, balanced progression)
- ✅ PPP pricing implemented for emerging markets (coaching accessible globally)
- ✅ Achievement system narrativized (progression story, not random badges)
- ✅ Booking timezone support implemented (coaches & players matched by availability)
- ✅ Anti-sandbagging system deployed (tournament fairness)
- ✅ Creator revenue cliffs smoothed (gradual tier transitions)
- ✅ Churn intervention system automated (reactivation campaigns)
- ✅ Marketplace duplicate/spam content flagged (quality control)

---

## GAME BALANCE ISSUE #1: DIFFICULTY CURVE TOO STEEP

### Problem Statement

Current ELO range: 100-2600 (26 tiers × ~100-point steps)

**Issues Identified**:
- **Mid-range gaps**: Few puzzles 400-800 ELO (beginner→intermediate transition)
- **Expert crowding**: 2000-2600 ELO clustered in narrow range (1K puzzles vs 5K for 1000-1500)
- **Progression alienation**: New players jump from 300 to 500 (too steep, discouraging)
- **Top player scarcity**: 2500+ ELO has <50 puzzles (insufficient challenge for elite)

**Impact**:
- Beginner retention: Players frustrated by difficulty jumps
- Expert engagement: Elite players bored (lack content at peak level)
- Creator confusion: "What ELO rating should my puzzle be?" (unclear tiers)
- Recommendation engine: Can't find well-matched puzzles for fringe ELOs

### Root Cause Analysis

1. **Linear ELO scale** (100-point steps) doesn't match puzzle distribution
2. **Creator focus on popular range** (1000-2000 ELO has most puzzles)
3. **No explicit guidance** for puzzles outside main range
4. **No difficulty interpolation** (no mid-level puzzles between extremes)

### Remediation Plan

#### Step 1: Redefine Difficulty Scale (Week 1)

**Action**: Create finer-grained difficulty spectrum with smoother progression.

**New ELO Scale (Finer-Grained)**:

```
Current: 26 tiers (100-point steps) = 100, 200, 300, ..., 2600
Problem: Some tiers have 0-50 puzzles, others 1000+

Proposed: 52 tiers (50-point steps) = 100, 150, 200, ..., 2600
Benefit: Finer progression, more balanced distribution

Example - Beginner Progression:
Current: 100 → 200 → 300 (big jumps)
Proposed: 100 → 150 → 200 → 250 → 300 (smaller steps, gradual)

Example - Expert Range:
Current: 2200 → 2300 → 2400 → 2500 → 2600 (only 5 levels)
Proposed: 2200 → 2225 → 2250 → 2275 → 2300 → ... → 2600 (16 levels)
```

**Implementation**:
- Recalibrate all 12K existing puzzles to new 50-point scale
- New puzzles automatically assigned to 50-point tiers
- Player ratings updated to 50-point scale (1523 instead of 1500)
- Recommendation engine updated for finer targeting

#### Step 2: Balance Puzzle Distribution (Week 1-2)

**Action**: Audit and rebalance puzzles across difficulty tiers.

**Target Distribution**:

```
Tier Size (50-point steps) = (Peak tiers / tier) × 100 puzzles minimum

Current Distribution Problem:
- 1000-1500 ELO: 6000 puzzles (high supply)
- 600-900 ELO: 1000 puzzles (supply shortage)
- 2400+ ELO: 50 puzzles (supply shortage)

Target Distribution (Balanced):
- Tier 100-150: 200 puzzles (beginner intro)
- Tier 150-200: 300 puzzles (ramping up)
- Tier 200-250: 400 puzzles
- Tier 250-300: 500 puzzles
- ...
- Tier 1000-1050: 600 puzzles (mainstream, but not oversupplied)
- ...
- Tier 2400-2450: 300 puzzles (elite content, high quality)
- Tier 2450-2500: 250 puzzles
- Tier 2500-2550: 200 puzzles
- Tier 2550-2600: 150 puzzles (ultra-elite)

Total target: 50K+ puzzles (balanced across all tiers)
```

**Rebalancing Process**:
1. Audit existing 12K puzzles, assign to 50-point tiers
2. Identify underrepresented tiers (<200 puzzles)
3. Commission new puzzles for gaps (via creator program)
4. Promote underplayed puzzles from crowded tiers to fill gaps
5. Monitor distribution monthly, adjust creator incentives

#### Step 3: Implement Difficulty Interpolation (Week 2-3)

**Action**: Create smooth difficulty transitions for players crossing tier boundaries.

**Difficulty Interpolation System**:

```
Player rated 1523 ELO solving puzzles:

Recommended mix (Vygotsky Zone of Proximal Development):
- 40%: Puzzles at current level (1500-1550) - confidence
- 40%: Puzzles slightly above (1550-1600) - challenge
- 20%: Puzzles well above (1650-1750) - stretch

If no puzzles at exact level, interpolate:
- Player 1523 solves puzzle rated "1500-1550" (average 1525)
- System treats as +2 difficulty adjustment
- Recalibrates expected success rate

Benefit: Smooth progression, no cliff jumps
```

**Algorithm**:
1. Calculate player's percentile in current ELO bracket
2. Recommend next-tier puzzles if approaching top 20% (moving up)
3. Recommend previous-tier puzzles if approaching bottom 20% (moving down)
4. Mix current/above/below tiers to avoid jarring jumps

#### Step 4: Create Tier Naming System (Week 3)

**Action**: Add intuitive names to difficulty levels for creator/player clarity.

**Tier Names** (replacing raw ELO numbers):

```
ELO 100-300: Beginner
  100-150: Beginner I (first steps)
  150-200: Beginner II
  200-250: Beginner III
  250-300: Beginner IV (ready for intermediate)

ELO 300-600: Intermediate
  300-350: Intermediate I
  350-400: Intermediate II
  400-500: Intermediate III
  500-600: Intermediate IV (ready for advanced)

ELO 600-1000: Advanced
  600-700: Advanced I
  700-800: Advanced II
  800-900: Advanced III
  900-1000: Advanced IV

ELO 1000-1500: Expert
  1000-1200: Expert I
  1200-1300: Expert II
  1300-1400: Expert III
  1400-1500: Expert IV

ELO 1500-2000: Master
  1500-1650: Master I
  1650-1800: Master II
  1800-1950: Master III
  1950-2000: Master IV

ELO 2000-2400: Grandmaster
  2000-2100: GM I
  2100-2250: GM II
  2250-2350: GM III
  2350-2400: GM IV

ELO 2400-2600: Super-GM
  2400-2500: Super-GM I
  2500-2600: Super-GM II
```

**Creator Benefit**: "I want to create a Master II puzzle" (1650-1800 ELO) is clearer than "Create a puzzle rated 1725 on the 50-point scale."

#### Success Metrics

- [ ] Difficulty scale refined to 50-point steps (52 tiers total)
- [ ] Puzzle distribution rebalanced (minimum 200 per tier)
- [ ] Difficulty interpolation algorithm implemented
- [ ] Tier naming system deployed
- [ ] Zero cliff jumps (no ELO tier with 0 puzzles)
- [ ] Player progression smooth (no sudden frustration spikes)

### Owner & Timeline

**Owner**: Game Design + Analytics  
**Timeline**: Week 1-4 (4 weeks)  
**Validation Gate**: Pilot cohort shows smooth progression (no sudden churn)

---

## GAME BALANCE ISSUE #2: COACHING PRICING TOO LOW FOR EMERGING MARKETS

### Problem Statement

Global coaching pricing: $30-150/hour (same for all regions)

**Problem**: 
- USA: $50/hour is reasonable (median wage ~$25/hour, coaches earn 2x)
- India: $50/hour is $600/month (median wage $5K/year, unaffordable)
- Brazil: $50/hour is $4K/month (median wage ~$800/month, 5x unaffordable)
- Nigeria: $50/hour is unimaginable

**Impact**:
- No affordable coaching in emerging markets (geographic bias)
- Underrepresentation of coaches from low-wage countries
- Players in India/Brazil can't afford coaching (retention impact)
- Creator earnings inequality (coaches in developed markets earn more per capita)

### Root Cause Analysis

1. **USD-denominated pricing** (assumes global affordability)
2. **No PPP adjustment** (didn't account for purchasing power parity)
3. **Payment processing costs** (high in developing countries)
4. **No regional variation** (ignored economic differences by country)

### Remediation Plan

#### Step 1: Implement PPP Pricing (Week 1)

**Action**: Adjust coaching prices based on Purchasing Power Parity by country/region.

**PPP Adjustment Model**:

```
PPP Index (relative to USA = 1.0):
- USA: 1.0
- Canada: 0.95
- UK: 0.85
- Germany: 0.75
- Japan: 0.65
- Mexico: 0.45
- Brazil: 0.35
- India: 0.15
- Nigeria: 0.10
- Philippines: 0.12

Global Base Price: $50/hour (Emerging Coach tier)

PPP-Adjusted Prices:
- USA: $50 × 1.0 = $50/hour
- Canada: $50 × 0.95 = $47.50/hour
- Brazil: $50 × 0.35 = $17.50/hour
- India: $50 × 0.15 = $7.50/hour
- Nigeria: $50 × 0.10 = $5/hour

Revenue Impact (CTM gets 30%):
- USA $50 coach: CTM gets $15/hour
- Brazil $17.50 coach: CTM gets $5.25/hour
- India $7.50 coach: CTM gets $2.25/hour

Total revenue per coach (25 sessions/week × 50 weeks):
- USA: $15 × 25 × 50 = $18,750/year
- Brazil: $5.25 × 25 × 50 = $6,562/year
- India: $2.25 × 25 × 50 = $2,812/year

Coach Annual Income (net):
- USA: $35 × 25 × 50 = $43,750/year ✅
- Brazil: $12.25 × 25 × 50 = $15,312/year ✅ (fair for Brazil)
- India: $5.25 × 25 × 50 = $6,562/year ✅ (fair for India)
```

**Implementation**:
1. Detect user location via IP + player profile
2. Apply PPP multiplier to displayed prices
3. Coach can see both local + USD prices
4. Payment processor handles multi-currency conversion

#### Step 2: Address Payment Processing Costs (Week 1-2)

**Action**: Add payment processor fee subsidy for low-income countries.

**Payment Processing Costs by Region**:
```
USA/Europe: Stripe 2.2% + $0.30 = ~2.5% effective
India: Razorpay 2% + 10 INR = ~3% effective (higher)
Brazil: Wise 1.5% + 1 BRL = ~2% effective
Nigeria: Flutterwave 1.5% + 50 NGN = ~2.5% effective
```

**Fee Subsidy Model**:
- CTM eats extra 0.5-1% processing fee for emerging markets
- Coaches in India/Nigeria get 30% split instead of 25%
- Example: Coach in India keeps $7.50 × 35% = $2.62/hour (not $2.25)

**Budget Impact**: ~$20K/year subsidy for processing fees (acceptable at scale)

#### Step 3: Create Regional Creator Tiers (Week 2)

**Action**: Define creator earnings by region (not global cookie-cutter).

**Tier Examples by Country**:

```
INDIA COACHING TIERS:
- Emerging (2000 rating): ₹250/hour ($3 USD), CTM 35%
- Established (2200+ rating): ₹400/hour ($4.80 USD), CTM 30%
- Expert (2400+ rating): ₹600/hour ($7.20 USD), CTM 25%

BRAZIL COACHING TIERS:
- Emerging: R$85/hour ($17 USD), CTM 30%
- Established: R$130/hour ($26 USD), CTM 27%
- Expert: R$200/hour ($40 USD), CTM 25%

USA COACHING TIERS (unchanged):
- Emerging: $35-40/hour, CTM 30%
- Established: $50-65/hour, CTM 27%
- Expert: $75-100/hour, CTM 25%
```

**Creator Benefit**: Transparent, fair earnings in local currency

#### Step 4: Market Expansion Strategy (Week 3-4)

**Action**: Proactively recruit coaches in emerging markets.

**Recruitment Channels by Region**:
1. **India**: ChessBomb, Indian chess federations, chess.com Indian community
2. **Brazil**: Brazilian Chess Federation, Portuguese YouTube creators
3. **Nigeria/Africa**: Africa Chess Union, Lagos chess clubs
4. **Philippines**: Chess.ph, Manila chess community

**Incentive Program**:
- Sign-up bonus: First 3 coaches from new country get $100 bonus
- Referral: Coach refers friend, both get $25 bonus
- Marketing: Featured as "Rising Star Coach from [Country]"
- Mentorship: Pair new coach with experienced coach (30-min free session)

#### Step 5: Monitor Regional Health (Week 4-5)

**Action**: Track metrics by region to ensure fair economics.

**Regional Metrics Dashboard**:
- Coaches per 100K players (target: 1-2 globally)
- Average coach earnings (target: 2-3x median wage)
- Player access to coaching (% who can afford)
- Retention by region (churn should be regional-agnostic)
- Growth rate (emerging markets should grow faster)

#### Success Metrics

- [ ] PPP pricing implemented for 20+ countries
- [ ] Emerging market coaching prices 50-70% lower than USA
- [ ] Payment processing subsidies deployed (extra 0.5-1%)
- [ ] Regional creator tiers defined by country
- [ ] 50+ coaches recruited from emerging markets
- [ ] Coach earnings fair by regional standards (2-3x median wage)
- [ ] Geographic diversity: 30%+ of coaches from emerging markets

### Owner & Timeline

**Owner**: Creator Operations + Finance  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: Coach feedback survey shows fairness perception > 80%

---

## GAME BALANCE ISSUE #3: ACHIEVEMENT SYSTEM LACKS PROGRESSION NARRATIVE

### Problem Statement

Current achievement ideas scattered across phases:
- "Solve 100 puzzles" (arbitrary number)
- "Reach 1500 ELO" (abstract milestone)
- "Win 3 tournaments" (no progression)

**Problem**:
- Random badges feel unmotivating
- No story arc (beginner → intermediate → master)
- No sense of progression (each achievement independent)
- Created confusion (what does "Solve 100 puzzles" really mean?)

**Impact**:
- Players don't know what to work toward
- Engagement plateau (no clear next challenge)
- Retention drops (after reaching arbitrary milestones, what's next?)

### Root Cause Analysis

1. **No achievement hierarchy** (didn't design progression path)
2. **Random thresholds** (100 puzzles, 1500 ELO unrelated)
3. **No narrative** (achievements not part of story)
4. **Weak rewards** (badges + bragging rights, not enough motivation)

### Remediation Plan

#### Step 1: Design Achievement Narrative (Week 1)

**Action**: Create story arc for player progression through achievements.

**Achievement Narrative**:

```
CHAPTER 1: BEGINNING YOUR JOURNEY (Beginner tier)
- Milestone 1: "First Puzzle" - Solve your first puzzle
- Milestone 2: "Persistent" - Solve 10 puzzles in a week
- Milestone 3: "Tactician" - Solve 50 puzzles
- Milestone 4: "Ready to Learn" - Reach Beginner IV (300 ELO)
- Story: You learn the basics, tackle simple tactics, pass beginner threshold

CHAPTER 2: INTERMEDIATE MASTERY (Intermediate tier)
- Milestone 1: "Intermediate Path" - Solve 10 Intermediate puzzles
- Milestone 2: "Tactic Expert" - Solve 100 intermediate puzzles
- Milestone 3: "Strategist" - Solve 5 puzzles per day for 7 days
- Milestone 4: "Advanced Seeker" - Reach Intermediate IV (600 ELO)
- Story: You tackle progressively harder puzzles, build pattern recognition

CHAPTER 3: ADVANCED TECHNIQUES (Advanced tier)
- Milestone 1: "Complex Patterns" - Solve 50 Advanced puzzles
- Milestone 2: "Endgame Master" - Solve 20 endgame puzzles
- Milestone 3: "Opening Brilliance" - Solve 20 opening puzzles
- Milestone 4: "Expert Threshold" - Reach Advanced IV (1000 ELO)
- Story: You specialize, learn different game phases, reach expert level

CHAPTER 4: MASTERY (Expert tier)
- Milestone 1: "Champion Seeker" - Enter your first tournament
- Milestone 2: "Match Play" - Play 10 coaching sessions
- Milestone 3: "Consistent" - Reach 1300 ELO
- Milestone 4: "Master Achieved" - Reach Master (1500 ELO)
- Story: You test skills in real competition, learn from coaches

CHAPTER 5: GRANDMASTER PURSUIT (Grandmaster tier)
- Milestone 1: "High Altitude" - Reach 1800 ELO
- Milestone 2: "Peak Performance" - Win a tournament
- Milestone 3: "Creator" - Create 5 puzzles for platform
- Milestone 4: "Grandmaster" - Reach 2000 ELO
- Story: You reach chess mastery, begin contributing to community

CHAPTER 6: LEGACY (Super-GM tier)
- Milestone 1: "Legendary" - Reach 2400 ELO
- Milestone 2: "Mentor" - Coach 20+ students
- Milestone 3: "Creator" - 50+ puzzles on platform (1000+ solves)
- Milestone 4: "Supreme" - Reach 2600 ELO
- Story: You become one of the elite, mentor next generation
```

#### Step 2: Define Achievement Rewards (Week 2)

**Action**: Create meaningful rewards for achievement progression.

**Reward Tiers by Achievement Level**:

```
BRONZE ACHIEVEMENTS (Early progression):
- Reward: +100 bonus rating points (bragging rights)
- Badge: "Beginner" badge on profile
- Unlocks: Beginner-exclusive tactics trainer mode
- Cosmetic: Special bronze border on puzzles solved

SILVER ACHIEVEMENTS (Mid progression):
- Reward: +200 bonus rating points
- Badge: "Intermediate" badge on profile
- Unlocks: Intermediate course (videos, analysis)
- Cosmetic: Silver border on puzzles
- Perk: 1 free coaching session (30 min)

GOLD ACHIEVEMENTS (Expert level):
- Reward: +500 bonus rating points
- Badge: "Expert" badge (rare, visible on leaderboard)
- Unlocks: Expert-only tournaments (higher prize pools)
- Cosmetic: Gold border on puzzles
- Perk: 2 free coaching sessions (1 hour total)
- Creator: Can create puzzles (earn money)

PLATINUM ACHIEVEMENTS (Grandmaster):
- Reward: +1000 bonus rating points
- Badge: "Grandmaster" badge (very rare, prominent display)
- Unlocks: Grandmaster-exclusive tournaments ($1K+ prizes)
- Cosmetic: Platinum/diamond border
- Perk: 5 free coaching sessions (2.5 hours total)
- Creator tools: Priority in creator marketplace
- Status: Listed on "Legends" wall on homepage

DIAMOND ACHIEVEMENTS (Super-GM):
- Reward: +2000 bonus rating points
- Badge: "Legend" badge (1 in 1000 elite)
- Unlocks: Championship tournaments (invite-only)
- Cosmetic: Custom badge design
- Perk: Unlimited coaching (1 free session/month)
- Creator: Revenue share increase (30% instead of 25%)
- Status: Public hall of fame (lifetime)
- Prestige: Lifetime membership (free premium forever)
```

#### Step 3: Build Achievement Progression UI (Week 2-3)

**Action**: Design visual progression showing path from current → next achievement.

**Achievement Page Layout**:
```
[Chapter 4: MASTERY]

Current Status: Expert I (1050 ELO)

Progress to Next Achievement:
┌─────────────────────────────────────────┐
│ MILESTONE: "Champion Seeker"             │
│ Enter your first tournament              │
│                                         │
│ Progress: 0/1 tournaments entered       │
│ Status: Not started                     │
│                                         │
│ [Find Tournament] [How to start]        │
└─────────────────────────────────────────┘

Future Achievements:
┌─────────────────────────────────────────┐
│ MILESTONE: "Match Play" (Far)            │
│ Play 10 coaching sessions               │
│ Reward: Unlock Expert course            │
│                                         │
│ [Book Coaching Session]                 │
└─────────────────────────────────────────┘

Past Achievements:
┌─────────────────────────────────────────┐
│ ✅ CHAPTER 3: Advanced Techniques       │
│ Reached Advanced IV (1000 ELO)          │
│ Unlocked: Advanced techniques course    │
│ Earned: 500 bonus rating points         │
└─────────────────────────────────────────┘
```

#### Step 4: Implement Social Sharing (Week 3-4)

**Action**: Allow players to share achievements for viral engagement.

**Sharing Mechanics**:
- Achievement unlocked: "Share on Twitter" prompt
- Tweet template: "I just reached Master level on Chess Tactics Master! 🎓 [Link to share]"
- Friend challenges: "Beat my achievement: Reach 1500 ELO"
- Leaderboard: Achievements contribute to monthly leaderboard
- Social proof: Show which friends have achieved milestones

#### Step 5: Monitor Achievement Distribution (Week 4-5)

**Action**: Track engagement metrics to ensure achievements motivate.

**Metrics Dashboard**:
- % of players reaching each achievement level
- Time to reach achievement (should increase gradually)
- Churn rate post-achievement (should spike with rewards unlocked)
- Achievement repeat rate (% reaching next achievement after one)
- Social share rate (viral potential)

#### Success Metrics

- [ ] 18+ achievements designed across 6 chapters
- [ ] Narrative progression from Beginner → Super-GM
- [ ] Rewards differentiated by achievement level
- [ ] Achievement progression UI built and tested
- [ ] Social sharing mechanics implemented
- [ ] 60%+ of players reach at least Bronze achievement
- [ ] 20%+ progress to Silver achievement
- [ ] Achievement system drives 5-10% retention lift

### Owner & Timeline

**Owner**: Game Design + Engineering  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: Pilot cohort engagement metrics show lift

---

## GAME BALANCE ISSUE #4: BOOKING ASYMMETRY (TIMEZONE MISMATCH)

### Problem Statement

Current coaching booking: Player can book any coach, any time (no timezone awareness)

**Problems**:
- Player in Singapore books 8am session with USA coach (midnight for coach)
- Coach accepts but is too tired to teach well
- Player frustrated with quality
- Trust eroded

**Impact**:
- Booking cancellation rate high (schedules don't align)
- Coach quality drops (exhausted coaches teaching)
- Player satisfaction low (not getting best coaching)

### Root Cause Analysis

1. **No timezone data** (didn't capture coach's timezone)
2. **No availability matching** (didn't match coach hours to player hours)
3. **No scheduling interface** (assumed simple booking works)
4. **No incentives** (no bonus for coaches taking off-hour sessions)

### Remediation Plan

#### Step 1: Implement Timezone Awareness (Week 1)

**Action**: Capture and display timezone information for coaches and players.

**Coach Profile Enhancement**:
```
Coach: "Alex from NYC"
Location: New York, USA
Timezone: EST (UTC-5)
Working Hours: Mon-Fri 6pm-10pm EST, Sat 10am-6pm EST

Availability in YOUR timezone (Singapore, SGT):
- Mon-Fri: 6am-12pm SGT
- Sat: 11pm-5am SGT

Note: Booking outside working hours requires +$10 premium (coach overtime pay)
```

**Player Booking View**:
```
Want to book Alex (NYC coach)?

Your timezone: Singapore (SGT, UTC+8)
Coach working hours: 6pm-10pm EST
Overlap: 6am-12pm SGT (next day) + Sat 11pm-5am SGT

Available times:
☑ Monday 6am SGT (10pm EST previous night)
☑ Tuesday 6am SGT
...
☐ Wednesday 1am SGT (not in coach working hours)

Recommended: Book Mon-Sat 6am-12pm SGT (coach fresh, well-rested)
Premium rates: Booking outside coach hours (+$10, coach appreciation pay)
```

#### Step 2: Create Recommended Time Slots (Week 1-2)

**Action**: Highlight ideal booking times for coach-player pairs.

**Algorithm**:
1. Get coach's working hours (converted to player timezone)
2. Calculate overlap with player's typically active times
3. Recommend 3-5 "best times" to book
4. Show why each time is good ("Coach is fresh," "Your morning is coach evening")

#### Step 3: Implement Flexible Premium Pricing (Week 2-3)

**Action**: Incentivize off-hour coaching without punishing players/coaches.

**Pricing Model**:

```
Standard Rate: $50/hour
Coach working hours: 6pm-10pm EST

PEAK HOURS (highest demand): 6pm-8pm EST
- Rate: $50/hour (base)
- Quantity: Limited (3 slots/week)
- Player motivation: Standard rate, but book early

NORMAL HOURS (good availability): 8pm-10pm EST
- Rate: $50/hour (base)
- Quantity: Unlimited
- Player motivation: No premium

OFF-HOUR PREMIUM (coach sacrifice): 10pm-midnight EST
- Rate: $60/hour (+$10 coach appreciation pay)
- Quantity: Limited (2 slots/week, opt-in)
- Coach motivation: Earn $18 instead of $15 (30% more)
- Player motivation: Urgent need (e.g., tournament tomorrow)

TIMEZONE MISMATCH PREMIUM: Any time outside coach's preferred 6pm-10pm EST
- Base rate + $10 (e.g., $50 → $60)
- Incentivizes coaches to teach during "good" hours
- Ensures quality (coach gets compensated for inconvenience)
```

#### Step 4: Auto-Match by Timezone (Week 3-4)

**Action**: Help players discover coaches in aligned timezones.

**Discovery Filters**:
```
Looking for a coach?

Filters:
- Rating: 2000+ ✓
- Specialization: Openings ✓
- Timezone overlap: My timezone or -2 to +2 hours ✓ [NEW]
- Language: English ✓
- Price: $40-60/hour ✓

Results:
1. Alex (NYC) - 6 hours overlap ⭐⭐⭐⭐⭐ (Perfect match)
2. Boris (London) - 5 hours overlap ⭐⭐⭐⭐⭐
3. Chen (Singapore, your timezone!) - 8 hours overlap ⭐⭐⭐⭐⭐
```

**Benefits**:
- Players find coaches in compatible timezones
- Coaches book within preferred hours
- Quality higher (well-rested coaches)
- Cancellation rates drop

#### Step 5: Monitor Booking Health (Week 4-5)

**Action**: Track metrics to ensure timezone matching works.

**Metrics**:
- Booking-to-completion rate (how many scheduled sessions happen?)
- Quality ratings (are off-hour sessions rated lower?)
- Cancellation rate by timezone overlap
- Rescheduling frequency (sign of timezone mismatch)

#### Success Metrics

- [ ] Coach timezone data captured and displayed
- [ ] Recommended booking times calculated per coach-player pair
- [ ] Flexible premium pricing implemented (±$10 for off-hours)
- [ ] Auto-match by timezone discoverable
- [ ] Booking-to-completion rate: 90%+ (from ~70%)
- [ ] Cancellation rate drops 30% (timezone alignment)
- [ ] Coach quality stable regardless of booking time

### Owner & Timeline

**Owner**: Product + Coach Ops  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: Booking metrics improve in beta

---

## GAME BALANCE ISSUE #5: TOURNAMENT FAIRNESS - RATING SANDBAGGING

### Problem Statement

Tournament rating sandbagging: High-rated players artificially lower their rating to compete in lower brackets (easy wins, prize pool division).

**Example Exploit**:
- Player with 2000 ELO rating
- Enters "Expert" tournament (max 1500 ELO bracket)
- Reports losses to other accounts to lower rating to 1490
- Competes in lower bracket, beats lower-rated players easily
- Wins tournament with unfair advantage

**Impact**:
- Fair players (legitimately 1500 ELO) can't win
- Trust eroded ("Tournaments aren't fair")
- High-rated players dominate all brackets
- Low-rated players frustrated (can't win against sandbagging)

### Root Cause Analysis

1. **No account linking** (can't detect if same person on multiple accounts)
2. **No rating velocity check** (didn't detect sudden rating drop)
3. **No historical verification** (didn't check if rating is stable)
4. **No bracket lock** (players can change bracket after signing up)

### Remediation Plan

#### Step 1: Implement Rating Velocity Detection (Week 1)

**Action**: Flag accounts with suspicious rating changes.

**Rating Velocity Algorithm**:

```
Suspicious if:
1. Rating drops > 100 points in < 7 days (normal variation: ±30 points/week)
2. Pattern: Drop before tournament, improve after (obvious sandbagging)
3. Series of quick losses (< 5 minutes/game, suggests tanking)

Flag triggers:
- Drop + tournament entry within 24 hours
- Multiple accounts from same IP with suspicious patterns
- Account age < 30 days + entering paid tournament
```

**Action on Detection**:
- Auto-verify: Ask player "We detected a rating change. Did you intend to enter this bracket?"
- Auto-confirm: Player confirms entry bracket at sign-up time
- Disqualify: If flagged + doesn't confirm, player refunded + auto-removed

#### Step 2: Create Rating Brackets with Lock (Week 1-2)

**Action**: Lock player into bracket at sign-up, prevent sandbagging during tournament.

**Bracket System**:

```
Tournament: Premier Monthly
Brackets:
- Emerging (800-1100 ELO)
- Intermediate (1100-1400 ELO)
- Advanced (1400-1700 ELO)
- Expert (1700-2000 ELO)
- Master (2000+ ELO)

Sign-up process:
1. Player enters tournament
2. System assigns bracket based on current rating
3. Confirmation: "You're registered in [Bracket]. Confirm? [Yes/No]"
4. LOCK: Once confirmed, player rating is frozen for tournament duration
5. Post-tournament: Player rating unfrozen, applies all rating changes

Benefit: Can't sandbag by losing games after signing up
```

#### Step 3: Implement Account Linking Detection (Week 2-3)

**Action**: Detect likely multi-accounting and flag for review.

**Multi-Account Detection**:

```
Suspicious account linking if:
1. Same IP address
2. Same device fingerprint
3. Same email domain
4. Similar username patterns (Player1, Player1_alt, PlayerAlt)
5. Same payment method
6. Rapid account switching (same IP, different account, < 5 min apart)

Flagging system:
- Low risk: 1-2 indicators → Warning email
- Medium risk: 3-4 indicators → Require ID verification
- High risk: 5+ indicators → Disqualify from tournament, refund

Legitimate cases (NOT flagged):
- Family members (different payment methods, different names)
- Coaching staff (different usage patterns, explicit disclosure)
- School tournaments (disclosed in tournament setup)
```

#### Step 4: Create Anti-Sandbagging Penalties (Week 3-4)

**Action**: Penalize confirmed sandbagging.

**Sandbag Detection**:
```
Confirmed sandbagging if:
1. Player enters lower bracket than historical high rating
2. Rating velocity shows deliberate tanking (<5 min games, 90% loss rate)
3. Post-tournament: Player's rating spikes (confirms intentional lowering)

Penalties:
- First offense: Rating dropped to actual skill level (no brackets for 1 tournament)
- Second offense: 3-month tournament ban + rating audit
- Repeated: Permanent tournament ban + account warning
```

#### Step 5: Implement Transparent Rating System (Week 4-5)

**Action**: Show rating history to prevent hidden rating drops.

**Rating Transparency**:
```
Player profile shows:
- Current rating: 1950 ELO
- Peak rating (lifetime): 2100 ELO ⭐
- 30-day average: 1970 ELO
- 30-day high: 2050 ELO
- 30-day low: 1820 ELO
- Rating trend: ↗ (trending up)

Tournament eligibility:
"Based on your peak rating (2100), you're eligible for Expert+ tournaments.
You may enter lower brackets, but your historical rating is public."

Benefit: Community knows your true strength, sandbagging loses advantage
```

#### Success Metrics

- [ ] Rating velocity detection algorithm implemented
- [ ] Tournament bracket lock system deployed
- [ ] Multi-account linking detection active
- [ ] Anti-sandbagging penalties documented and enforced
- [ ] Rating transparency on all profiles
- [ ] Sandbagging incidents: < 1% of tournaments
- [ ] Fair player satisfaction: 85%+

### Owner & Timeline

**Owner**: Tournaments Team + Fraud Prevention  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: First tournament runs with < 1% sandbag incidents

---

## GAME BALANCE ISSUE #6: CREATOR REVENUE CLIFFS

### Problem Statement

Creator tiers have sudden revenue drops at boundaries:

**Example Revenue Cliff**:
```
Tier 2 (Hobbyist): 200-2000 solves/month
- Earnings: 20% of revenue, avg $100/month

Tier 3 (Active): 1000+ total puzzles
- Earnings: 25% of revenue, avg $500/month

Problem: Creator has 999 puzzles earning $100/month
Next day: Creates 1000th puzzle, 25% rate applies
- Same 999 puzzles suddenly earn $125 (new rate applies retroactively)
- OR rate only applies to 1000th puzzle onward
Either way: Feels like cliff, not gradual improvement
```

**Impact**:
- Creator confusion ("Why did my earnings jump?")
- Exploitation ("Game the tier system")
- Fairness perception low (feels arbitrary)

### Root Cause Analysis

1. **Tier-based commission splits** (sharp transitions at boundaries)
2. **No granular progression** (big jumps between tiers)
3. **Retroactive vs forward-only** (unclear when new rate applies)
4. **No milestone celebrations** (tier changes feel like glitches, not achievements)

### Remediation Plan

#### Step 1: Smooth Creator Commission Tiers (Week 1)

**Action**: Replace tier cliffs with smooth commission progression.

**Current (Cliff) Model**:
```
Tier 1 (1-100 puzzles): 20% commission
Tier 2 (101-500 puzzles): 20% commission
Tier 3 (501+ puzzles): 25% commission ← CLIFF

Creator at 500 puzzles: 20% of revenue
Creator at 501 puzzles: 25% of revenue (25/20 = +25% jump)
```

**Proposed (Smooth) Model**:
```
Commission scales continuously based on puzzle count:

Commission % = 20% + (Puzzle Count - 50) × 0.0083%
            = 20% + (Puzzle Count - 50) / 12000

Examples:
- 50 puzzles: 20%
- 100 puzzles: 20.4%
- 500 puzzles: 23.8%
- 1000 puzzles: 27.9%
- 2000 puzzles: 32.1%

Benefit: No cliffs, smooth progression
Max cap: 35% (don't go higher even with 5000+ puzzles)
```

**Result**: Creator at 499 → 500 puzzles sees smooth +0.008% increase (not cliff)

#### Step 2: Create Milestone Celebrations (Week 2)

**Action**: Celebrate commission tier improvements with rewards.

**Milestone Rewards**:
```
100 Puzzles:
- Email: "Congratulations! You've created 100 puzzles! 🎉"
- Bonus: +1% commission for 1 month (20% → 21%)
- Badge: "Prolific Creator" badge
- Featured: Homepage "Creator Spotlight" feature (1 week)

250 Puzzles:
- Bonus: +1% commission for 1 month
- Badge: "Dedicated Creator"
- Direct support: Email support priority
- Marketing: Featured in "Rising Stars" email newsletter

500 Puzzles:
- Bonus: +2% commission for 3 months
- Badge: "Elite Creator" (visible on profile)
- Perk: Access to creator analytics (bonus revenue metrics)
- Direct: 1-on-1 coaching call with content lead

1000 Puzzles:
- Bonus: +3% commission for 6 months
- Badge: "Legendary Creator" (prominent display)
- Tier elevation: Automatic promotion to Tier 3 (permanent)
- Recognition: Hall of fame entry

Benefit: Celebrates progress, provides tangible rewards, smooths perception of tiers
```

#### Step 3: Implement Retroactive Commission Adjustment (Week 2-3)

**Action**: When creator reaches milestone, backpay commission improvement on recent revenue.

**Example**:
```
Creator reaches 500 puzzles on Nov 1
- Old rate: 20% (applied through Oct)
- New rate: 23.8% (starting Nov)

Retroactive adjustment (last 30 days):
- Oct 1-31: Earned $100 at 20% = $20 payout
- New calculation: $100 at 23.8% = $23.80
- Retroactive bonus: +$3.80 (applied to Nov payout)

Email: "You reached 500 puzzles! We've updated your commission rate to 23.8%
and added $3.80 retroactive bonus to your next payout."

Benefit: Creator sees immediate value of milestones, not punished for timing
```

#### Step 4: Add Transparency Dashboard (Week 3-4)

**Action**: Show commission progression path to creators.

**Creator Dashboard**:
```
Your Commission Progression

Current Status:
- Puzzles created: 347
- Current commission: 21.1%
- Monthly revenue: $150

Progress to Next Milestone:
[=====>          ] 347/500 puzzles (69%)
- Projected date: Dec 15
- Projected commission at 500: 23.8% (+2.7%)
- Projected bonus payout: +$4.05

Future Milestones:
- 1000 puzzles: 27.9% commission
- 2000 puzzles: 32.1% commission (capped)

Revenue Projection:
If you reach 1000 puzzles in 12 months:
- Current trajectory: $150/month × 12 = $1800/year
- At 1000 puzzles: $500/month × 12 = $6000/year (3.3x growth potential)

[Check out creator resources] [See similar creators]
```

#### Step 5: Monitor Creator Satisfaction (Week 4-5)

**Action**: Track perception of commission system fairness.

**Metrics**:
- Creator satisfaction: "Commission system feels fair" (target: 80%+)
- Churn rate: % creators leaving platform (target: < 5%)
- Retention: % reaching next milestone (target: 70%+)
- Survey: Quarterly feedback on tier system

#### Success Metrics

- [ ] Smooth commission model implemented (no cliffs)
- [ ] Milestone celebrations deployed with bonuses
- [ ] Retroactive commission adjustments working
- [ ] Transparency dashboard live
- [ ] Creator fairness perception: 80%+
- [ ] Creator churn rate: < 5%/year
- [ ] Retention to next milestone: 70%+

### Owner & Timeline

**Owner**: Creator Ops + Product  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: Creator feedback shows fairness perception improvement

---

## GAME BALANCE ISSUE #7: CHURN INTERVENTION TIMING

### Problem Statement

Players churn (stop playing) for different reasons at different times:

**Churn Timeline**:
- Day 1: 50% churn (wrong expectations, difficulty, boring)
- Day 7: 70% cumulative (gave it a week, lost interest)
- Day 30: 92% cumulative (stopped checking in)
- Day 90: 97% cumulative (fully lapsed, re-engagement hard)

**Problem**: CTM doesn't intervene at right times. Generic "Come back!" at Day 90 doesn't work (player has moved on).

**Impact**:
- High churn (97% by Day 90)
- Missed re-engagement windows (best time is Day 7-14)
- Wasted resources (Day 90 intervention costs as much as Day 7, but less effective)

### Root Cause Analysis

1. **No churn prediction** (didn't identify at-risk players early)
2. **No segmented interventions** (same message for all churn reasons)
3. **No optimal timing** (didn't research when re-engagement works)
4. **Weak incentives** (generic "come back" doesn't motivate)

### Remediation Plan

#### Step 1: Build Churn Prediction Model (Week 1)

**Action**: Predict which players will churn before it happens.

**Churn Risk Signals** (from analytics):
```
Day 1-3 Churners (immediate drop):
- Session length: < 5 minutes (didn't engage)
- Puzzle solving: 0-3 puzzles (barely tried)
- Premium conversion: No sign-up
- Device: Mobile only (incomplete experience)
→ Intervention: Day 2 (before fully gone)

Day 4-7 Churners (weak engagement):
- Session frequency: 1-2 times (sporadic)
- Puzzle difficulty: Repeated same tier (stuck, frustrated)
- Rating stagnant: No progress (boring)
- Feedback: No ratings/comments (passive user)
→ Intervention: Day 5 (while still thinking about app)

Day 14+ Churners (gradual fade):
- Frequency declining: 3 days/week → 1 day/week (losing habit)
- Session time: Decreasing (less engaged)
- Puzzle completion rate: Declining (less motivated)
- Tournament interest: No signup (lost competitive drive)
→ Intervention: Day 10-12 (catch before habit breaks)

Day 30+ Churners (dormant):
- No activity: 7+ days without login
- App uninstalled: Yes/No (check app store)
- Email opens: <50% (not reading communications)
→ Intervention: Day 28-30 (last-ditch effort)
```

**Prediction Model**:
```
Risk Score = 0.3 × (Low Engagement) + 0.3 × (Frustration Signals) 
           + 0.2 × (Frequency Decline) + 0.2 × (User Segment)

High risk (>0.7): Likely to churn within 7 days
Medium risk (0.4-0.7): Likely to churn within 30 days
Low risk (<0.4): Likely to retain

Accuracy target: 75%+ precision (accurate predictions)
```

#### Step 2: Create Segmented Interventions (Week 2)

**Action**: Tailor re-engagement message to churn reason.

**Intervention by Churn Reason**:

```
SEGMENT 1: "Too Difficult" (Frustration with puzzles)
Signal: Stuck on same ELO tier for 5+ days, <50% solve rate
Intervention (Day 2):
- Email: "Your puzzles seem too hard! Let's find your level."
- CTA: "Get personalized puzzle recommendations"
- Offer: "Free hints unlocked this week"
- Action: System recommends easier puzzles (100 ELO lower)

SEGMENT 2: "Too Easy" (Boredom)
Signal: 95%+ solve rate, quick session times, no premium signup
Intervention (Day 3):
- Email: "These puzzles are too easy for you! Time for a challenge?"
- CTA: "Try Expert puzzles"
- Offer: "Free premium access to tactics trainer"
- Action: System recommends 200 ELO higher puzzles

SEGMENT 3: "Wrong Expectation" (Expected multiplayer, got solo)
Signal: Mobile only, 0 puzzles solved, no tutorial completion
Intervention (Day 1):
- In-app: "Welcome to Chess Tactics Master! 🎓"
- Explain: "You're here to learn tactics through puzzles"
- Demo: "Let's solve your first puzzle together (2 min)"
- Offer: "Free month of Premium"

SEGMENT 4: "Social/Competitive" (Wanted multiplayer, not solo)
Signal: Installed but tried 0 puzzles, searched for "multiplayer"
Intervention (Day 2):
- Email: "Want to compete with friends? 🏆"
- CTA: "Join a tournament this weekend"
- Offer: "Free tournament entry (usually $5)"
- Show: Tournament brackets, prize pools, player communities

SEGMENT 5: "Lost Habit" (Used to play, fading frequency)
Signal: Was active (10 sessions/week), now 1/week, declining
Intervention (Day 10):
- Email: "We miss you! Solve just 3 puzzles today." ⏱️
- CTA: "Your 10-puzzle streak is waiting!"
- Offer: "+50 bonus rating points this week only"
- Gamify: "Back to 5 sessions/week gets you a badge"
```

#### Step 3: Optimize Intervention Channels (Week 2-3)

**Action**: Use right channel (email, SMS, push) for different users.

**Channel Strategy**:
```
Day 1-2 (Immediate): In-app push (if app still open)
Day 3-5 (Early): Email (highest open rate for new users)
Day 7-10 (Habit): SMS (harder to ignore, more personal)
Day 14-30 (Last-ditch): Email + SMS + retargeting ads (multi-channel)
Day 60+ (Win-back): SMS only ("Limited time offer just for you")
```

**Content by Channel**:
- Email: Detailed explanation + link to personalized experience
- SMS: Short, urgent, time-limited offer ("3-puzzle challenge ends tonight!")
- Push: Reward notification ("New puzzle matching your level!")
- Ads: Retargeting ("Finish your first 100-puzzle milestone! $5K tournament prize pool")

#### Step 4: Test Intervention Timing (Week 3-4)

**Action**: Run experiments to find optimal re-engagement timing.

**A/B Test Design**:
```
Sample: 1000 churning players

Control: Standard "Come back" email at Day 30
Test 1: Segmented email at Day 5 + follow-up at Day 10
Test 2: Segmented SMS at Day 2 + email at Day 7
Test 3: Multi-channel (push Day 1 + email Day 3 + SMS Day 5)

Metric: Re-engagement rate (% who return and play > 1 puzzle)

Expected results:
Control: 5% re-engagement rate
Test 1: 15% re-engagement (3x improvement)
Test 2: 18% re-engagement (4x improvement)
Test 3: 20% re-engagement (4x improvement, highest cost)

Deploy winner: Test 2 (cost-effective + high impact)
```

#### Step 5: Create Win-Back Campaign (Week 4-5)

**Action**: For players churned 60+ days, create special re-onboarding.

**Win-Back Campaign**:
```
"Welcome Back! You've been away for 60 days. Chess Tactics Master has improved!"

What's new (show last 2 months of features):
- New tournament system (prize pools increased 2x)
- New coaching network (100+ coaches from your region)
- New achievement system (progression ladder with rewards)

Special offer (limited time):
- 50% off Premium for 3 months ($2.49/month)
- Free coaching session ($50 value)
- +200 bonus rating points

Personalized: "You were solving [Expert] puzzles. Here are 5 new Expert puzzles!"

Goal: Get player to solve 1 puzzle (entry point back in)
```

#### Success Metrics

- [ ] Churn prediction model built (75%+ accuracy)
- [ ] 5 segmented intervention templates created
- [ ] Multi-channel intervention system deployed
- [ ] Intervention timing optimized (A/B tested)
- [ ] Win-back campaign active
- [ ] Day 7 re-engagement: 15%+ (from <5%)
- [ ] Day 30 churn: Reduced to 85% (from 92%)

### Owner & Timeline

**Owner**: Retention Lead + Analytics  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: A/B test shows 3x+ re-engagement improvement

---

## GAME BALANCE ISSUE #8: MARKETPLACE SATURATION & CONTENT QUALITY

### Problem Statement

As creator marketplace scales, quality issues emerge:

**Potential Issues**:
- Duplicate courses: 10 different coaches create "Opening Masterclass" (confusing)
- Spam/low-quality: Courses with 1-hour content, unrealistic promises
- Pricing confusion: Same course priced $19-299 (no standardization)
- Discovery problem: 1000 courses, players don't know what to choose
- Creator saturation: Too many mediocre coaches, flooding marketplace

**Impact**:
- Player confusion (which course to buy?)
- Player dissatisfaction (bought low-quality course)
- Creator frustration (can't stand out)
- Platform credibility ("Marketplace is garbage")

### Root Cause Analysis

1. **No content quality gates** (anyone can create anything)
2. **No duplicate detection** (didn't prevent redundant content)
3. **No pricing standardization** (each creator sets own price)
4. **No curation** (marketplace is just a dump of content)
5. **No discovery algorithm** (no filtering/sorting by quality)

### Remediation Plan

#### Step 1: Implement Content Quality Gates (Week 1-2)

**Action**: Require minimum standards before content goes live.

**Quality Gate Checklist for Courses**:

```
Before Publishing, Course Must Have:
☑ Minimum 2 hours of content (video, written, audio)
☑ Clear learning outcomes (3+ specific skills taught)
☑ Structured curriculum (5+ modules, logical progression)
☑ Included material (all analysis, games, positions provided)
☑ Creator credentials (minimum 1800 rating or verified credentials)
☑ Peer review (2+ community reviewers rate quality ≥4/5)
☑ Sample content preview (first module available free)

If course fails any check:
- Auto-rejection with specific feedback
- Creator gets resources to improve
- Re-submit when ready (no limit on attempts)
- Approval guaranteed if meets all criteria
```

**Quality Gate for Coaching Services**:

```
Before Opening Coaching Slots, Coach Must:
☑ Minimum 1800 ELO rating (verified)
☑ Complete coaching orientation (video course)
☑ Availability documented (clear working hours)
☑ First 3 students reviewed by platform (quality assurance)
☑ Maintain 4.0+ star rating after 5 sessions

Failure to meet:
- Coaching slots suspended
- Coaching resources provided
- Re-qualification available after 30 days
```

#### Step 2: Detect Duplicate Content (Week 2-3)

**Action**: Flag and merge similar content.

**Duplicate Detection Algorithm**:

```
Content similarity scoring:
1. Title similarity: "Opening Masterclass" vs "Opening Master Class" (95% match)
2. Description similarity: Cosine similarity of topic descriptions (80%+ threshold)
3. Content overlap: Do courses cover same openings in similar order? (75%+ threshold)
4. Pricing: Are prices within 30% of each other? (similar market)

When duplicates detected:
- Flag both creators: "Your course is similar to [Other Course]"
- Suggest consolidation: "Consider collaborating or differentiating"
- Options:
  a) Merge content (creators co-author, share revenue)
  b) Differentiate (each focus on different openings/styles)
  c) Maintain as-is (both live, but user sees both in results)

Goal: Reduce redundancy without stifling creators
```

#### Step 3: Implement Marketplace Curation (Week 3-4)

**Action**: Surface high-quality content first.

**Curation Tiers**:

```
GOLD-TIER COURSES (Curated by platform)
- Minimum 4.7 star rating (500+ reviews)
- Minimum 1000 students enrolled
- Verified high-impact (measurable rating improvement)
- Featured prominently on homepage
- Higher revenue share: 60/40 (creator gets 60% instead of 50%)
- Spotlight: "Platform Recommended" badge

SILVER-TIER COURSES (Quality content)
- Minimum 4.3 star rating (50+ reviews)
- Minimum 100 students enrolled
- No quality gate violations
- Listed in search results with priority ordering
- Standard revenue share: 50/50

BRONZE-TIER COURSES (Approved content)
- Meets quality gates (2 hours, 5 modules, credentials)
- Minimum 4.0 star rating (5+ reviews)
- Listed in search results (lower priority)
- Standard revenue share: 50/50

UNMODERATED: New courses (< 1 month old, < 5 reviews)
- Listed in "New Courses" section (separate from curated)
- Can be promoted to Silver/Gold tier after reviews accumulate
- Standard revenue share: 50/50
```

#### Step 4: Add Pricing Standardization (Week 4)

**Action**: Implement suggested pricing tiers to prevent chaos.

**Suggested Pricing by Course Type**:

```
OPENING COURSE (10-15 openings covered):
- Beginner: $29
- Intermediate: $49
- Advanced: $79

ENDGAME COURSE (comprehensive endgame study):
- Beginner: $19
- Intermediate: $39
- Advanced: $59

TECHNIQUE COURSE (specific techniques: pins, forks, sacrifices):
- Beginner: $9-19
- Intermediate: $19-29
- Advanced: $29-49

1-ON-1 COACHING:
- Emerging coach (1800-2000): $30-45/hour
- Established coach (2000-2200): $50-75/hour
- Expert coach (2200+): $100+/hour
(PPP adjustments apply)

Creator can deviate ±20% (e.g., Intermediate Opening $40-59 instead of $49)
But platform shows "Standard pricing is $49" to set expectations
```

#### Step 5: Monitor Marketplace Health (Week 4-5)

**Action**: Track metrics to ensure marketplace stays healthy.

**Marketplace Health Metrics**:
- Average course rating (target: 4.2+ stars)
- Duplicate detection rate (target: <5% of new content)
- Student satisfaction (target: 80%+ would recommend)
- Creator satisfaction (target: 75%+ feel marketplace is fair)
- Search effectiveness (target: Player finds what they want in <2 minutes)

#### Success Metrics

- [ ] Content quality gates implemented and enforced
- [ ] Duplicate detection algorithm running
- [ ] Curation tiers deployed (Gold/Silver/Bronze)
- [ ] Pricing standardization suggested (not enforced)
- [ ] Marketplace health dashboard live
- [ ] Average course rating: 4.2+ stars
- [ ] Player satisfaction with marketplace: 80%+

### Owner & Timeline

**Owner**: Marketplace Lead + Content Quality  
**Timeline**: Week 1-5 (5 weeks)  
**Validation Gate**: First quality audit shows <5% duplicate content

---

## CONSOLIDATED REMEDIATION SCHEDULE

### Week 1: Foundation
- Issue #1: Difficulty scale refined, puzzle distribution analysis
- Issue #2: PPP model designed, regional pricing tiers
- Issue #3: Achievement narrative written, 6 chapters with milestones
- Issue #4: Timezone data model, recommended booking times
- Issue #5: Rating velocity algorithm, bracket lock system
- Issue #6: Smooth commission formula, milestone rewards
- Issue #7: Churn prediction signals identified, segmentation defined
- Issue #8: Content quality gates drafted, duplicate detection algorithm

### Week 2-3: Implementation
- Issue #1: Difficulty interpolation algorithm coded
- Issue #2: PPP pricing implemented, payment subsidy calculated
- Issue #3: Achievement rewards UI designed
- Issue #4: Timezone-aware coach discovery built
- Issue #5: Account linking detection implemented
- Issue #6: Retroactive commission adjustments, dashboard designed
- Issue #7: Intervention templates written, SMS channel setup
- Issue #8: Duplicate detection algorithm running, marketplace tiers defined

### Week 4-5: Testing & Optimization
- Issue #1: Tier naming system deployed, user testing
- Issue #2: Regional creator outreach begins, first coaches signed
- Issue #3: Achievement progression UI launched
- Issue #4: Booking confirmation flow tested, off-hour premium pricing
- Issue #5: Anti-sandbagging penalties documented
- Issue #6: Milestone celebration campaigns launched
- Issue #7: Win-back campaign ready, A/B test results analyzed
- Issue #8: Quality gates enforced on new content, pricing standardization suggested

---

## SUCCESS CRITERIA & VALIDATION GATES

### Before v1.0 Launch (Q4 2026)
- [ ] Difficulty curve smooth (no ELO tier with 0 puzzles)
- [ ] PPP pricing implemented (emerging markets 50-70% lower)
- [ ] Achievement system narrativized (6 chapters, 18+ milestones)
- [ ] Booking timezone matching live (90%+ booking completion)
- [ ] Anti-sandbagging system deployed (< 1% exploitation rate)
- [ ] Creator revenue cliffs smoothed (no cliff transitions)
- [ ] Churn intervention automated (segmented, multi-channel)
- [ ] Marketplace curated (Gold/Silver/Bronze tiers)

### During Beta (Oct-Dec 2026)
- [ ] Difficulty progression smooth (player surveys 4.0+ rating)
- [ ] PPP pricing fair (emerging market feedback: 80%+ positive)
- [ ] Achievement engagement (60%+ reach Bronze, 20%+ reach Silver)
- [ ] Booking satisfaction (95%+ would book again)
- [ ] Tournament fairness (player feedback: 90%+ trust tournaments)
- [ ] Creator satisfaction (80%+ feel commission is fair)
- [ ] Churn re-engagement (15%+ Day 7 re-engagement)
- [ ] Marketplace search (players find course in <2 min)

---

## Conclusion

Phase V polishes all gameplay mechanics, creator economics, and marketplace health to deliver a cohesive, high-quality product at launch. By executing these game balance improvements, Chess Tactics Master achieves:

- ✅ Smooth difficulty progression (no frustration spikes)
- ✅ Fair creator economics globally (PPP pricing)
- ✅ Engaging achievement system (narrative progression)
- ✅ Seamless coaching bookings (timezone support)
- ✅ Fair tournaments (anti-sandbagging)
- ✅ Transparent creator rewards (no cliffs)
- ✅ Effective churn interventions (15%+ re-engagement)
- ✅ High-quality marketplace (curated, discoverable)

**Project Status Post-Phase V**: LAUNCH READY ✅
- All critical issues fixed (Phase T)
- All major balance problems resolved (Phase U)
- All game balance issues polished (Phase V)
- 39K+ lines of strategic documentation complete
- Series A investment ready
- v1.0 launch Q4 2026 ready

**Next Phase**: PHASE_W - Minor Inconsistencies Cleanup (23 issues) or PHASE_X - Series A Investor Deck finalization.

# Phase H: Live Deployment & Launch Execution

**Status**: Execution Phase  
**Timeline**: 3-7 days (deployment) + ongoing (monitoring)  
**Goal**: Submit Chess Tactics Master to App Store and Google Play, execute controlled launch, and manage first-week operations

---

## Overview

Phase H executes the transition from "production-ready" to "live in app stores" with controlled rollout and comprehensive monitoring. This phase covers actual submission to both platforms, launch day operations, and first-week monitoring procedures.

---

## 1. Pre-Deployment Final Checklist

### 1.1 Code & Build Verification

**Verify Deployment Branch**:
```bash
# Confirm we're on main with all changes
git checkout main
git pull origin main
git log --oneline -1  # Should show Phase G merge

# Verify no uncommitted changes
git status  # Should show "working tree clean"
```

**Verify Deployment Config**:
```bash
# Check deployment_config.dart
grep "appVersion\|buildNumber" lib/src/config/deployment_config.dart
# Expected: appVersion = '1.0.0', buildNumber = 1

# Verify release config
flutter pub get
dart run build_runner build
```

**Final Tests**:
```bash
# Run all tests
flutter test --coverage

# Verify no errors
dart analyze lib/
dart format --set-exit-if-changed lib/
```

### 1.2 Documentation Review

- [ ] PHASE_G_DEPLOYMENT_AND_RELEASE.md reviewed
- [ ] Release notes prepared (RELEASE_NOTES_TEMPLATE.md)
- [ ] Deployment timeline understood
- [ ] On-call team confirmed
- [ ] Support procedures documented
- [ ] Escalation matrix prepared

### 1.3 Monitoring Setup

- [ ] Firebase Console dashboard prepared
- [ ] Crash dashboard configured
- [ ] Analytics dashboard enabled
- [ ] Alerts configured (crash rate >0.5%, rating <3.5)
- [ ] Daily reporting template prepared
- [ ] On-call contact info updated

---

## 2. iOS App Store Submission (Day 1)

### 2.1 Prepare Build Artifacts

```bash
# Clean build environment
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Navigate to iOS directory
cd ios

# Create archive with deployment script
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -derivedDataPath build \
    -archivePath "build/Runner-1.0.0.xcarchive" \
    archive

# Validate archive
xcodebuild -validateArchive \
    -archivePath "build/Runner-1.0.0.xcarchive" \
    -scheme Runner

cd ..
```

**Validation Checklist**:
- [ ] Archive created successfully (build/Runner-1.0.0.xcarchive/)
- [ ] Archive validation passed
- [ ] No warnings or errors
- [ ] File size reasonable (< 200MB)

### 2.2 App Store Connect Upload

**Option A: Using Xcode Organizer (Recommended)**

1. **Open Xcode**:
   ```bash
   open -a Xcode
   ```

2. **Navigate to Organizer**:
   - Menu: Window → Organizer
   - Or: Cmd + Shift + 2

3. **Select Archive**:
   - Tap "Archives" tab
   - Select "Runner-1.0.0.xcarchive"
   - Click "Distribute App"

4. **Distribution Options**:
   - Select "App Store Connect"
   - Click "Next"

5. **Distribution Options** (Screen 2):
   - Uncheck "Manage signing"  OR  Keep automatic signing enabled
   - Click "Next"

6. **Certificate & Profile**:
   - Confirm iOS distribution certificate
   - Confirm provisioning profile
   - Click "Next"

7. **Review & Upload**:
   - Review app information
   - Click "Upload"
   - Wait for upload to complete (5-10 minutes)

**Upload Status**:
- [ ] Archive uploaded to App Store Connect
- [ ] "Ready to Submit" status confirmed
- [ ] No upload errors

### 2.3 App Store Connect Configuration

**Navigate to App Store Connect**: https://appstoreconnect.apple.com

1. **Select App**:
   - My Apps → Chess Tactics Master

2. **Build Selection**:
   - App Store → Prepare for Submission → iOS App
   - Version: "1.0.0"
   - Click "Select a build"
   - Choose build from upload (should appear within 5 minutes)
   - Click "Done"

3. **Version Information**:
   - Version Release Type: Automatic release
   - OR: Scheduled release (set date/time)
   - Phased Release: Check for iOS phased rollout option (optional)

4. **Release Notes**:
   ```
   🎉 Chess Tactics Master 1.0.0 - Initial Release

   ✨ Features:
   • 1000+ tactical puzzles
   • CPU opponents with difficulty levels
   • Real-time online multiplayer
   • ELO rating system
   • Material 3 dark mode
   • Real-time notifications
   • Player leaderboards
   • Game replay system
   • Three-tier subscription

   📋 Requirements: iOS 14.0 or later
   Internet connection for online features
   ```

5. **Review & Submit**:
   - Double-check all information
   - Click "Submit for Review"
   - Confirm submission dialog

**Submission Confirmation**:
- [ ] App submitted for review
- [ ] Status changed to "Waiting for Review"
- [ ] Email received from Apple

### 2.4 Review Timeline Management

**Expected Timeline**: 24-48 hours

**Daily Monitoring**:
- Check App Store Connect status every 4 hours
- Note any status changes
- Review build processing logs for warnings

**If Rejected**:
1. Read rejection email carefully
2. Address each issue systematically
3. Create new build if code changes needed
4. Resubmit with detailed explanations
5. Request expedited review if appropriate

**Post-Approval**:
- [ ] Status changed to "Ready for Sale"
- [ ] App appears in App Store (can take 30 min - 2 hours)
- [ ] Test download on real device
- [ ] Verify app functionality

---

## 3. Android Google Play Submission (Day 1)

### 3.1 Build App Bundle

```bash
# Clean build environment
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Build app bundle
flutter build appbundle \
    --release \
    -t lib/main.dart \
    --build-number=1

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Build Verification**:
```bash
# Verify bundle exists
ls -lh build/app/outputs/bundle/release/app-release.aab

# Validate bundle (if bundletool available)
bundletool validate --bundle-path=build/app/outputs/bundle/release/app-release.aab
```

### 3.2 Google Play Console Upload

**Navigate to Google Play Console**: https://play.google.com/console

1. **Select App**:
   - Chess Tactics Master

2. **Release Management**:
   - Left menu: "Release" → "Production"
   - Click "Create new release"

3. **Upload Bundle**:
   - Click "Browse files" under "App bundles"
   - Select: build/app/outputs/bundle/release/app-release.aab
   - Wait for upload and review (1-2 minutes)
   - Fix any warnings if needed

4. **Release Name**:
   - Name: "1.0.0"
   - Version Code: 1

5. **Release Notes**:
   ```
   🎉 Chess Tactics Master 1.0.0 - Initial Launch!

   Welcome to Chess Tactics Master! Master chess tactics 
   with 1000+ puzzles and challenge players worldwide in 
   real-time multiplayer matches.

   ✨ Features:
   • Comprehensive puzzle library (1000+)
   • AI opponents (multiple difficulty levels)
   • Real-time online multiplayer
   • ELO rating system
   • Material 3 dark mode
   • Real-time notifications
   • Global leaderboards
   • Game replay and analysis
   • Three subscription tiers

   📋 Requirements: Android 7.0+ (API 24+)

   Enjoy and help us improve! 
   support@chessmaster.app
   ```

6. **Rollout Strategy** (IMPORTANT):
   - DO NOT release to 100% immediately
   - Select "Staged rollout" (if available)
   - Initial: 5%
   - Duration: 1 day
   - Click "Next"

7. **Review & Submit**:
   - Review all information
   - Click "Review release"
   - Verify staged rollout is 5%
   - Click "Start staged rollout"

**Submission Confirmation**:
- [ ] Release submitted
- [ ] Status shows "5% rollout" or "Pending Review"
- [ ] No submission errors

### 3.3 Review Timeline Management

**Expected Timeline**: 2-3 hours (first release can be up to 4 hours)

**Monitoring**:
- Check Google Play Console every 30 minutes
- Note any warnings or issues

**Post-Approval**:
- [ ] Status changed to "5% rolled out"
- [ ] App appears in Play Store for 5% of devices
- [ ] Verify app functionality
- [ ] Prepare to escalate rollout

---

## 4. Launch Day Operations (Day 2)

### 4.1 Verification Checklist

**iOS App Store**:
- [ ] App appears in search results
- [ ] App icon displays correctly
- [ ] All screenshots visible
- [ ] Rating system working
- [ ] Reviews can be submitted
- [ ] Download works on test device
- [ ] App launches without crashes

**Android Google Play**:
- [ ] App appears in search results (5% visible)
- [ ] App icon displays correctly
- [ ] Screenshots visible
- [ ] Rating system working
- [ ] Install button functional
- [ ] Download works on test device
- [ ] App launches without crashes

### 4.2 Internal Testing

**iOS**:
1. Fresh install on iOS 14+ device
2. Complete onboarding flow
3. Test CPU game
4. Test online matchmaking
5. Test settings and preferences
6. Force crash to test Crashlytics

**Android**:
1. Fresh install on Android 7.0+ device
2. Complete onboarding flow
3. Test CPU game
4. Test online matchmaking
5. Test settings and preferences
6. Force crash to test Crashlytics

### 4.3 Monitor Metrics

**Launch Dashboard** (Firebase):
- Crash rate (target: <0.1%)
- Session count (target: 100+)
- DAU (target: 50+)
- User retention
- App performance metrics

**Store Metrics**:
- iOS: App Store Analytics
- Android: Google Play Analytics
- Rating and reviews
- Install trends
- Uninstall rate

### 4.4 Social Media Announcement

**Announcement Template**:
```
🎉 Chess Tactics Master is LIVE! 

Available now on:
📱 iOS App Store: [link]
🤖 Android Google Play: [link]

Master chess tactics with 1000+ puzzles and challenge 
players worldwide in real-time multiplayer matches!

Features:
✨ Comprehensive puzzle library
🤖 AI opponents
🌍 Real-time multiplayer
📊 ELO rating system
🌙 Dark mode support
🏆 Global leaderboards

Download now and start improving your chess!

#ChessTacticsMaster #ChessApp #ChessGaming
```

**Post to**:
- [ ] Twitter
- [ ] Instagram
- [ ] Reddit (r/chess, r/AndroidGaming, r/iPhoneGaming)
- [ ] Facebook
- [ ] Website news section

### 4.5 Team Communication

**Email to On-Call Team**:
```
Subject: ✅ Chess Tactics Master 1.0.0 LIVE - Launch Day

Team,

Chess Tactics Master has been successfully submitted to 
both App Store and Google Play. Initial approval received.

Launch Status:
• iOS: Live and available globally
• Android: Live with 5% staged rollout

On-Call Schedule (UTC):
- European: [time range]
- Americas: [time range]
- APAC: [time range]

Monitoring:
- Firebase Dashboard: [link]
- App Store Analytics: [link]
- Google Play Analytics: [link]

Escalation Triggers:
- Crash rate >0.5%: Immediate hotfix
- Rating <3.5 stars: Review analysis
- Server issues: Infrastructure alert

Support Email: support@chessmaster.app

Please stay alert for first 24 hours.
```

---

## 5. First Week Operations (Days 3-7)

### 5.1 Daily Monitoring Checklist

**Every Morning** (UTC 8:00 AM):
- [ ] Crash rate check (target: <0.5%)
- [ ] App rating check (target: ≥3.5)
- [ ] User review analysis (sentiment)
- [ ] Daily active users count
- [ ] Uninstall rate check
- [ ] Email support queue review

**Every Evening** (UTC 6:00 PM):
- [ ] Repeat all morning checks
- [ ] Prepare daily report
- [ ] Escalate any issues
- [ ] Update team on metrics

### 5.2 Escalation Procedures

**Crash Rate >1%**:
1. Investigate Crashlytics for top crash signatures
2. Reproduce top crash locally
3. Create hotfix branch
4. Build and test fix
5. Submit hotfix (See Phase G hotfix.sh)
6. Update team

**Crash Rate >0.5%**:
1. Same as above
2. Monitor but may delay hotfix if minor

**Rating Drop <3.5**:
1. Read negative reviews carefully
2. Identify patterns in complaints
3. Respond to reviews professionally
4. Schedule fixes for next release

**Network/Server Issues**:
1. Check server status dashboard
2. Contact backend team
3. Implement workarounds if needed
4. Communicate status to users

### 5.3 Rollout Escalation (Android)

**Day 1**: 5% rollout (monitoring)
- [ ] No critical issues
- [ ] Crash rate <0.5%
- [ ] Rating ≥3.5

**Day 2**: Escalate to 10%
```
Google Play Console:
- Release → Staged Rollout
- Increase to 10%
- Monitor additional 24 hours
```

**Day 3**: Escalate to 25%
```
Same process, increase to 25%
Monitor for 24 hours
```

**Day 4**: Escalate to 50%
```
Same process, increase to 50%
Monitor for 24 hours
```

**Day 7**: Complete Rollout to 100%
```
Same process, increase to 100%
App now available to all Android users
```

**Halt Conditions** (Pause Rollout):
- Crash rate >1% → Halt and create hotfix
- Rating drops <3.0 → Halt and investigate
- Server issues >50% failure → Halt and fix
- Security vulnerability → Halt and patch

### 5.4 Support Procedure

**Support Email Workflow**:
1. Receive email to support@chessmaster.app
2. Read and categorize issue
3. Respond within 24 hours (SLA)
4. For bugs: Log in Crashlytics
5. For feature requests: Track for future releases
6. For account issues: Escalate to backend team
7. Follow up after resolution

**Review Response Procedure**:
1. Read negative reviews daily
2. Respond professionally and helpfully
3. Acknowledge issue
4. Provide solution or workaround
5. Offer to follow up
6. Mark as resolved if fixed

### 5.5 Daily Report Template

```markdown
# Chess Tactics Master - Daily Report
Date: 2026-08-27

## Metrics Summary
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Crash Rate | <0.5% | 0.2% | ✅ |
| App Rating | ≥4.0 | 4.2 | ✅ |
| DAU | ≥500 | 600 | ✅ |
| Session Length | >5 min | 6.5 | ✅ |
| Uninstall Rate | <5% | 3% | ✅ |

## Platform Status
- iOS: ✅ Live and available
- Android: ✅ 10% rollout (Day 2)

## Issues
- None critical

## Reviews & Feedback
- 48 ratings received
- Average: 4.2 stars
- Common feedback: Great puzzles, smooth gameplay

## Actions Taken
- Monitored crash dashboard
- Responded to 3 support emails
- Escalated Android rollout to 10%

## Next Steps
- Continue monitoring
- Escalate to 25% rollout tomorrow if metrics hold
- Plan first patch release (1.0.1)

## Escalation Status
✅ No escalations needed
```

---

## 6. Success Metrics & Targets

### 6.1 Launch Window (Days 1-3)

| Metric | Target | Threshold |
|--------|--------|-----------|
| Crash Rate | <0.1% | >0.5% HALT |
| App Rating | ≥3.5 | <3.5 WARN |
| Downloads (iOS) | 50+ | N/A |
| Downloads (Android) | 50+ | N/A |
| Installation Success | 95%+ | <90% HALT |
| First Launch Completion | 80%+ | <60% WARN |

### 6.2 First Week (Days 3-7)

| Metric | Target | Status |
|--------|--------|--------|
| Crash Rate | <0.5% | Monitoring |
| App Rating | ≥4.0 | Pending |
| DAU | ≥500 | Pending |
| Session Length | >5 min | Pending |
| Retention D1 | >40% | Pending |
| Retention D7 | >20% | Pending |
| Uninstall Rate | <5% | Pending |

### 6.3 End of Month

| Metric | Target |
|--------|--------|
| Crash Rate | <0.1% |
| App Rating | ≥4.2 |
| DAU | ≥2,000 |
| Retention D30 | >10% |
| ARPU | >$0.50 |

---

## 7. Hotfix Procedures During Launch

**Critical Issues** (App-breaking):
```bash
# 1. Create hotfix branch
./scripts/hotfix.sh "issue_name" "Fix description"

# 2. Implement fix

# 3. Test thoroughly

# 4. Push to GitHub
git push origin hotfix/...

# 5. Create PR and merge

# 6. Deploy
./scripts/deploy.sh 1.0.1 2 production

# 7. Submit to stores
# iOS: Xcode Organizer
# Android: Google Play Console
```

**Timeline**:
- iOS: 24-48 hours (can expedite)
- Android: 2-3 hours (expedite available)

---

## 8. Post-Launch Planning

### Week 2: Patch Release (1.0.1)

**Focus**: Bug fixes from launch feedback
```bash
./scripts/deploy.sh 1.0.1 2 production
```

### Month 1: Minor Release (1.1.0)

**Focus**: Small features based on user feedback

### Month 2: Feature Release (1.2.0)

**Focus**: Larger features and improvements

---

## 9. Emergency Procedures

### 9.1 Server Outage

1. **Detection**: Crash rate or error spike >10%
2. **Response**: Check server status dashboard
3. **Communication**: 
   - Notify backend team
   - Update status page
   - Post to social media if >1 hour
4. **User Notification**: In-app message if available
5. **Follow-up**: Post-mortem after restoration

### 9.2 Security Vulnerability

1. **Detection**: Security report or audit finding
2. **Response**: 
   - Assess severity (P0-P3)
   - Create emergency hotfix
   - Test thoroughly
3. **Submission**: 
   - Expedite both stores
   - Request urgent review
4. **Communication**: 
   - Update privacy/security page
   - Notify affected users (if data breach)
5. **Follow-up**: Security audit remediation

### 9.3 Mass Negative Reviews

1. **Root Cause**: 
   - Analyze review content
   - Check crash dashboard
   - Review support emails
2. **Response**:
   - Create fix if issue identified
   - Respond to reviews
   - Engage with users
3. **Action**:
   - Hotfix if critical
   - Plan patch for next release
4. **Communication**:
   - Social media response
   - Support email blitz

---

## Checklist: Launch Execution

**Pre-Launch**:
- [ ] All code merged to main
- [ ] Tests passing and coverage >90%
- [ ] Deployment config verified
- [ ] On-call team confirmed
- [ ] Monitoring dashboards ready

**iOS Submission**:
- [ ] Build archive created and validated
- [ ] Uploaded to App Store Connect
- [ ] Metadata complete and reviewed
- [ ] Release notes finalized
- [ ] Submitted for review

**Android Submission**:
- [ ] App bundle built and validated
- [ ] Uploaded to Google Play Console
- [ ] Metadata complete and reviewed
- [ ] Release notes finalized
- [ ] Staged rollout set to 5%
- [ ] Submitted to review

**Launch Day**:
- [ ] Both apps approved and available
- [ ] Verified working on real devices
- [ ] Firebase dashboards active
- [ ] Social media announcements posted
- [ ] Team notifications sent
- [ ] First monitoring round completed

**First Week**:
- [ ] Daily monitoring completed
- [ ] Android rollout escalated progressively
- [ ] Support emails answered
- [ ] Metrics tracked and reported
- [ ] No critical issues unresolved

---

**Phase H Status**: Execution Phase  
**Success Criteria**: App live in both stores with metrics on track  
**Next**: Ongoing operations and updates (Phase I+)


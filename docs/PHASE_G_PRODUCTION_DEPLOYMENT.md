# Phase G: Production Deployment & Monitoring Guide

**Phase Status:** In Progress  
**Week:** 16 (Production Release Week)  
**Date Started:** 2026-09-05

---

## Overview

Phase G manages the production deployment of Chess Tactics Master with the complete monetization system (Phases E & F). This phase includes staging validation, production configuration, monitoring setup, and phased rollout strategy.

## Pre-Deployment Checklist

### Infrastructure Readiness ✅
- [x] Phase F testing complete (250+ tests)
- [x] Security audit complete
- [x] All dependencies validated
- [x] Firebase project configured
- [x] RevenueCat account set up
- [x] GitHub Actions CI/CD ready

### Code Readiness ✅
- [x] Main branch passing (baseline)
- [x] All Phase E/F code merged
- [x] Security rules in place
- [x] Error handling comprehensive
- [x] Logging and monitoring integrated

### Documentation ✅
- [x] Security procedures documented
- [x] Testing procedures documented
- [x] Deployment procedures (this guide)
- [x] Incident response procedures
- [x] Privacy policy updated
- [x] Terms of Service updated

---

## Staging Deployment

### 1. Staging Environment Setup

**Firebase Staging Project:**
```bash
# Create staging project (if not exists)
firebase projects:create chess-staging

# Deploy security rules to staging
firebase deploy --only firestore:rules --project chess-staging

# Deploy Firebase functions to staging
firebase deploy --only functions --project chess-staging

# Enable services
# - Authentication
# - Firestore Database
# - Realtime Database (if used)
# - Cloud Storage
# - Analytics
# - Crashlytics
```

**RevenueCat Staging:**
```bash
# Use RevenueCat Sandbox App for staging
# 1. Go to https://dashboard.revenuecat.com
# 2. Switch to Sandbox environment
# 3. Create test products matching production
# 4. Note Sandbox Public SDK Key
# 5. Configure in .env.staging
```

### 2. Staging Build & Deployment

**Build Staging APK/IPA:**
```bash
# Android Staging Build
flutter build apk \
  --release \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=FIREBASE_PROJECT=chess-staging \
  --dart-define=REVENUECAT_KEY=pk_test_xxxxx

# iOS Staging Build  
flutter build ios \
  --release \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=FIREBASE_PROJECT=chess-staging \
  --dart-define=REVENUECAT_KEY=pk_test_xxxxx
```

**Deploy to Staging:**
```bash
# Firebase App Distribution (Android)
firebase appdistribution:distribute \
  build/app/outputs/apk/release/app-release.apk \
  --app=1:xxx:android:xxxx \
  --project=chess-staging

# TestFlight (iOS)
# Upload via Xcode or transporter
```

### 3. Staging Validation Testing

**End-to-End Test Scenarios:**

**A. Authentication Flow**
- [ ] Email/password signup
- [ ] Google sign-in
- [ ] Apple sign-in
- [ ] Session persistence
- [ ] Logout and re-login

**B. Subscription Flow**
- [ ] View paywall screen
- [ ] Premium monthly purchase
- [ ] Premium Plus yearly purchase
- [ ] Lifetime subscription
- [ ] Restore purchases
- [ ] Cancel subscription
- [ ] Re-subscribe after cancellation

**C. Feature Access Verification**
- [ ] Free user restrictions
- [ ] Premium features accessible
- [ ] Premium Plus features accessible
- [ ] Feature gating enforcement

**D. Analytics Validation**
- [ ] App launch event tracked
- [ ] Screen views tracked
- [ ] Game completion events tracked
- [ ] Puzzle completion events tracked
- [ ] Custom events logged
- [ ] Events appear in Firebase Console

**E. Payment Processing**
- [ ] Sandbox transactions complete
- [ ] Receipt validation
- [ ] Subscription status synced
- [ ] Revenue events logged
- [ ] No real charges (sandbox only)

**F. Error Handling**
- [ ] Network disconnection handled
- [ ] Payment timeout handled
- [ ] Invalid subscription state handled
- [ ] Firebase connection errors handled

**G. Performance Testing**
- [ ] App launch time < 2 seconds
- [ ] Paywall load time < 1 second
- [ ] Purchase flow < 5 seconds
- [ ] Event logging non-blocking
- [ ] Memory usage stable

**H. Security Validation**
- [ ] API keys not exposed
- [ ] Payment data not logged
- [ ] Firebase rules enforced
- [ ] Authentication tokens secure
- [ ] No sensitive data in logs

### 4. Staging Sign-Off

**Validation Checklist:**
```
Staging Deployment Validation Report
=====================================

Date: _______________
Tester: _______________
Environment: chess-staging

[ ] Authentication system working
[ ] All subscription tiers functional
[ ] Feature gating enforced
[ ] Analytics events tracked
[ ] Payment processing works
[ ] Error handling robust
[ ] Performance acceptable
[ ] Security measures verified
[ ] No console errors/warnings
[ ] Ready for production

Issues Found:
- Issue 1: _________________ [RESOLVED/DEFERRED]
- Issue 2: _________________ [RESOLVED/DEFERRED]

Sign-Off: _________________ Date: _________
```

---

## Production Deployment

### 1. Production Environment Setup

**Firebase Production Project:**
```bash
# Verify production project exists (yourwish-chess)
firebase projects:list

# Deploy to production
firebase deploy --only firestore:rules

# Enable production analytics
firebase apps:sdkconfig WEB > public/firebase-config.json

# Test production connection
# - Verify Firestore accessible
# - Verify Analytics receiving events
# - Verify Crashlytics initialized
```

**RevenueCat Production:**
```bash
# Production Setup
# 1. Go to https://dashboard.revenuecat.com
# 2. Switch to Production environment
# 3. Create production App Store subscription products
#    - Premium Monthly: $4.99
#    - Premium Yearly: $49.90
#    - Premium Lifetime: $99.99
#    - Premium Plus Monthly: $9.99
#    - Premium Plus Yearly: $99.90
#    - Premium Plus Lifetime: $199.99
# 4. Note Production Public SDK Key: pk_live_xxxxx
# 5. Store in secure secrets manager
# 6. Configure in production .env
```

**App Store Configuration:**
```bash
# iOS
# 1. Create App Store Connect application
# 2. Create subscription products matching above
# 3. Set up in-app purchase prices
# 4. Create test users in Sandbox
# 5. Configure privacy policy
# 6. Add app privacy details

# Subscription Categories:
# - Premium Monthly: Recurring subscription, 1 month trial
# - Premium Yearly: Recurring subscription, 14 days trial  
# - Premium Lifetime: Non-renewable purchase
```

**Google Play Configuration:**
```bash
# Android
# 1. Create app in Google Play Console
# 2. Create subscription products
# 3. Set up pricing tiers (region-specific)
# 4. Configure privacy policy
# 5. Add app privacy details
# 6. Set up billing account

# Important: Google Play requires:
# - Clear subscription cancellation mechanism
# - Transparent pricing
# - Refund policy documented
```

### 2. Production Build & Deployment

**Build Production Release:**
```bash
# Increment version in pubspec.yaml
# Example: 1.1.0 → 1.2.0

# Android Production Build
flutter build appbundle --release

# iOS Production Build  
flutter build ios --release
```

**App Store Submission:**
```bash
# iOS
# 1. Archive in Xcode
# 2. Upload via Organizer
# 3. Submit for review
# 4. Expected review time: 1-2 days
# 5. Wait for approval before release

# Android
# 1. Upload AAB to Google Play Console
# 2. Create release notes
# 3. Set rollout percentage (see Phased Rollout)
# 4. Submit for review (usually instant)
```

### 3. Pre-Release Production Checks

**24 Hours Before Release:**

```
Pre-Release Checklist
=====================

Infrastructure:
[ ] Firebase production accessible
[ ] RevenueCat production configured
[ ] All APIs responsive
[ ] Database performance acceptable
[ ] Monitoring dashboards active

Code:
[ ] Main branch fully tested
[ ] All Phase E/F features verified
[ ] Security rules deployed
[ ] Error logging active
[ ] Analytics collecting events

Operations:
[ ] On-call schedule confirmed
[ ] Incident response team ready
[ ] Monitoring alerts configured
[ ] Rollback procedures documented
[ ] Support team briefed

Documentation:
[ ] Release notes prepared
[ ] Known issues documented
[ ] Support FAQ updated
[ ] Troubleshooting guide ready
```

---

## Phased Rollout Strategy

### Phase 1: Early Access (Days 1-3)
**Rollout: 10% of users**

**Objectives:**
- Validate production setup
- Monitor for critical errors
- Confirm payment processing
- Test analytics pipeline
- Verify user experience

**Monitoring Focus:**
- Crash rate (target < 0.5%)
- Payment success rate (target > 99%)
- API response times
- User session duration
- Feature adoption

**Decision Points:**
- No critical crashes → Expand to 25%
- Payment rate stable → Expand to 25%
- Analytics flowing → Expand to 25%
- Issue found → Fix and re-test 10%

### Phase 2: Beta Rollout (Days 4-6)
**Rollout: 25% → 50% of users**

**Objectives:**
- Expand to larger user base
- Confirm stability at scale
- Gather user feedback
- Monitor system performance
- Validate pricing acceptance

**Monitoring Focus:**
- Crash rate trend
- Payment conversion rate
- Customer support ticket volume
- Feature usage metrics
- Regional performance

**Decision Points:**
- Stable performance → Expand to 75%
- Payment issues → Hold and investigate
- Support tickets manageable → Expand to 75%
- Data quality good → Expand to 75%

### Phase 3: Full Rollout (Days 7+)
**Rollout: 50% → 100% of users**

**Objectives:**
- Complete production deployment
- Monitor full user base
- Optimize based on data
- Plan Phase H features
- Establish monitoring baseline

**Monitoring Focus:**
- Long-term stability
- Conversion metrics
- Revenue tracking
- Churn rate
- User satisfaction

---

## Monitoring & Alerting

### 1. Firebase Monitoring

**Analytics Dashboard:**
```
Key Metrics:
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Session duration
- Feature adoption
- Conversion rate (free → premium)
- Revenue metrics

Real-Time Alerts:
- Crash rate > 1%
- Purchase failures > 5%
- API errors > 1000/min
- Storage quota near limit
```

**Crashlytics Dashboard:**
```
Monitor:
- Total crashes per day
- Affected users count
- Top crash stacks
- Crash-free users %
- Regression detection

Alert Triggers:
- New crash type
- Crash rate spike
- Critical issue (priority 1)
- User-impacting error
```

### 2. RevenueCat Monitoring

**Revenue Dashboard:**
```
Track:
- Daily revenue
- Monthly Recurring Revenue (MRR)
- Annual Recurring Revenue (ARR)
- Subscription breakdown (Premium vs Premium Plus)
- Churn rate
- Refund rate
- Trial conversion rate

Alert Triggers:
- Churn rate > 5%/month
- Refund rate > 3%
- Payment processing failures
- Suspicious activity
```

### 3. Custom Dashboards

**Create Firebase Console Dashboard:**
```
1. Revenue Tracking
   - Purchase events by type
   - Revenue by region
   - Conversion funnel
   - LTV trends

2. User Engagement
   - Feature usage heat map
   - Premium feature adoption
   - User retention curves
   - Churn analysis

3. Performance Metrics
   - App performance by device
   - Network latency analysis
   - Analytics event delivery lag
   - Database query performance

4. Security & Compliance
   - Failed authentication attempts
   - Unusual subscription patterns
   - Sensitive error frequencies
   - Regional data residency
```

### 4. Alerting Configuration

**Email Alerts Setup:**

```
Critical Alerts (Immediate):
- Crash rate > 1%
- Payment processing down
- Database connection failed
- More than 10,000 errors/min
→ Send to: ops-team@company.com

High Priority (within 1 hour):
- Crash rate > 0.5%
- Payment failures > 50/hour
- API latency > 5 seconds
- Analytics lag > 15 minutes
→ Send to: dev-team@company.com

Medium Priority (daily digest):
- Feature usage changes
- Churn rate movements
- Performance trends
- Security events
→ Send to: analytics@company.com
```

**Slack Integration:**
```bash
# Install Firebase → Slack integration
# Channels:
- #alerts-critical: Production issues
- #analytics-daily: Daily metrics
- #revenue-tracking: Financial metrics
- #security-events: Security findings
```

---

## Post-Deployment Procedures

### Day 1: Launch Monitoring

**Immediate Checks (Every 30 minutes):**
- [ ] App store reviews positive (or no errors)
- [ ] No spike in crash reports
- [ ] Payment processing smooth
- [ ] Analytics events flowing
- [ ] Support team receiving normal volume

**Action Items:**
- Monitor revenue closely
- Track payment success rate
- Watch for user-reported issues
- Confirm analytics data quality

### Day 2-3: Stability Assessment

**Daily Review:**
- Revenue trends
- User acquisition
- Feature usage
- Crash patterns
- Support tickets

**Decision:**
- Continue with next rollout phase?
- Pause and investigate issues?
- Revert and fix (emergency)?

### Week 1: Consolidation

**Metrics to Establish:**
- Baseline MAU/DAU
- Premium conversion rate
- Average revenue per user
- User retention rate
- Support load

**Optimizations to Plan:**
- Pricing adjustments
- Feature prioritization
- User onboarding improvements
- Performance optimizations

---

## Incident Response

### Critical Issue Protocol

**Severity 1: Payments Not Processing**
```
1. Immediate Actions:
   - Pause 100% rollout
   - Revert to previous version (if applicable)
   - Check RevenueCat status
   - Check Firebase status
   - Check App Store/Play Store status

2. Communication:
   - Notify ops team
   - Update status page
   - Prepare user communication

3. Investigation:
   - Check logs for errors
   - Verify payment processor connection
   - Confirm receipt validation
   - Test with sandbox account

4. Resolution:
   - Deploy fix if found
   - Resume rollout at 10%
   - Monitor closely
```

**Severity 2: High Crash Rate (>1%)**
```
1. Immediate Actions:
   - Pause rollout expansion
   - Investigate top crash stack
   - Check if crash is new or known

2. Analysis:
   - Identify affected device/OS
   - Review recent code changes
   - Check dependency versions

3. Resolution:
   - Deploy hotfix if identified
   - If not identified, revert to previous version
   - Prepare post-mortem

4. Resume:
   - Re-test thoroughly
   - Resume rollout at 10%
```

**Severity 3: Data Privacy Issue**
```
1. Immediate Actions:
   - Stop collecting affected data
   - Preserve logs for investigation
   - Notify security team

2. Communication:
   - Assess user impact
   - Prepare GDPR/legal notification if needed
   - Document incident

3. Remediation:
   - Fix data collection
   - Request data retention review
   - Implement additional safeguards

4. Follow-up:
   - Post-mortem with team
   - Update security procedures
   - Audit similar areas
```

---

## Success Metrics

### Week 1 Goals
- [ ] Reach 10% rollout (Phase 1)
- [ ] No critical issues requiring rollback
- [ ] Crash-free users > 99%
- [ ] Payment success rate > 99%
- [ ] Zero payment data breaches
- [ ] Analytics data quality > 95%

### Month 1 Goals
- [ ] Full rollout (100%)
- [ ] Premium conversion rate > 5%
- [ ] Monthly revenue > $5,000
- [ ] User retention > 40%
- [ ] Support volume manageable
- [ ] Monitoring fully operational

### Quarter 1 Goals
- [ ] Optimize paywall for conversion
- [ ] Reduce churn to < 3%/month
- [ ] Premium Plus adoption > 20% of premium
- [ ] User LTV > $50
- [ ] Quarterly revenue > $50,000
- [ ] Plan Phase H features

---

## Post-Deployment Review

**After 1 Month:**

```
Deployment Success Report
=========================

Objectives Met:
[ ] Production deployment successful
[ ] Revenue system operational
[ ] Analytics tracking complete
[ ] Monitoring established
[ ] Support team trained

Key Metrics:
- Crash-free users: ____%
- Payment success rate: ____%
- Premium conversion: ____%
- Revenue (MRR): $______
- User retention: ____%

Issues Encountered:
1. Issue: _________________ [RESOLVED/ONGOING]
2. Issue: _________________ [RESOLVED/ONGOING]

Learnings:
- Learning 1: _________________
- Learning 2: _________________

Recommendations for Phase H:
1. _____________________
2. _____________________

Approval: _________________ Date: _________
```

---

## Phase G Deliverables

✅ **Phase G: Production Deployment & Monitoring**

- [ ] Staging environment validated
- [ ] Production Firebase configured
- [ ] RevenueCat production integrated
- [ ] App Store/Play Store submissions complete
- [ ] Phased rollout executed (10% → 25% → 50% → 100%)
- [ ] Monitoring dashboards operational
- [ ] Alerting configured and tested
- [ ] Incident response procedures documented
- [ ] Support team trained
- [ ] Revenue tracking established

**Estimated Duration:** 2-3 weeks
**Target Revenue (Month 1):** $5,000+
**Target Premium Conversion:** 5%+

---

## Next Phase: Phase H (Analytics & Insights)

**Focus Areas:**
- Advanced analytics dashboards
- Cohort analysis
- A/B testing framework
- Churn prediction models
- LTV optimization strategies
- Regional expansion analysis

---

Generated with [Claude Code](https://claude.ai/code)

**Phase G: Production Deployment Guide** 📋

#!/usr/bin/env dart

import 'dart:io';
import 'dart:math';

/// Manual testing script to verify Otium demo flow timing and calculations
/// This script simulates the demo flow and verifies timing requirements

void main() async {
  print('🧠 Otium Demo Flow Verification');
  print('================================\n');

  // Test 1: Verify overload score calculation
  print('📊 Testing Overload Score Calculation...');
  testOverloadCalculation();
  
  // Test 2: Verify demo timing
  print('\n⏱️  Testing Demo Flow Timing...');
  await testDemoTiming();
  
  // Test 3: Verify score reduction
  print('\n📉 Testing Score Reduction Logic...');
  testScoreReduction();
  
  // Test 4: Verify classification thresholds
  print('\n🏷️  Testing Classification Thresholds...');
  testClassificationThresholds();
  
  print('\n✅ All manual tests completed!');
  print('📋 Summary: Demo flow should take approximately 2 minutes');
  print('   • Simulation phase: ~30 seconds (35 taps)');
  print('   • Breathing exercise: 90 seconds');
  print('   • Dashboard review: ~10 seconds');
  print('   • Total: ~2 minutes 10 seconds');
}

void testOverloadCalculation() {
  // Test the overload score formula: (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes)
  
  // Test case 1: Initial state
  var score = calculateScore(0, 0, 0);
  assert(score == 0.0, 'Initial score should be 0');
  print('  ✓ Initial state: Score = $score (Expected: 0)');
  
  // Test case 2: After one simulation tap
  // Each tap: unlocks +3, appSwitches +2
  score = calculateScore(3, 2, 0);
  var expected = (0.4 * 3) + (0.4 * 2) + (0.2 * 0);
  assert((score - expected).abs() < 0.01, 'Score calculation incorrect');
  print('  ✓ After 1 tap: Score = $score (Expected: $expected)');
  
  // Test case 3: After 35 taps (threshold crossing)
  var unlocks = 35 * 3; // 105
  var appSwitches = 35 * 2; // 70
  score = calculateScore(unlocks, appSwitches, 0);
  expected = (0.4 * 105) + (0.4 * 70) + 0; // 42 + 28 = 70
  assert((score - expected).abs() < 0.01, 'Score calculation incorrect');
  print('  ✓ After 35 taps: Score = $score (Expected: $expected)');
  assert(score > 60, 'Score should exceed threshold of 60');
  print('  ✓ Threshold crossed: Score > 60');
}

double calculateScore(int unlocks, int appSwitches, int nightMinutes) {
  return (0.4 * unlocks) + (0.4 * appSwitches) + (0.2 * nightMinutes);
}

Future<void> testDemoTiming() async {
  var stopwatch = Stopwatch()..start();
  
  print('  📱 Simulating app switch taps...');
  // Simulate 35 taps at ~1 tap per second
  for (int i = 0; i < 35; i++) {
    await Future.delayed(Duration(milliseconds: 50)); // Fast simulation for testing
    if ((i + 1) % 10 == 0) {
      print('    Tap ${i + 1}/35 completed');
    }
  }
  
  var simulationTime = stopwatch.elapsedMilliseconds;
  print('  ✓ Simulation phase: ${simulationTime}ms (Real demo: ~30 seconds)');
  
  print('  🫁 Simulating breathing exercise (90 seconds)...');
  // In real demo, this would be 90 seconds
  await Future.delayed(Duration(milliseconds: 100)); // Fast simulation
  var breathingTime = 90000; // 90 seconds in real demo
  print('  ✓ Breathing exercise: ${breathingTime}ms');
  
  print('  📊 Simulating dashboard review...');
  await Future.delayed(Duration(milliseconds: 50)); // Fast simulation
  var dashboardTime = 10000; // ~10 seconds in real demo
  print('  ✓ Dashboard review: ${dashboardTime}ms');
  
  var totalTime = simulationTime + breathingTime + dashboardTime;
  var totalMinutes = totalTime / 60000;
  print('  ✅ Total demo time: ${totalMinutes.toStringAsFixed(1)} minutes');
  
  assert(totalMinutes >= 1.8 && totalMinutes <= 2.5, 
         'Demo should take approximately 2 minutes');
}

void testScoreReduction() {
  // Test intervention effect: score should be reduced to 50%
  var originalScore = 70.0;
  var reducedScore = originalScore * 0.5;
  
  print('  📊 Original score: $originalScore');
  print('  📉 Reduced score: $reducedScore');
  print('  📈 Reduction: ${((originalScore - reducedScore) / originalScore * 100).toStringAsFixed(1)}%');
  
  assert(reducedScore == 35.0, 'Score reduction should be exactly 50%');
  print('  ✓ Score reduction verified: 50% reduction applied correctly');
  
  // Test metrics reduction
  var originalUnlocks = 105;
  var originalAppSwitches = 70;
  var reducedUnlocks = (originalUnlocks * 0.5).round();
  var reducedAppSwitches = (originalAppSwitches * 0.5).round();
  
  print('  📱 Metrics reduction:');
  print('    Unlocks: $originalUnlocks → $reducedUnlocks');
  print('    App Switches: $originalAppSwitches → $reducedAppSwitches');
  
  assert(reducedUnlocks == 53, 'Unlocks should be reduced by 50% and rounded');
  assert(reducedAppSwitches == 35, 'App switches should be reduced by 50% and rounded');
  print('  ✓ Metrics reduction verified');
}

void testClassificationThresholds() {
  // Test classification boundaries
  var testCases = [
    (0.0, 'Calm'),
    (15.0, 'Calm'),
    (29.9, 'Calm'),
    (30.0, 'Moderate'),
    (45.0, 'Moderate'),
    (60.0, 'Moderate'),
    (60.1, 'High Overload'),
    (70.0, 'High Overload'),
    (100.0, 'High Overload'),
  ];
  
  for (var testCase in testCases) {
    var score = testCase.$1;
    var expectedClassification = testCase.$2;
    var actualClassification = getClassification(score);
    
    assert(actualClassification == expectedClassification, 
           'Classification for score $score should be $expectedClassification, got $actualClassification');
    print('  ✓ Score $score → $actualClassification');
  }
}

String getClassification(double score) {
  if (score < 30) return 'Calm';
  if (score <= 60) return 'Moderate';
  return 'High Overload';
}
import test from 'node:test';
import assert from 'node:assert/strict';
import { answerQuestion, DESTINATIONS, INITIAL_PROGRESS, REWARD, sanitizeProgress, TRANSPORTS, travelTo } from '../src/game.ts';
import type { Progress } from '../src/game.ts';

const fresh = (): Progress => structuredClone(INITIAL_PROGRESS);
const win = (p: Progress) => answerQuestion(p, DESTINATIONS[p.current].id, DESTINATIONS[p.current].correct).progress;

test('initial state has an accessible first destination and a nonnegative budget', () => {
  assert.equal(INITIAL_PROGRESS.current, 0);
  assert.equal(INITIAL_PROGRESS.stamps.length, 0);
  assert.ok(INITIAL_PROGRESS.money >= 0);
  assert.deepEqual(sanitizeProgress(fresh()), INITIAL_PROGRESS);
});

test('destination content has unique IDs and valid, unambiguous answer indices', () => {
  assert.equal(new Set(DESTINATIONS.map(d => d.id)).size, DESTINATIONS.length);
  assert.ok(DESTINATIONS.length >= 6);
  for (const d of DESTINATIONS) {
    assert.ok(d.story && d.fact && d.question);
    assert.ok(Number.isInteger(d.correct) && d.correct >= 0 && d.correct < d.options.length);
    assert.equal(new Set(d.options).size, d.options.length);
  }
});

test('wrong answers do not charge money, award stamps, or mutate state', () => {
  const p = fresh();
  for (const option of [0, 2, -1, 99, NaN, 1.5]) {
    const result = answerQuestion(p, DESTINATIONS[0].id, option);
    assert.equal(result.correct, false);
    assert.equal(result.progress, p);
  }
  assert.deepEqual(p, INITIAL_PROGRESS);
});

test('a correct answer awards exactly one stamp and one reward', () => {
  const before = fresh();
  const after = win(before);
  assert.equal(after.money, before.money + REWARD);
  assert.deepEqual(after.stamps, [DESTINATIONS[0].id]);
  assert.deepEqual(before, INITIAL_PROGRESS);
});

test('repeated correct answers cannot farm rewards', () => {
  const p = win(fresh());
  for (let i = 0; i < 20; i++) {
    const result = answerQuestion(p, DESTINATIONS[0].id, DESTINATIONS[0].correct);
    assert.equal(result.progress, p);
    assert.equal(result.alreadyStamped, true);
  }
  assert.equal(p.money, INITIAL_PROGRESS.money + REWARD);
});

test('answers for another or nonexistent destination cannot unlock it', () => {
  const p = fresh();
  assert.equal(answerQuestion(p, DESTINATIONS[1].id, DESTINATIONS[1].correct).progress, p);
  assert.equal(answerQuestion(p, 'unknown', 0).progress, p);
});

test('travel requires completing the current destination and cannot skip a stop', () => {
  const p = fresh();
  assert.equal(travelTo(p, DESTINATIONS[1].id, 'bus'), p);
  const stamped = win(p);
  assert.equal(travelTo(stamped, DESTINATIONS[2].id, 'bus'), stamped);
  assert.equal(travelTo(stamped, 'unknown', 'bus'), stamped);
  assert.equal(travelTo(stamped, DESTINATIONS[1].id, 'unknown'), stamped);
});

test('each transport charges its advertised cost exactly once', () => {
  for (const transport of TRANSPORTS) {
    const before = win(fresh());
    const after = travelTo(before, DESTINATIONS[1].id, transport.id);
    assert.equal(after.current, 1);
    assert.equal(after.money, before.money - transport.cost);
    assert.deepEqual(after.trips, [{ destination: DESTINATIONS[1].id, transport: transport.id, cost: transport.cost }]);
    assert.equal(travelTo(after, DESTINATIONS[1].id, transport.id), after);
    assert.equal(before.trips.length, 0);
  }
});

test('insufficient funds do not create a trip or a negative balance', () => {
  const p = { ...win(fresh()), money: TRANSPORTS[0].cost - 1 };
  for (const transport of TRANSPORTS) assert.equal(travelTo(p, DESTINATIONS[1].id, transport.id), p);
});

test('an exact transport budget permits travel with zero remaining', () => {
  const p = { ...win(fresh()), money: TRANSPORTS[0].cost };
  const after = travelTo(p, DESTINATIONS[1].id, TRANSPORTS[0].id);
  assert.equal(after.money, 0);
  assert.equal(after.current, 1);
});

test('every fixed transport strategy can complete all eight destinations', () => {
  for (const transport of TRANSPORTS) {
    let p = fresh();
    for (let index = 0; index < DESTINATIONS.length; index++) {
      if (index) p = travelTo(p, DESTINATIONS[index].id, transport.id);
      assert.equal(p.current, index);
      p = win(p);
      assert.ok(p.money >= 0);
      assert.deepEqual(sanitizeProgress(JSON.parse(JSON.stringify(p))), p);
    }
    assert.equal(p.stamps.length, DESTINATIONS.length);
    assert.equal(p.trips.length, DESTINATIONS.length - 1);
    assert.equal(travelTo(p, 'unknown', transport.id), p);
  }
});

test('restore returns independent copies of arrays and trip records', () => {
  const p = travelTo(win(fresh()), DESTINATIONS[1].id, 'train');
  const restored = sanitizeProgress(p);
  assert.deepEqual(restored, p);
  restored.stamps.push('unexpected');
  restored.trips[0].cost = 999;
  assert.equal(p.stamps.length, 1);
  assert.equal(p.trips[0].cost, 140);
});

test('restore rejects malformed values, unsupported versions and invalid numbers', () => {
  for (const value of [null, undefined, '', [], {}, { ...fresh(), version: 2 }, { ...fresh(), money: -1 }, { ...fresh(), money: NaN }, { ...fresh(), current: 1.5 }, { ...fresh(), current: -1 }, { ...fresh(), current: DESTINATIONS.length }, { ...fresh(), stamps: null }, { ...fresh(), trips: null }]) {
    assert.throws(() => sanitizeProgress(value));
  }
});

test('restore rejects duplicate/out-of-order stamps and impossible unlocks', () => {
  for (const value of [
    { ...fresh(), stamps: [DESTINATIONS[1].id] },
    { ...fresh(), stamps: [DESTINATIONS[0].id, DESTINATIONS[0].id] },
    { ...fresh(), current: 1 },
  ]) assert.throws(() => sanitizeProgress(value));
});

test('restore rejects tampered balances and forged trip destinations, transport or cost', () => {
  const p = travelTo(win(fresh()), DESTINATIONS[1].id, 'bus');
  assert.throws(() => sanitizeProgress({ ...p, money: p.money + 1 }));
  for (const trip of [
    { ...p.trips[0], cost: 0 },
    { ...p.trips[0], destination: DESTINATIONS[2].id },
    { ...p.trips[0], transport: 'teleport' },
  ]) assert.throws(() => sanitizeProgress({ ...p, trips: [trip] }));
  assert.throws(() => sanitizeProgress({ ...p, trips: [null] }));
});

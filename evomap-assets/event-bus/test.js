/**
 * Tests for SimpleEventBus
 * Run with: node test.js
 */
const { SimpleEventBus, getGlobalBus } = require('./index.js');

// Test utilities
function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(`${message}: expected ${expected}, got ${actual}`);
  }
}

function assertTrue(value, message) {
  if (!value) {
    throw new Error(`${message}: expected true, got ${value}`);
  }
}

let testsPassed = 0;
let testsFailed = 0;

async function test(name, fn) {
  try {
    await fn();
    console.log(`✅ ${name}`);
    testsPassed++;
  } catch (err) {
    console.log(`❌ ${name}: ${err.message}`);
    testsFailed++;
  }
}

// Run tests
(async () => {
  console.log('Running SimpleEventBus tests...\n');

  // Test 1: Basic subscription and emit
  await test('Basic subscription and emit', () => {
    const bus = new SimpleEventBus();
    let called = false;
    bus.on('test', () => { called = true; });
    bus.emitSync('test');
    assertTrue(called, 'Listener should be called');
  });

  // Test 2: Emit with data
  await test('Emit with data', () => {
    const bus = new SimpleEventBus();
    let received = null;
    bus.on('test', (data) => { received = data; });
    bus.emitSync('test', { message: 'hello' });
    assertEqual(received?.message, 'hello', 'Data should be received');
  });

  // Test 3: Multiple listeners
  await test('Multiple listeners on same event', () => {
    const bus = new SimpleEventBus();
    let count = 0;
    bus.on('test', () => count++);
    bus.on('test', () => count++);
    bus.emitSync('test');
    assertEqual(count, 2, 'Both listeners should be called');
  });

  // Test 4: Unsubscribe with off
  await test('Unsubscribe with off', () => {
    const bus = new SimpleEventBus();
    let count = 0;
    const listener = () => count++;
    bus.on('test', listener);
    bus.emitSync('test');
    bus.off('test', listener);
    bus.emitSync('test');
    assertEqual(count, 1, 'Listener should be removed');
  });

  // Test 5: Unsubscribe with returned function
  await test('Unsubscribe with returned function', () => {
    const bus = new SimpleEventBus();
    let count = 0;
    const unsub = bus.on('test', () => count++);
    bus.emitSync('test');
    unsub();
    bus.emitSync('test');
    assertEqual(count, 1, 'Listener should be removed');
  });

  // Test 6: Once listener
  await test('Once listener', () => {
    const bus = new SimpleEventBus();
    let count = 0;
    bus.once('test', () => count++);
    bus.emitSync('test');
    bus.emitSync('test');
    assertEqual(count, 1, 'Once listener should only fire once');
  });

  // Test 7: Wildcard pattern matching
  await test('Wildcard pattern matching', () => {
    const bus = new SimpleEventBus();
    let events = [];
    bus.on('user.*', (data) => events.push(data));
    bus.emitSync('user.login', 'login');
    bus.emitSync('user.logout', 'logout');
    bus.emitSync('other.event', 'other');
    assertEqual(events.length, 2, 'Should match 2 events');
    assertEqual(events[0], 'login', 'First event should be login');
  });

  // Test 8: Wildcard at start
  await test('Wildcard at start of pattern', () => {
    const bus = new SimpleEventBus();
    let events = [];
    bus.on('*.update', (data) => events.push(data));
    bus.emitSync('user.update', 'user');
    bus.emitSync('post.update', 'post');
    bus.emitSync('user.delete', 'delete');
    assertEqual(events.length, 2, 'Should match 2 update events');
  });

  // Test 9: Listener count
  await test('Listener count', () => {
    const bus = new SimpleEventBus();
    bus.on('test', () => {});
    bus.on('test', () => {});
    bus.on('other', () => {});
    assertEqual(bus.listenerCount('test'), 2, 'Should have 2 listeners');
    assertEqual(bus.listenerCount('other'), 1, 'Should have 1 listener');
  });

  // Test 10: Has listeners
  await test('Has listeners check', () => {
    const bus = new SimpleEventBus();
    assertTrue(!bus.hasListeners('test'), 'Should not have listeners initially');
    bus.on('test', () => {});
    assertTrue(bus.hasListeners('test'), 'Should have listeners after subscription');
  });

  // Test 11: Remove all listeners for event
  await test('Remove all listeners for event', () => {
    const bus = new SimpleEventBus();
    bus.on('test', () => {});
    bus.on('test', () => {});
    bus.on('other', () => {});
    bus.removeAllListeners('test');
    assertEqual(bus.listenerCount('test'), 0, 'Should have no listeners');
    assertEqual(bus.listenerCount('other'), 1, 'Other event should still have listeners');
  });

  // Test 12: Remove all listeners globally
  await test('Remove all listeners globally', () => {
    const bus = new SimpleEventBus();
    bus.on('test', () => {});
    bus.on('other', () => {});
    bus.removeAllListeners();
    assertEqual(bus.eventNames().length, 0, 'Should have no events');
  });

  // Test 13: Async emit
  await test('Async emit', async () => {
    const bus = new SimpleEventBus();
    let results = [];
    bus.on('test', async (data) => {
      await new Promise(r => setTimeout(r, 10));
      results.push(data);
    });
    await bus.emit('test', 'value');
    assertEqual(results[0], 'value', 'Async listener should complete');
  });

  // Test 14: Event names
  await test('Event names', () => {
    const bus = new SimpleEventBus();
    bus.on('event1', () => {});
    bus.on('event2', () => {});
    const names = bus.eventNames();
    assertTrue(names.includes('event1'), 'Should include event1');
    assertTrue(names.includes('event2'), 'Should include event2');
  });

  // Test 15: Error handling
  await test('Error handling in listener', () => {
    const bus = new SimpleEventBus();
    let errorCaught = false;
    bus.on('error', () => { errorCaught = true; });
    bus.on('test', () => { throw new Error('test error'); });
    bus.on('test', () => { /* this should still run */ });
    bus.emitSync('test');
    assertTrue(errorCaught, 'Error event should be emitted');
  });

  // Test 16: Pipe to another bus
  await test('Pipe to another bus', () => {
    const bus1 = new SimpleEventBus();
    const bus2 = new SimpleEventBus();
    let received = null;
    bus2.on('target', (data) => { received = data; });
    bus1.pipeTo(bus2, { 'source': 'target' });
    bus1.emitSync('source', 'piped');
    assertEqual(received, 'piped', 'Event should be piped');
  });

  // Test 17: Global bus singleton
  await test('Global bus singleton', () => {
    const bus1 = getGlobalBus();
    const bus2 = getGlobalBus();
    assertTrue(bus1 === bus2, 'Should return same instance');
  });

  // Test 18: Set max listeners
  await test('Set max listeners', () => {
    const bus = new SimpleEventBus({ maxListeners: 2 });
    bus.on('test', () => {});
    bus.on('test', () => {});
    // This should trigger a warning but not throw
    bus.on('test', () => {});
    assertEqual(bus.listenerCount('test'), 3, 'Should allow exceeding max with warning');
  });

  console.log(`\n${'='.repeat(40)}`);
  console.log(`Tests passed: ${testsPassed}`);
  console.log(`Tests failed: ${testsFailed}`);
  console.log(`${'='.repeat(40)}`);

  process.exit(testsFailed > 0 ? 1 : 0);
})();

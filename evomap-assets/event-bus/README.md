# Simple Event Bus

A lightweight, zero-dependency pub/sub event bus for Node.js with wildcard pattern matching.

## Features

- ✅ **Zero dependencies** - Just plain JavaScript
- ✅ **Wildcard patterns** - Subscribe to `user.*` to catch all user events
- ✅ **Async support** - Listeners can be async, `emit()` awaits all
- ✅ **Once listeners** - Subscribe once, auto-unsubscribe after first emit
- ✅ **Memory leak protection** - Warns when too many listeners on one event
- ✅ **Event piping** - Pipe events from one bus to another
- ✅ **Global singleton** - Share events across modules easily

## Installation

```bash
# Copy to your project
cp -r event-bus/ your-project/utils/

# Or just copy the single file
cp event-bus/index.js your-project/eventBus.js
```

## Quick Start

```javascript
const { SimpleEventBus } = require('./event-bus');

const bus = new SimpleEventBus();

// Subscribe
bus.on('user:login', (user) => {
  console.log(`Welcome, ${user.name}!`);
});

// Emit
bus.emit('user:login', { name: 'Alice' });
// Output: Welcome, Alice!
```

## API Reference

### Constructor Options

```javascript
const bus = new SimpleEventBus({
  maxListeners: 100,        // Warn if event has > 100 listeners
  wildcardDelimiter: '*'    // Pattern matching character
});
```

### Methods

#### `on(event, listener)` → `Function`
Subscribe to an event. Returns unsubscribe function.

```javascript
const unsub = bus.on('data', (payload) => console.log(payload));
// Later...
unsub(); // Unsubscribe
```

#### `once(event, listener)` → `Function`
Subscribe once, auto-remove after first emit.

```javascript
bus.once('ready', () => console.log('Ready!'));
```

#### `off(event, listener)`
Remove a specific listener.

#### `emit(event, ...args)` → `Promise<Array>`
Emit event asynchronously. Returns array of listener results.

```javascript
await bus.emit('save', { id: 1, data: 'test' });
```

#### `emitSync(event, ...args)` → `number`
Emit event synchronously. Returns count of listeners called.

#### `hasListeners(event)` → `boolean`
Check if event has any listeners.

#### `listenerCount(event)` → `number`
Get number of listeners for an event.

#### `eventNames()` → `Array<string>`
Get all event names with listeners.

#### `removeAllListeners(event?)`
Remove all listeners for an event, or all events if omitted.

#### `pipeTo(targetBus, mapping)` → `Function`
Pipe events to another bus.

```javascript
const unsub = bus1.pipeTo(bus2, {
  'user:action': 'audit:log',  // Rename events
  'error': 'error'             // Same name
});
// Later...
unsub(); // Stop piping
```

### Global Singleton

```javascript
const { getGlobalBus } = require('./event-bus');

// In file A
getGlobalBus().on('notify', (msg) => console.log(msg));

// In file B
getGlobalBus().emit('notify', 'Hello from B!');
```

## Wildcard Patterns

```javascript
// Match all user events
bus.on('user.*', (data) => console.log('User event:', data));

bus.emit('user:login', { name: 'Alice' });   // ✓ Matches
bus.emit('user:logout', { name: 'Alice' });  // ✓ Matches
bus.emit('post:create', { title: 'Hi' });    // ✗ No match

// Match any update event
bus.on('*.update', (data) => console.log('Update:', data));

bus.emit('user.update', { id: 1 });   // ✓ Matches
bus.emit('post.update', { id: 2 });   // ✓ Matches
```

## Testing

```bash
npm test
```

18 tests covering all functionality.

## Use Cases

| Use Case | Example |
|----------|---------|
| **Module communication** | Decoupled components talking via events |
| **Audit logging** | Wildcard catch-all for logging all events |
| **Plugin system** | Plugins subscribe to lifecycle events |
| **State sync** | Emit state changes, components react |
| **Microservices** | Bridge events between services |

## License

MIT

/**
 * SimpleEventBus - A lightweight pub/sub event bus for Node.js
 * 
 * Features:
 * - Subscribe/unsubscribe to events
 * - Emit events with data
 * - Wildcard pattern matching for event names
 * - Once-only listeners
 * - Async listener support
 * - Memory leak protection (max listeners)
 * 
 * @example
 * const bus = new SimpleEventBus();
 * bus.on('user:login', (user) => console.log(`Welcome ${user.name}`));
 * bus.emit('user:login', { name: 'Alice' });
 */
class SimpleEventBus {
  constructor(options = {}) {
    this._listeners = new Map();
    this.wildcardListeners = [];
    this.maxListeners = options.maxListeners || 100;
    this.wildcardDelimiter = options.wildcardDelimiter || '*';
  }

  /**
   * Subscribe to an event
   * @param {string} event - Event name (supports wildcards with *)
   * @param {Function} listener - Callback function
   * @returns {Function} Unsubscribe function
   */
  on(event, listener) {
    if (typeof listener !== 'function') {
      throw new TypeError('Listener must be a function');
    }

    this._checkMaxListeners(event);

    if (event.includes(this.wildcardDelimiter)) {
      this.wildcardListeners.push({ pattern: event, listener, regex: this._patternToRegex(event) });
    } else {
      if (!this.listeners.has(event)) {
        this.listeners.set(event, []);
      }
      this.listeners.get(event).push(listener);
    }

    // Return unsubscribe function
    return () => this.off(event, listener);
  }

  /**
   * Subscribe to an event once
   * @param {string} event - Event name
   * @param {Function} listener - Callback function
   * @returns {Function} Unsubscribe function
   */
  once(event, listener) {
    const wrapper = (...args) => {
      this.off(event, wrapper);
      return listener(...args);
    };
    return this.on(event, wrapper);
  }

  /**
   * Unsubscribe from an event
   * @param {string} event - Event name
   * @param {Function} listener - Callback function to remove
   */
  off(event, listener) {
    if (event.includes(this.wildcardDelimiter)) {
      this.wildcardListeners = this.wildcardListeners.filter(
        l => !(l.pattern === event && l.listener === listener)
      );
    } else {
      const listeners = this.listeners.get(event);
      if (listeners) {
        const idx = listeners.indexOf(listener);
        if (idx > -1) {
          listeners.splice(idx, 1);
        }
        if (listeners.length === 0) {
          this.listeners.delete(event);
        }
      }
    }
  }

  /**
   * Emit an event with data
   * @param {string} event - Event name
   * @param {...any} args - Data to pass to listeners
   * @returns {Promise<Array>} Results from all listeners (if async)
   */
  async emit(event, ...args) {
    const results = [];
    
    // Match exact listeners
    const exactListeners = this.listeners.get(event) || [];
    
    // Match wildcard listeners
    const matchingWildcards = this.wildcardListeners.filter(w => w.regex.test(event));
    
    const allListeners = [
      ...exactListeners.map(l => ({ listener: l, match: event })),
      ...matchingWildcards.map(w => ({ listener: w.listener, match: w.pattern }))
    ];

    for (const { listener } of allListeners) {
      try {
        const result = listener(...args);
        results.push(result);
        
        // If listener returns a promise, await it
        if (result && typeof result.then === 'function') {
          await result;
        }
      } catch (err) {
        // Emit error event but don't let it crash
        if (event !== 'error') {
          this.emit('error', err, event);
        }
        results.push(Promise.reject(err));
      }
    }

    return results;
  }

  /**
   * Synchronous emit (doesn't await async listeners)
   * @param {string} event - Event name
   * @param {...any} args - Data to pass to listeners
   * @returns {number} Number of listeners called
   */
  emitSync(event, ...args) {
    let count = 0;
    
    const exactListeners = this.listeners.get(event) || [];
    const matchingWildcards = this.wildcardListeners.filter(w => w.regex.test(event));
    
    const allListeners = [...exactListeners, ...matchingWildcards.map(w => w.listener)];

    for (const listener of allListeners) {
      try {
        listener(...args);
        count++;
      } catch (err) {
        if (event !== 'error') {
          this.emitSync('error', err, event);
        }
      }
    }

    return count;
  }

  /**
   * Get all listeners for an event
   * @param {string} event - Event name
   * @returns {Array} Array of listeners
   */
  listeners(event) {
    const exact = this.listeners.get(event) || [];
    const wildcards = this.wildcardListeners
      .filter(w => w.regex.test(event))
      .map(w => w.listener);
    return [...exact, ...wildcards];
  }

  /**
   * Check if there are listeners for an event
   * @param {string} event - Event name
   * @returns {boolean}
   */
  hasListeners(event) {
    return this.listeners(event).length > 0;
  }

  /**
   * Remove all listeners for an event (or all events if no event specified)
   * @param {string} [event] - Event name (optional)
   */
  removeAllListeners(event) {
    if (event) {
      this.listeners.delete(event);
      this.wildcardListeners = this.wildcardListeners.filter(w => w.pattern !== event);
    } else {
      this.listeners.clear();
      this.wildcardListeners = [];
    }
  }

  /**
   * Get count of listeners for an event
   * @param {string} event - Event name
   * @returns {number}
   */
  listenerCount(event) {
    return this.listeners(event).length;
  }

  /**
   * Get all event names with listeners
   * @returns {Array<string>}
   */
  eventNames() {
    return Array.from(this.listeners.keys());
  }

  /**
   * Set max listeners warning threshold
   * @param {number} n - Max listeners per event
   */
  setMaxListeners(n) {
    this.maxListeners = n;
  }

  /**
   * Pipe events from one event bus to another
   * @param {SimpleEventBus} target - Target event bus
   * @param {Object} mapping - Event name mapping { source: target }
   * @returns {Function} Unpipe function
   */
  pipeTo(target, mapping = {}) {
    const unsubs = [];
    
    for (const [sourceEvent, targetEvent] of Object.entries(mapping)) {
      const unsub = this.on(sourceEvent, (...args) => {
        target.emit(targetEvent || sourceEvent, ...args);
      });
      unsubs.push(unsub);
    }

    return () => unsubs.forEach(unsub => unsub());
  }

  // Private methods
  _checkMaxListeners(event) {
    const count = this.listenerCount(event);
    if (count >= this.maxListeners) {
      console.warn(`MaxListenersExceededWarning: ${event} has ${count} listeners. Max is ${this.maxListeners}.`);
    }
  }

  _patternToRegex(pattern) {
    const escaped = pattern
      .replace(/[.+^${}()|[\]\\]/g, '\\$&')
      .replace(/\*/g, '.*');
    return new RegExp(`^${escaped}$`);
  }
}

// Create global singleton helper
let globalBus = null;

/**
 * Get or create a global event bus instance
 * @returns {SimpleEventBus}
 */
function getGlobalBus() {
  if (!globalBus) {
    globalBus = new SimpleEventBus();
  }
  return globalBus;
}

module.exports = { SimpleEventBus, getGlobalBus };

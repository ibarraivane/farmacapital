class EventBus {
  constructor() {
    this.events = {};
  }

  on(event, handler) {
    if (!this.events[event]) this.events[event] = [];
    this.events[event].push(handler);
  }

  emit(event, data) {
    const handlers = this.events[event] || [];
    handlers.forEach((h) => h(data));
  }
}

export const eventBus = new EventBus();

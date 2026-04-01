/**
 * Performance Monitoring Utilities
 * Track Core Web Vitals and custom metrics
 */

// Web Vitals types
interface WebVitals {
  FCP?: number; // First Contentful Paint
  LCP?: number; // Largest Contentful Paint
  FID?: number; // First Input Delay
  CLS?: number; // Cumulative Layout Shift
  TTFB?: number; // Time to First Byte
}

// Performance observer for Core Web Vitals
export function observeWebVitals(callback: (metric: WebVitals) => void) {
  const vitals: WebVitals = {};
  
  // First Contentful Paint
  new PerformanceObserver((list) => {
    const entries = list.getEntries();
    const fcp = entries[entries.length - 1];
    vitals.FCP = fcp.startTime;
    callback({ ...vitals });
  }).observe({ entryTypes: ['paint'] });
  
  // Largest Contentful Paint
  new PerformanceObserver((list) => {
    const entries = list.getEntries();
    const lastEntry = entries[entries.length - 1] as any;
    vitals.LCP = lastEntry.startTime;
    callback({ ...vitals });
  }).observe({ entryTypes: ['largest-contentful-paint'] });
  
  // First Input Delay
  new PerformanceObserver((list) => {
    const firstEntry = list.getEntries()[0] as any;
    vitals.FID = firstEntry.processingStart - firstEntry.startTime;
    callback({ ...vitals });
  }).observe({ entryTypes: ['first-input'] });
  
  // Layout Shift
  let clsValue = 0;
  new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      const layoutShift = entry as any;
      if (!layoutShift.hadRecentInput) {
        clsValue += layoutShift.value;
      }
    }
    vitals.CLS = clsValue;
    callback({ ...vitals });
  }).observe({ entryTypes: ['layout-shift'] });
  
  // Time to First Byte
  const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
  if (navigation) {
    vitals.TTFB = navigation.responseStart - navigation.startTime;
    callback({ ...vitals });
  }
  
  return vitals;
}

// Measure component render time
export function measureRenderTime(componentName: string) {
  const startMark = `${componentName}-start`;
  const endMark = `${componentName}-end`;
  
  return {
    start: () => performance.mark(startMark),
    end: () => {
      performance.mark(endMark);
      performance.measure(
        `${componentName}-render`,
        startMark,
        endMark
      );
      const measure = performance.getEntriesByName(`${componentName}-render`)[0];
      console.log(`${componentName} rendered in ${measure.duration.toFixed(2)}ms`);
    },
  };
}

// Measure API call performance
export function measureAPICall(endpoint: string) {
  const startTime = performance.now();
  
  return {
    end: (success: boolean = true) => {
      const duration = performance.now() - startTime;
      console.log(`API ${endpoint}: ${duration.toFixed(2)}ms ${success ? '✓' : '✗'}`);
      
      // Send to analytics
      if (window.gtag) {
        window.gtag('event', 'api_timing', {
          event_category: 'Performance',
          event_label: endpoint,
          value: Math.round(duration),
        });
      }
    },
  };
}

// Report metrics to analytics
export function reportMetrics(vitals: WebVitals) {
  // Google Analytics 4
  if (window.gtag) {
    Object.entries(vitals).forEach(([metric, value]) => {
      if (value !== undefined) {
        window.gtag('event', 'web_vitals', {
          event_category: 'Web Vitals',
          event_label: metric,
          value: Math.round(value),
        });
      }
    });
  }
  
  // Log to console in development
  if (import.meta.env.DEV) {
    console.table(vitals);
  }
}

// Performance budget checker
export function checkPerformanceBudget(
  metric: keyof WebVitals,
  value: number,
  budgets: Record<keyof WebVitals, number> = {
    FCP: 1800,
    LCP: 2500,
    FID: 100,
    CLS: 0.1,
    TTFB: 600,
  }
) {
  const budget = budgets[metric];
  const passed = value <= budget;
  
  if (!passed) {
    console.warn(
      `⚠️ Performance budget exceeded: ${metric} = ${value.toFixed(2)}ms (budget: ${budget}ms)`
    );
  }
  
  return passed;
}

// Resource loading tracker
export function trackResourceLoading() {
  return new Promise<PerformanceResourceTiming[]>((resolve) => {
    const observer = new PerformanceObserver((list) => {
      const resources = list.getEntries() as PerformanceResourceTiming[];
      resolve(resources);
      observer.disconnect();
    });
    
    observer.observe({ entryTypes: ['resource'] });
    
    // Timeout after 10 seconds
    setTimeout(() => {
      observer.disconnect();
      resolve([]);
    }, 10000);
  });
}

// Export to window for debugging
declare global {
  interface Window {
    performanceMetrics: {
      observe: typeof observeWebVitals;
      measureRender: typeof measureRenderTime;
      measureAPI: typeof measureAPICall;
      report: typeof reportMetrics;
      checkBudget: typeof checkPerformanceBudget;
    };
    gtag?: (...args: any[]) => void;
  }
}

// Make available globally
if (typeof window !== 'undefined') {
  window.performanceMetrics = {
    observe: observeWebVitals,
    measureRender: measureRenderTime,
    measureAPI: measureAPICall,
    report: reportMetrics,
    checkBudget: checkPerformanceBudget,
  };
}

import React, { Suspense, lazy, ComponentType } from 'react';
import { Skeleton } from '@/components/ui/Skeleton';

// Loading fallback component
export const PageLoader = () => (
  <div className="flex items-center justify-center min-h-screen">
    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
  </div>
);

// Component loader with skeleton
export const ComponentLoader = () => (
  <div className="space-y-4 p-4">
    <Skeleton className="h-8 w-3/4" />
    <Skeleton className="h-4 w-full" />
    <Skeleton className="h-4 w-5/6" />
    <Skeleton className="h-4 w-4/5" />
  </div>
);

// Lazy load a component with automatic loading state
export function lazyLoad<T extends ComponentType<any>>(
  importFunc: () => Promise<{ default: T }>,
  fallback?: React.ReactNode
) {
  const LazyComponent = lazy(importFunc);
  
  return function LazyWrapper(props: React.ComponentProps<T>) {
    return (
      <Suspense fallback={fallback || <ComponentLoader />}>
        <LazyComponent {...props} />
      </Suspense>
    );
  };
}

// Lazy load with retry on error
export function lazyLoadWithRetry<T extends ComponentType<any>>(
  importFunc: () => Promise<{ default: T }>,
  retries = 3,
  fallback?: React.ReactNode
) {
  const LazyComponent = lazy(() => retryImport(importFunc, retries));
  
  return function LazyWrapper(props: React.ComponentProps<T>) {
    return (
      <Suspense fallback={fallback || <ComponentLoader />}>
        <LazyComponent {...props} />
      </Suspense>
    );;
  };
}

// Retry helper for failed imports
async function retryImport<T>(
  importFunc: () => Promise<T>,
  retries: number
): Promise<T> {
  try {
    return await importFunc();
  } catch (error) {
    if (retries > 0) {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return retryImport(importFunc, retries - 1);
    }
    throw error;
  }
}

// Preload component (call on hover/intent)
export function preloadComponent<T>(
  importFunc: () => Promise<T>
) {
  return () => {
    importFunc();
  };
}

// Usage examples:

// 1. Lazy load a page component
// const DashboardPage = lazyLoad(() => import('./pages/Dashboard'));

// 2. Lazy load with custom fallback
// const HeavyChart = lazyLoad(
//   () => import('./components/HeavyChart'),
//   <CustomLoadingSpinner />
// );

// 3. Lazy load routes
// const routes = [
//   {
//     path: '/dashboard',
//     component: lazyLoad(() => import('./pages/Dashboard'))
//   },
//   {
//     path: '/settings',
//     component: lazyLoad(() => import('./pages/Settings'))
//   }
// ];

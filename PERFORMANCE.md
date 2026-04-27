# Performance Overview

This document outlines the performance considerations and optimization strategies applied in the system.

## 1. Rendering 1,000+ Tasks Without UI Lag

To support large task volumes, the system is designed to minimize rebuilds and avoid unnecessary widget work.

Rendering Strategy

- Use ListView.builder for lazy rendering
    - Only visible items are built
    - Off-screen items are not rendered
- Each column is isolated using buildWhen
    - Only the affected column rebuilds
    - Prevents full board re-renders during drag or updates
- Avoid setState at high-level widgets
    - All updates flow through BLoC

Widget Optimization

- Task items are lightweight (StatelessWidget)
- Avoid deep widget nesting
- Reuse widgets (no duplication of layout logic)

Reordering Optimization

- Use precomputed layout bounds (GlobalKey)
- Map pointer position → index directly (O(n), small n per column)
- Avoid sorting or full list rebuilds

Drag Optimization

- Dragged item rendered in overlay (Stack)
- Original item hidden via opacity
- Prevents layout shift and expensive recalculation

Scaling Strategy (Future)

For very large datasets:

- Introduce pagination or infinite scroll
- Virtualize columns (only render active viewport)
- Cache previously built widgets if needed

## 2. Memory Management for Large Files & Image Previews

Handling document uploads and previews efficiently is critical to avoid memory pressure.

File Handling Strategy

- Avoid loading entire file into memory
- Use stream-based upload (chunking in production)
- Process files in parts instead of full buffering

Image Optimization

- Resize/compress images before preview
- Use Image.file with cache constraints:
    - cacheWidth
    - cacheHeight

This reduces:

- Memory usage
- GPU load

Caching Strategy
- Use Flutter’s built-in image cache carefully
- Clear unused images when necessary:
    PaintingBinding.instance.imageCache.clear();

Temporary Storage
- Store files in temporary directory
- Clean up after upload completes or fails
- Prevents disk bloat and memory leaks

Large File Safeguards

- Set size limits (e.g., max 10–20MB per file)
- Provide user feedback before processing large files


## 3. Performance Measurement & Profiling

Performance is validated using Flutter’s profiling tools and runtime metrics.

Tools Used

- Flutter DevTools
    - Frame rendering timeline
    - CPU profiler
    - Memory usage tracking
- Performance Overlay
    - Enabled via WidgetsApp.showPerformanceOverlay
    - Monitors UI and raster thread performance
- Dart DevTools Memory Tab
    - Detect memory leaks
    - Monitor heap growth

Key Metrics
- Frame Time
    - Target: < 16ms per frame (60 FPS)
    - Ensures smooth animations and interactions
- Jank (Dropped Frames)
    - Target: 0 dropped frames during drag/reorder
- Memory Usage
    - Stable memory footprint during document upload
    - No continuous heap growth
- Build Time
    - Minimized widget rebuild cost
    - Verified using DevTools timeline
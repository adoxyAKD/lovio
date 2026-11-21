import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovio/features/creation/domain/entities/page_document.dart';
import 'package:lovio/features/creation/presentation/view_models/page_editor_view_model.dart';

void main() {
  group('PageEditorViewModel - Resizing, Rotation & Alignment Tests', () {
    late ProviderContainer container;
    late PageEditorNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(pageEditorProvider.notifier);
      notifier.startNewPage(
        title: 'Anniversary Love',
        message: 'Forever and always in my heart',
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial page contains message text element', () {
      final state = container.read(pageEditorProvider);
      expect(state.document.elements.length, 1);
      final textElem = state.document.elements.first;
      expect(textElem.type, PageElementType.text);
      expect(textElem.text, 'Forever and always in my heart');
      expect(textElem.scale, 1.0);
      expect(textElem.rotation, 0.0);
    });

    test('updateElementScaleLive scales smoothly within bounds [0.25, 4.0]', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;

      // Scale up to 2.5x
      notifier.updateElementScaleLive(elemId, 2.5);
      var current = container.read(pageEditorProvider).document.elements.first;
      expect(current.scale, 2.5);

      // Clamp upper bound
      notifier.updateElementScaleLive(elemId, 5.0);
      current = container.read(pageEditorProvider).document.elements.first;
      expect(current.scale, 4.0);

      // Clamp lower bound
      notifier.updateElementScaleLive(elemId, 0.1);
      current = container.read(pageEditorProvider).document.elements.first;
      expect(current.scale, 0.25);
    });

    test('updateElementRotationLive updates rotation angle smoothly', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;

      notifier.updateElementRotationLive(elemId, math.pi / 2);
      final current =
          container.read(pageEditorProvider).document.elements.first;
      expect(current.rotation, closeTo(math.pi / 2, 0.001));
    });

    test('rotateElementStep increments rotation by degrees', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;

      notifier.rotateElementStep(elemId, 45);
      var current = container.read(pageEditorProvider).document.elements.first;
      expect(current.rotation, closeTo(math.pi / 4, 0.001));

      notifier.rotateElementStep(elemId, 45);
      current = container.read(pageEditorProvider).document.elements.first;
      expect(current.rotation, closeTo(math.pi / 2, 0.001));
    });

    test('nudgeElement moves element by precise delta pixels', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;
      final startX = state.document.elements.first.x;
      final startY = state.document.elements.first.y;

      notifier.nudgeElement(elemId, 5.0, -10.0);
      final current =
          container.read(pageEditorProvider).document.elements.first;
      expect(current.x, closeTo(startX + 5.0, 0.001));
      expect(current.y, closeTo(startY - 10.0, 0.001));
    });

    test('alignElementCenterHorizontal centers element on canvas width', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;
      const canvasWidth = 360.0;
      const elementWidth = 200.0;

      notifier.alignElementCenterHorizontal(elemId, canvasWidth, elementWidth);
      final current =
          container.read(pageEditorProvider).document.elements.first;
      // targetX = (360 - 200) / 2 = 80
      expect(current.x, 80.0);
    });

    test('alignElementCenterVertical centers element on canvas height', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;
      const canvasHeight = 600.0;
      const elementHeight = 100.0;

      notifier.alignElementCenterVertical(elemId, canvasHeight, elementHeight);
      final current =
          container.read(pageEditorProvider).document.elements.first;
      // targetY = (600 - 100) / 2 = 250
      expect(current.y, 250.0);
    });

    test('setElementExactPosition snaps position during magnetic alignment', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;

      notifier.setElementExactPosition(elemId, 180.0, 320.0);
      final current =
          container.read(pageEditorProvider).document.elements.first;
      expect(current.x, 180.0);
      expect(current.y, 320.0);
    });

    test('duplicateElement creates independent copy with offset', () {
      final state = container.read(pageEditorProvider);
      final elemId = state.document.elements.first.id;

      notifier.duplicateElement(elemId);
      final elements = container.read(pageEditorProvider).document.elements;
      expect(elements.length, 2);
      expect(elements[1].text, elements[0].text);
      expect(elements[1].x, elements[0].x + 20);
      expect(elements[1].y, elements[0].y + 20);
    });
  });
}

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/data_sources/remote/firebase_creations_remote_data_source.dart';
import '../../domain/entities/creation_document.dart';
import '../../domain/entities/creation_item.dart';
import '../../domain/entities/page_document.dart';
import '../../constants/page_editor_assets.dart';
import 'creations_view_model.dart';

class PageEditorState {
  final PageDocument document;
  final List<PageDocument> undoStack;
  final List<PageDocument> redoStack;
  final String? selectedElementId;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? statusMessage;

  const PageEditorState({
    required this.document,
    this.undoStack = const [],
    this.redoStack = const [],
    this.selectedElementId,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.statusMessage,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  PageElementModel? get selectedElement {
    if (selectedElementId == null) return null;
    try {
      return document.elements.firstWhere((e) => e.id == selectedElementId);
    } catch (_) {
      return null;
    }
  }

  PageEditorState copyWith({
    PageDocument? document,
    List<PageDocument>? undoStack,
    List<PageDocument>? redoStack,
    String? selectedElementId,
    bool clearSelectedElement = false,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? statusMessage,
  }) {
    return PageEditorState(
      document: document ?? this.document,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      selectedElementId: clearSelectedElement
          ? null
          : (selectedElementId ?? this.selectedElementId),
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      statusMessage: statusMessage,
    );
  }
}

final pageEditorProvider =
    StateNotifierProvider<PageEditorNotifier, PageEditorState>((ref) {
  return PageEditorNotifier();
});

class PageEditorNotifier extends StateNotifier<PageEditorState> {
  static const String _draftKey = 'lovio_page_draft_v1';
  final Uuid _uuid = const Uuid();

  PageEditorNotifier()
      : super(
          PageEditorState(
            document: PageDocument(
              id: const Uuid().v4(),
              title: 'Cherished Moment',
              shareToken: const Uuid().v4().substring(0, 8),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              background: const PageBackgroundConfig(
                type: PageBackgroundType.gradient,
                gradientColors: [0xFFFDE8E9, 0xFFE9D8FD],
                animationEffect: BackgroundAnimationEffect.floatingPetals,
              ),
            ),
          ),
        );

  void startNewPage({String? title, String? message}) {
    final pageId = _uuid.v4();
    final token = _uuid.v4().replaceAll('-', '').substring(0, 10);

    final List<PageElementModel> initialElements = [];

    // If initial text/message was supplied in write screen, add as the primary message element
    if (message != null && message.trim().isNotEmpty) {
      initialElements.add(
        PageElementModel(
          id: _uuid.v4(),
          type: PageElementType.text,
          x: 20,
          y: 60,
          text: message.trim(),
          fontFamily: 'Playfair Display',
          fontSize: 20,
          textColor: 0xFF0F172A, // Midnight Navy (Sharp & High Contrast)
          textAlign: 'center',
          isItalic: true,
          zIndex: 1,
        ),
      );
    }

    final now = DateTime.now();
    state = PageEditorState(
      document: PageDocument(
        id: pageId,
        title: (title != null && title.trim().isNotEmpty)
            ? title.trim()
            : 'My Cherished Page',
        writtenMessage: message?.trim() ?? '',
        shareToken: token,
        createdAt: now,
        updatedAt: now,
        elements: initialElements,
        background: const PageBackgroundConfig(
          type: PageBackgroundType.gradient,
          gradientColors: [0xFFF6B8C8, 0xFFEC8FA8],
          animationEffect: BackgroundAnimationEffect.floatingPetals,
        ),
      ),
      undoStack: [],
      redoStack: [],
      hasUnsavedChanges: true,
    );

    // Save initial draft
    saveDraft();
  }

  /// Load an existing document from library or draft without duplicating elements
  void loadDocument(PageDocument doc) {
    // Automatically de-duplicate any repeating identical text elements
    final seenCoords = <String>{};
    final seenTextBodies = <String>{};
    final uniqueElements = <PageElementModel>[];

    for (final elem in doc.elements) {
      if (elem.type == PageElementType.text) {
        final textTrimmed = elem.text?.trim() ?? '';
        if (textTrimmed.isNotEmpty) {
          // If long text (e.g. prompt or written message) was duplicated across elements, keep only the first one
          if (textTrimmed.length > 12 && seenTextBodies.contains(textTrimmed)) {
            continue;
          }
          seenTextBodies.add(textTrimmed);
        }

        final coordKey = '${elem.x.round()}_${elem.y.round()}';
        if (seenCoords.contains(coordKey)) {
          continue;
        }
        seenCoords.add(coordKey);
      }
      uniqueElements.add(elem);
    }

    final cleanedDoc = doc.copyWith(elements: uniqueElements);

    state = PageEditorState(
      document: cleanedDoc,
      undoStack: [],
      redoStack: [],
      hasUnsavedChanges: false,
    );
    saveDraft();
  }

  void _pushHistory() {
    final newUndo = List<PageDocument>.from(state.undoStack)..add(state.document);
    if (newUndo.length > 25) {
      newUndo.removeAt(0);
    }
    state = state.copyWith(
      undoStack: newUndo,
      redoStack: [], // New action clears redo stack
      hasUnsavedChanges: true,
    );
  }

  void undo() {
    if (!state.canUndo) return;
    final newUndo = List<PageDocument>.from(state.undoStack);
    final prevDoc = newUndo.removeLast();
    final newRedo = List<PageDocument>.from(state.redoStack)..add(state.document);

    state = state.copyWith(
      document: prevDoc,
      undoStack: newUndo,
      redoStack: newRedo,
      hasUnsavedChanges: true,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final newRedo = List<PageDocument>.from(state.redoStack);
    final nextDoc = newRedo.removeLast();
    final newUndo = List<PageDocument>.from(state.undoStack)..add(state.document);

    state = state.copyWith(
      document: nextDoc,
      undoStack: newUndo,
      redoStack: newRedo,
      hasUnsavedChanges: true,
    );
  }

  void setTitle(String title) {
    _pushHistory();
    state = state.copyWith(
      document: state.document.copyWith(title: title),
    );
    saveDraft();
  }

  void setWrittenMessage(String message) {
    _pushHistory();
    state = state.copyWith(
      document: state.document.copyWith(writtenMessage: message),
    );
    saveDraft();
  }

  void setBackground(PageBackgroundConfig bg) {
    _pushHistory();
    state = state.copyWith(
      document: state.document.copyWith(background: bg),
    );
    saveDraft();
  }

  void setOpeningStyle(OpeningRevealStyle style) {
    _pushHistory();
    state = state.copyWith(
      document: state.document.copyWith(openingStyle: style),
    );
    saveDraft();
  }

  void selectElement(String? id) {
    state = state.copyWith(
      selectedElementId: id,
      clearSelectedElement: id == null,
    );
  }

  void addElement(PageElementModel element) {
    _pushHistory();
    final newElements = List<PageElementModel>.from(state.document.elements)
      ..add(element);
    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      selectedElementId: element.id,
    );
    saveDraft();
  }

  void addText({
    String text = PageEditorAssets.defaultNewTextElement,
    String fontFamily = 'Playfair Display',
    double fontSize = 18,
    int color = 0xFF0F172A,
  }) {
    final element = PageElementModel(
      id: _uuid.v4(),
      type: PageElementType.text,
      x: 30,
      y: 120 + (state.document.elements.length * 30.0) % 200,
      text: text,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textColor: color,
      zIndex: state.document.elements.length + 1,
    );
    addElement(element);
  }

  void addPhoto(String imagePath, {PhotoShape shape = PhotoShape.roundedRectangle}) {
    final element = PageElementModel(
      id: _uuid.v4(),
      type: PageElementType.photo,
      imagePath: imagePath,
      photoShape: shape,
      x: 40,
      y: 140,
      width: 180,
      height: 180,
      zIndex: state.document.elements.length + 1,
    );
    addElement(element);
  }

  void addSticker(String symbol, {StickerAnimationEffect animation = StickerAnimationEffect.floating}) {
    final element = PageElementModel(
      id: _uuid.v4(),
      type: PageElementType.sticker,
      stickerSymbol: symbol,
      stickerAnimation: animation,
      x: 100 + (state.document.elements.length * 20.0) % 150,
      y: 80 + (state.document.elements.length * 35.0) % 250,
      scale: 1.0,
      zIndex: state.document.elements.length + 1,
    );
    addElement(element);
  }

  void updateElement(String id, PageElementModel Function(PageElementModel) updater) {
    _pushHistory();
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return updater(e);
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
    );
    saveDraft();
  }

  void updateElementPosition(String id, Offset delta) {
    // Note: To avoid saturating undo stack on every micro drag event,
    // we directly mutate position without pushHistory here;
    // calling finishDrag will push history or user can undo discretely.
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(
          x: (e.x + delta.dx).clamp(-50.0, 600.0),
          y: (e.y + delta.dy).clamp(-50.0, 4000.0),
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
  }

  void recordGestureCommit() {
    _pushHistory();
    saveDraft();
  }

  void updateElementScaleLive(String id, double scale) {
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(scale: scale.clamp(0.25, 4.0));
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
  }

  void updateElementRotationLive(String id, double rotation) {
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(rotation: rotation);
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
  }

  void setElementExactPosition(String id, double x, double y) {
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(
          x: x.clamp(-50.0, 600.0),
          y: y.clamp(-50.0, 4000.0),
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
  }

  void alignElementCenterHorizontal(
      String id, double canvasWidth, double elementWidth) {
    _pushHistory();
    final targetX =
        ((canvasWidth - elementWidth) / 2).clamp(10.0, canvasWidth - 10.0);
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(x: targetX);
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
    saveDraft();
  }

  void alignElementCenterVertical(
      String id, double canvasHeight, double elementHeight) {
    _pushHistory();
    final targetY =
        ((canvasHeight - elementHeight) / 2).clamp(20.0, canvasHeight - 20.0);
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(y: targetY);
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
    saveDraft();
  }

  void nudgeElement(String id, double dx, double dy) {
    _pushHistory();
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(
          x: (e.x + dx).clamp(-50.0, 600.0),
          y: (e.y + dy).clamp(-50.0, 4000.0),
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
    saveDraft();
  }

  void rotateElementStep(String id, double angleInDegrees) {
    _pushHistory();
    final radDelta = angleInDegrees * math.pi / 180.0;
    final newElements = state.document.elements.map((e) {
      if (e.id == id) {
        return e.copyWith(rotation: (e.rotation + radDelta) % (2 * math.pi));
      }
      return e;
    }).toList();

    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      hasUnsavedChanges: true,
    );
    saveDraft();
  }

  void updateElementScale(String id, double scale) {
    updateElement(id, (e) => e.copyWith(scale: scale.clamp(0.25, 4.0)));
  }

  void updateElementRotation(String id, double rotation) {
    updateElement(id, (e) => e.copyWith(rotation: rotation));
  }

  void bringToFront(String id) {
    _pushHistory();
    final elements = List<PageElementModel>.from(state.document.elements);
    final idx = elements.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final elem = elements.removeAt(idx);
      elements.add(elem.copyWith(zIndex: elements.length + 1));
      state = state.copyWith(
        document: state.document.copyWith(elements: elements),
      );
      saveDraft();
    }
  }

  void sendToBack(String id) {
    _pushHistory();
    final elements = List<PageElementModel>.from(state.document.elements);
    final idx = elements.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final elem = elements.removeAt(idx);
      elements.insert(0, elem.copyWith(zIndex: 0));
      state = state.copyWith(
        document: state.document.copyWith(elements: elements),
      );
      saveDraft();
    }
  }

  void duplicateElement(String id) {
    _pushHistory();
    final elem = state.document.elements.firstWhere((e) => e.id == id);
    final duplicated = elem.copyWith(
      id: _uuid.v4(),
      x: elem.x + 20,
      y: elem.y + 20,
      zIndex: state.document.elements.length + 1,
    );
    final newElements = List<PageElementModel>.from(state.document.elements)
      ..add(duplicated);
    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      selectedElementId: duplicated.id,
    );
    saveDraft();
  }

  void deleteElement(String id) {
    _pushHistory();
    final newElements =
        state.document.elements.where((e) => e.id != id).toList();
    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
      clearSelectedElement: state.selectedElementId == id,
    );
    saveDraft();
  }

  void clearCanvas() {
    _pushHistory();
    state = state.copyWith(
      document: state.document.copyWith(elements: []),
      clearSelectedElement: true,
    );
    saveDraft();
  }

  void toggleShareable(bool isShareable) {
    state = state.copyWith(
      document: state.document.copyWith(isShareable: isShareable),
    );
    saveDraft();
  }

  // Autosave Draft
  Future<void> saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.document.toJson());
      await prefs.setString(_draftKey, jsonStr);
    } catch (_) {
      // Ignored for draft
    }
  }

  Future<bool> loadDraftIfExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_draftKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final loaded = PageDocument.fromJson(map);
        state = PageEditorState(
          document: loaded,
          undoStack: [],
          redoStack: [],
          hasUnsavedChanges: false,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  // Screen 4: Save to My Library with Local First & Firebase Sync
  Future<bool> saveToLibrary(WidgetRef ref, {bool syncToCloud = true}) async {
    state = state.copyWith(isSaving: true);
    try {
      final doc = state.document.copyWith(
        updatedAt: DateTime.now(),
      );

      final creationDoc = CreationDocument(
        id: doc.id,
        title: doc.title.isNotEmpty ? doc.title : 'My Cherished Page',
        type: CreationType.page,
        content: doc.toJson(),
        createdAt: doc.createdAt,
        updatedAt: DateTime.now(),
        pageCount: 1,
        coverGradientKey: 'primary',
        syncStatus: syncToCloud ? SyncStatus.synced : SyncStatus.localOnly,
      );

      // Save locally into Creations Repository (Instant local-first save)
      final repo = ref.read(creationsRepositoryProvider);
      await repo.saveCreationLocally(creationDoc);

      // Refresh list immediately with local copy
      ref.read(creationsProvider.notifier).loadCreations();

      // Cloud upload in background without blocking UI
      if (syncToCloud) {
        ref
            .read(creationsProvider.notifier)
            .uploadToCloud(creationDoc.id)
            .catchError((_) {});
      }

      state = state.copyWith(
        document: doc,
        isSaving: false,
        hasUnsavedChanges: false,
        statusMessage: 'Saved to My Library successfully! ✨',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        statusMessage: 'Error saving: $e',
      );
      return false;
    }
  }

  // Screen 5: Post to Public Feed
  Future<bool> postToPublicFeed(WidgetRef ref) async {
    state = state.copyWith(isSaving: true);
    try {
      final updated = state.document.copyWith(
        isPostedToFeed: true,
        isShareable: true,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(document: updated);

      // Save locally & sync to cloud
      await saveToLibrary(ref, syncToCloud: true);
      await uploadForSharing();

      state = state.copyWith(
        isSaving: false,
        statusMessage: 'Posted to Lovio Feed successfully! 🌟',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        statusMessage: 'Could not post to feed: $e',
      );
      return false;
    }
  }

  /// Upload the active page to Firebase Realtime Database and Cloud Firestore under its shareToken
  Future<bool> uploadForSharing() async {
    try {
      final doc = state.document;

      // Encode local images to base64 data URI so recipients on web & other phones can view them
      final updatedElements = <PageElementModel>[];
      for (final elem in doc.elements) {
        if (elem.type == PageElementType.photo &&
            elem.imagePath != null &&
            elem.imagePath!.isNotEmpty &&
            !elem.imagePath!.startsWith('http://') &&
            !elem.imagePath!.startsWith('https://') &&
            !elem.imagePath!.startsWith('data:image')) {
          try {
            final file = File(elem.imagePath!);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64String = base64Encode(bytes);
              final mimeType = elem.imagePath!.toLowerCase().endsWith('.png')
                  ? 'image/png'
                  : 'image/jpeg';
              final dataUri = 'data:$mimeType;base64,$base64String';
              updatedElements.add(elem.copyWith(imagePath: dataUri));
              continue;
            }
          } catch (e) {
            debugPrint('Error converting photo to data URI for sharing: $e');
          }
        }
        updatedElements.add(elem);
      }

      final docToUpload = doc.copyWith(elements: updatedElements);
      state = state.copyWith(document: docToUpload);
      saveDraft();
      final body = jsonEncode(docToUpload.toJson());

      // 1. Upload to Firebase Realtime Database at /shared_pages/${doc.shareToken}.json
      final rtdbUrl = Uri.parse(
          '${FirebaseCreationsRemoteDataSource.rtdbBaseUrl}/shared_pages/${doc.shareToken}.json');
      await http
          .put(rtdbUrl,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 10));

      // 2. Also save into Cloud Firestore 'shared_pages' collection
      try {
        if (Firebase.apps.isNotEmpty) {
          final db = FirebaseFirestore.instance;
          await db
              .collection('shared_pages')
              .doc(doc.shareToken)
              .set(docToUpload.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 8));
        }
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('uploadForSharing error: $e');
      return false;
    }
  }
}


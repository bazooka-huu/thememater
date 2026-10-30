import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_maker/models/export_item.dart';
import 'package:theme_maker/models/icon_item.dart';
import 'package:theme_maker/models/resource_type.dart';
import '';
part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());

  void selectItems(List<ResourceType> list) {
    List<ResourceType> items = List.from(state.selectedItems);
    for (ResourceType item in list) {
      if (items.contains(item)) {
        continue;
      } else {
        items.add(item);
      }
    }
    emit(
      state.copyWith(
        selectedItems: items
      )
    );
  }

  void deselectItems(List<ResourceType> list) {
    List<ResourceType> items = List.from(state.selectedItems);
    for (ResourceType item in list) {
      if (items.contains(item)) {
        items.remove(item);
      }
    }
    emit(
      state.copyWith(
        selectedItems: items
      )
    );
  }

  void setPreviewIphoneFile(Uint8List? file) {
    emit(
      state.copyWith(
        previewIphoneFile: file
      )
    );
    if (file != null) {
      selectItems([ResourceType.previewIphone]);
    }
  }

  void setPreviewIpadFile(Uint8List? file) {
    emit(
      state.copyWith(
        previewIpadFile: file,
      )
    );
    if (file != null) {
      selectItems([ResourceType.previewIpad]);
    }
  }

  void setBgIphoneFile(Uint8List? file) {
    emit(
      state.copyWith(
        bgIphoneFile: file
      )
    );
    if (file != null) {
      selectItems([ResourceType.bgIphone]);
    }
  }

  void setBgIpadFile(Uint8List? file) {
    emit(
      state.copyWith(
        bgIpadFile: file
      )
    );
    if (file != null) {
      selectItems([ResourceType.bgIpad]);
    }
  }

  void setLsIphoneFile(Uint8List? file) {
    emit(
      state.copyWith(
        lsIphoneFile: file
      )
    );
    if (file != null) {
      selectItems([ResourceType.lsIphone]);
    }
  }

  void setLsIpadFile(Uint8List? file) {
    emit(
      state.copyWith(
        lsIpadFile: file
      )
    );
    if (file != null) {
      selectItems([ResourceType.lsIpad]);
    }
  }

  void clearIconItems() {
    emit(state.copyWith(
      iconItems: [],
      iconPreviewItems: List<IconItem?>.filled(12, null)
    ));
  }

  void clearIconsPreview() {
    emit(state.copyWith(
      iconPreviewItems: List<IconItem?>.filled(12, null)
    ));
  }

  void addNewIcons(List<IconItem> iconItems) {
    final List<IconItem> items = List.from(state.iconItems);
    for (IconItem item in iconItems) {
      final index = items.indexWhere((e) => e.id == item.id);
      if(index > -1) {
        items[index] = item;
      } else {
        items.add(item);
      }
    }
    items.sort((a,b) => a.id.compareTo(b.id));
    emit(state.copyWith(
      iconItems: items,
    ));
    if (state.iconPreviewItems.every((e) => e == null)) {
      randomIconPreview();
    }
    if (items.isNotEmpty) {
      selectItems([ResourceType.icons, ResourceType.profile]);
    }
  }

  void randomIconPreview() {
    final List<IconItem?> iconItems = List.from(state.iconItems);
    iconItems.shuffle();
    List<IconItem?> iconPreviewItems = List<IconItem?>.generate(
      12, (index) => index < iconItems.length ? iconItems[index] : null,
    );
    emit(state.copyWith(
      iconPreviewItems: iconPreviewItems
    ));
    if (iconPreviewItems.every((e) => e != null)) {
      selectItems([.iconsPreview]);
    }
  }

  void updateIconPreview(List<IconItem?> updated) {
    emit(state.copyWith(
      iconPreviewItems: updated
    ));
  }

  Uint8List? getMediumWidgetFile(int index) {
    switch (index) {
      case 1: return state.mediumWidget1File;
      case 2: return state.mediumWidget2File;
      default: return state.mediumWidget3File;
    }
  }

  Uint8List? getLargeWidgetFile(int index) {
    switch (index) {
      case 1: return state.largeWidget1File;
      case 2: return state.largeWidget2File;
      default: return state.largeWidget3File;
    }
  }

  void setWidgetFile(Uint8List? file, {required ResourceType resourceType}) {
    switch (resourceType) {
      case .mediumWidget1: {
        emit(state.copyWith(mediumWidget1File: file));
        if(file != null) {
          selectItems([.mediumWidget1]);
        }
      }
      case .largeWidget1: {
        emit(state.copyWith(largeWidget1File: file));
        if(file != null) {
          selectItems([.largeWidget1]);
        }
      }
      case .mediumWidget2: {
        emit(state.copyWith(mediumWidget2File: file));
        if(file != null) {
          selectItems([.mediumWidget2]);
        }
      }
      case .largeWidget2: {
        emit(state.copyWith(largeWidget2File: file));
        if(file != null) {
          selectItems([.largeWidget2]);
        }
      }
      case .mediumWidget3: {
        emit(state.copyWith(mediumWidget3File: file));
        if(file != null) {
          selectItems([.mediumWidget3]);
        }
      }
      case .largeWidget3: {
        emit(state.copyWith(largeWidget3File: file));
        if(file != null) {
          selectItems([.largeWidget3]);
        }
      }
      default:
    }
  }

  void removeIcon(int id) {
    final List<IconItem> items = List.from(state.iconItems);
    final List<IconItem?> iconsPreviewItems = List.from(state.iconPreviewItems);
    final index = items.indexWhere((e) => e.id == id);
    if(index > -1) {
      items.removeAt(index);
    }
    final index2 = iconsPreviewItems.indexWhere((e) => e?.id == id);
    if(index2 > -1) {
      iconsPreviewItems[index2] = null;
    }

    emit(state.copyWith(
      iconItems: items,
      iconPreviewItems: iconsPreviewItems
    ));

    if (state.iconPreviewItems.every((e) => e == null)) {
      randomIconPreview();
    }
  }
}

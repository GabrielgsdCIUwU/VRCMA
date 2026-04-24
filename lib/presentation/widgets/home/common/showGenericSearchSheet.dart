import 'package:flutter/material.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';

typedef SearchableTextCallback<T> = String Function(T item);
typedef ItemBuilderCallback<T> = Widget Function(T item);
typedef OnItemSelectedCallback<T> = void Function(T? item);

void showGenericSearchSheet<T>({
  required BuildContext context,
  required List<T> items,
  required SearchableTextCallback<T> searchableText,
  required ItemBuilderCallback<T> itemBuilder,
  required OnItemSelectedCallback<T> onSelected,
  String searchHint = "Search...",
  Widget? headerOption,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _GenericSearchContent<T>(
            items: items,
            searchableText: searchableText,
            itemBuilder: itemBuilder,
            onSelected: onSelected,
            searchHint: searchHint,
            headerOption: headerOption,
          );
        },
      );
    },
  );
}

class _GenericSearchContent<T> extends StatefulWidget {
  final List<T> items;
  final SearchableTextCallback<T> searchableText;
  final ItemBuilderCallback<T> itemBuilder;
  final OnItemSelectedCallback<T> onSelected;
  final String searchHint;
  final Widget? headerOption;

  const _GenericSearchContent({
    required this.items,
    required this.searchableText,
    required this.itemBuilder,
    required this.onSelected,
    required this.searchHint,
    this.headerOption,
  });

  @override
  State<_GenericSearchContent<T>> createState() => _GenericSearchContentState<T>();
}

class _GenericSearchContentState<T> extends State<_GenericSearchContent<T>> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final List<T> filtered = widget.items.where((T item) {
      final text = widget.searchableText(item).toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: context.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _query = ""))
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              if (widget.headerOption != null) ...[
                widget.headerOption!,
                const Divider(),
              ],
              ...filtered.map((T item) => InkWell(
                onTap: () => widget.onSelected(item),
                child: widget.itemBuilder(item),
              )),
              if (filtered.isEmpty && _query.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text("No items match your search")),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
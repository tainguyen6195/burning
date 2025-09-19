import 'package:bruning/providers/product_provider.dart';
import 'package:bruning/widgets/error_indicator.dart';
import 'package:bruning/widgets/loading_indicator.dart';
import 'package:bruning/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      print(
        'SCROLL: Reached near the end of the list. Triggering next page load.',
      );
      final state = ref.read(productProvider);
      final notifier = ref.read(productProvider.notifier);
      if (state.status != ProductState.loading &&
          state.status != ProductState.endOfList) {
        notifier.fetchProducts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: notifier.onSearchQueryChanged,
            ),
          ),
        ),
      ),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildBody(ProductListState state, ProductNotifier notifier) {
    if (state.products.isEmpty && state.status == ProductState.loading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.products.isEmpty && state.status == ProductState.noData) {
      return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
    }

    if (state.products.isEmpty && state.status == ProductState.error) {
      return ErrorIndicator(
        errorMessage: state.errorMessage!,
        onRetry: notifier.fetchProducts,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount:
          state.products.length +
          (state.status == ProductState.endOfList ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == state.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: LoadingIndicator(),
          );
        }
        final product = state.products[index];
        return ProductCard(
          product: product,
          onFavoriteToggle: () => notifier.toggleFavorite(product),
        );
      },
    );
  }
}

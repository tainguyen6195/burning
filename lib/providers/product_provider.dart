import 'package:bruning/models/product.dart';
import 'package:bruning/services/api_service.dart';
import 'package:bruning/services/database.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProductState { initial, loading, loaded, error, endOfList, noData }

class ProductListState {
  final List<Product> products;
  final ProductState status;
  final String? errorMessage;
  final int totalCount;
  final String searchQuery;

  const ProductListState({
    this.products = const [],
    this.status = ProductState.initial,
    this.errorMessage,
    this.totalCount = 0,
    this.searchQuery = '',
  });

  ProductListState copyWith({
    List<Product>? products,
    ProductState? status,
    String? errorMessage,
    int? totalCount,
    String? searchQuery,
  }) {
    return ProductListState(
      products: products ?? this.products,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductListState>((ref) {
      return ProductNotifier(ref.read(apiService), ref.read(databaseService));
    });
final apiService = Provider((ref) => ApiService());
final databaseService = Provider((ref) => DatabaseService());

class ProductNotifier extends StateNotifier<ProductListState> {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final _debouncer = Debouncer(
    const Duration(milliseconds: 500),
    initialValue: '',
    checkEquality: false,
  );

  ProductNotifier(this._apiService, this._databaseService)
    : super(const ProductListState()) {
    _debouncer.values.listen((query) {
      if (query != state.searchQuery) {
        state = state.copyWith(
          products: [],
          searchQuery: query,
          status: ProductState.initial,
        );
        fetchProducts();
      }
    });
  }

  Future<void> fetchProducts() async {
    if (state.status == ProductState.loading ||
        state.status == ProductState.endOfList)
      return;
    state = state.copyWith(status: ProductState.loading);

    final int skip = state.searchQuery.isEmpty ? state.products.length : 0;

    try {
      final response =
          state.searchQuery.isEmpty
              ? await _apiService.getProducts(skip: skip)
              : await _apiService.searchProducts(
                query: state.searchQuery,
                skip: skip,
              );

      final favoriteIds = await _databaseService.getFavoriteIds();
      final newProducts =
          response.products.map((p) {
            return p.copyWith(isFavorite: favoriteIds.contains(p.id));
          }).toList();

      final allProducts =
          state.searchQuery.isEmpty
              ? [...state.products, ...newProducts]
              : newProducts;

      if (allProducts.isEmpty) {
        state = state.copyWith(status: ProductState.noData, products: []);
        return;
      }

      final bool endOfList = allProducts.length >= response.total;

      state = state.copyWith(
        products: allProducts,
        totalCount: response.total,
        status: endOfList ? ProductState.endOfList : ProductState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void onSearchQueryChanged(String query) {
    _debouncer.value = query;
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      final isFavorite = await _databaseService.toggleFavorite(product);
      final updatedProducts =
          state.products.map((p) {
            if (p.id == product.id) {
              return p.copyWith(isFavorite: isFavorite);
            }
            return p;
          }).toList();
      state = state.copyWith(products: updatedProducts);
    } catch (e) {
      state = state.copyWith(
        status: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

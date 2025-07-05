abstract class SearchEvent {
  const SearchEvent();
}

class SearchFoodsEvent extends SearchEvent {
  final String query;

  const SearchFoodsEvent(this.query);
}

class SearchRestaurantsEvent extends SearchEvent {
  final String query;

  const SearchRestaurantsEvent(this.query);
}

class SearchAllEvent extends SearchEvent {
  final String query;

  const SearchAllEvent(this.query);
}

class ClearSearchEvent extends SearchEvent {}

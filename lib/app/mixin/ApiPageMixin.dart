mixin ApiPageMixin{
  int currentPage;
  int perPage;
  int lastPage;
  int totalData;

  bool get hasNext => lastPage != currentPage;
}
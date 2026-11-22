abstract interface class IDatabaseMapper<T> {
  T fromDatabaseMap(Map<String, dynamic> row);

  Map<String, dynamic> toDatabaseMap(T entity);
}
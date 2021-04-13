class FirestorePath {
  static String user() => 'users';
  static String evets() => 'events';
  static String userActivities(String uid) => 'users/$uid/activities';
    static String userPosts(String uid) => 'users/$uid/posts';

    static String chats(String current,String to) => 'users/$current/chats/$to/messages';

  static String market() => 'market';
    static String productComments(String id) => 'market/$id/comments';

}

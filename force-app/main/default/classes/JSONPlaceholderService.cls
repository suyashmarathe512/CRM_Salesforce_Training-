public class JSONPlaceholderService {
    public List<PostWrapper> posts {get; set;}
    public List<CommentWrapper> comments {get; set;}
    public List<AlbumWrapper> albums {get; set;}
    public List<PhotoWrapper> photos {get; set;}
    public List<TodoWrapper> todos {get; set;}
    public List<UserWrapper> users {get; set;}
    public List<CommentWrapper> postComments {get; set;}
    public List<PhotoWrapper> albumPhotos {get; set;}
    public List<AlbumWrapper> userAlbums {get; set;}
    public List<TodoWrapper> userTodos {get; set;}
    public List<PostWrapper> userPosts {get; set;}
    public Integer postIdParam {get; set;}
    public Integer albumIdParam {get; set;}
    public Integer userIdParam {get; set;}

    private void clearList(){
        posts = new List<PostWrapper>();
        comments = new List<CommentWrapper>();
        albums = new List<AlbumWrapper>();
        photos =  new List<PhotoWrapper>();
        todos = new List<TodoWrapper>();
        users = new List<UserWrapper>();
        postComments = new List<CommentWrapper>();
        albumPhotos = new List<PhotoWrapper>();
        userAlbums = new List<AlbumWrapper>();
        userTodos = new List<TodoWrapper>();
        userPosts = new List<PostWrapper>();
    }
    public void fetchPosts() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/posts');
        if (json != null) {
            posts = (List<PostWrapper>) System.JSON.deserialize(json, List<PostWrapper>.class);
        }
    }

    public void fetchComments() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/comments');
        if (json != null) {
            comments = (List<CommentWrapper>) System.JSON.deserialize(json, List<CommentWrapper>.class);
        }
    }

    public void fetchAlbums() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/albums');
        if (json != null) {
            albums = (List<AlbumWrapper>) System.JSON.deserialize(json, List<AlbumWrapper>.class);
        }
    }

    public void fetchPhotos() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/photos?_limit=1000');
        if (json != null) {
            photos = (List<PhotoWrapper>) System.JSON.deserialize(json, List<PhotoWrapper>.class);
        }
    }

    public void fetchTodos() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/todos');
        if (json != null) {
            todos = (List<TodoWrapper>) System.JSON.deserialize(json, List<TodoWrapper>.class);
        }
    }

    public void fetchUsers() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/users');
        if (json != null) {
            users = (List<UserWrapper>) System.JSON.deserialize(json, List<UserWrapper>.class);
        }
    }

    public void fetchCommentsForPost() {
        clearList();
        if (postIdParam != null) {
            String json = makeHttpCall('https://jsonplaceholder.typicode.com/posts/' + postIdParam + '/comments');
            if (json != null) {
                postComments = (List<CommentWrapper>) System.JSON.deserialize(json, List<CommentWrapper>.class);
            }
        }
    }

    public void fetchPhotosForAlbum() {
        clearList();
        if (albumIdParam != null) {
            String json = makeHttpCall('https://jsonplaceholder.typicode.com/albums/' + albumIdParam + '/photos');
            if (json != null) {
                albumPhotos = (List<PhotoWrapper>) System.JSON.deserialize(json, List<PhotoWrapper>.class);
            }
        }
    }

    public void fetchAlbumsForUser() {
        clearList();
        if (userIdParam != null) {
            String json = makeHttpCall('https://jsonplaceholder.typicode.com/users/' + userIdParam + '/albums');
            if (json != null) {
                userAlbums = (List<AlbumWrapper>) System.JSON.deserialize(json, List<AlbumWrapper>.class);
            }
        }
    }

    public void fetchTodosForUser() {
        clearList();
        if (userIdParam != null) {
            String json = makeHttpCall('https://jsonplaceholder.typicode.com/users/' + userIdParam + '/todos');
            if (json != null) {
                userTodos = (List<TodoWrapper>) System.JSON.deserialize(json, List<TodoWrapper>.class);
            }
        }
    }

    public void fetchPostsForUser() {
        clearList();
        if (userIdParam != null) {
            String json = makeHttpCall('https://jsonplaceholder.typicode.com/users/' + userIdParam + '/posts');
            if (json != null) {
                userPosts = (List<PostWrapper>) System.JSON.deserialize(json, List<PostWrapper>.class);
            }
        }
    }

    public void clearPostComments() {
        postComments = new List<CommentWrapper>();
    }

    public void clearAlbumPhotos() {
        albumPhotos = new List<PhotoWrapper>();
    }

    public void clearUserAlbums() {
        userAlbums = new List<AlbumWrapper>();
    }

    public void clearUserTodos() {
        userTodos = new List<TodoWrapper>();
    }

    public void clearUserPosts() {
        userPosts = new List<PostWrapper>();
    }

    private String makeHttpCall(String endpoint) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            System.debug('Error: ' + response.getStatus());
            return null;
        }
    }

    public class PostWrapper {
        public Integer id {get; set;}
        public Integer userId {get; set;}
        public String title {get; set;}
        public String body {get; set;}
    }

    public class CommentWrapper {
        public Integer id {get; set;}
        public Integer postId {get; set;}
        public String name {get; set;}
        public String email {get; set;}
        public String body {get; set;}
    }

    public class AlbumWrapper {
        public Integer id {get; set;}
        public Integer userId {get; set;}
        public String title {get; set;}
    }

    public class PhotoWrapper {
        public Integer id {get; set;}
        public Integer albumId {get; set;}
        public String title {get; set;}
        public String url {get; set;}
        public String thumbnailUrl {get; set;}
    }

    public class TodoWrapper {
        public Integer id {get; set;}
        public Integer userId {get; set;}
        public String title {get; set;}
        public Boolean completed {get; set;}
    }

    public class UserWrapper {
        public Integer id {get; set;}
        public String name {get; set;}
        public String username {get; set;}
        public String email {get; set;}
        public String phone {get; set;}
        public String website {get; set;}
    }
}

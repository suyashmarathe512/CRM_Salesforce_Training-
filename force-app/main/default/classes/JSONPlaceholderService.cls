public class JSONPlaceholderService {
    private static final Integer PAGE_SIZE = 10;

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

    // Pagination properties
    public List<PhotoWrapper> photosPage {get; set;}
    public Integer photosPageNumber {get; set;}
    public Integer photosTotalPages {get; set;}

    public List<TodoWrapper> todosPage {get; set;}
    public Integer todosPageNumber {get; set;}
    public Integer todosTotalPages {get; set;}

    public List<UserWrapper> usersPage {get; set;}
    public Integer usersPageNumber {get; set;}
    public Integer usersTotalPages {get; set;}

    public List<PhotoWrapper> albumPhotosPage {get; set;}
    public Integer albumPhotosPageNumber {get; set;}
    public Integer albumPhotosTotalPages {get; set;}

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

        // Initialize pagination
        photosPage = new List<PhotoWrapper>();
        photosPageNumber = 1;
        photosTotalPages = 1;

        todosPage = new List<TodoWrapper>();
        todosPageNumber = 1;
        todosTotalPages = 1;

        usersPage = new List<UserWrapper>();
        usersPageNumber = 1;
        usersTotalPages = 1;

        albumPhotosPage = new List<PhotoWrapper>();
        albumPhotosPageNumber = 1;
        albumPhotosTotalPages = 1;
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
        if (photos != null && !photos.isEmpty()) {
            photosPageNumber = 1;
            photosTotalPages = (Integer) Math.ceil((Double) photos.size() / PAGE_SIZE);
            photosPage = getPhotosPage();
        } else {
            photosPage = new List<PhotoWrapper>();
            photosPageNumber = 1;
            photosTotalPages = 1;
        }
    }

    public void fetchTodos() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/todos');
        if (json != null) {
            todos = (List<TodoWrapper>) System.JSON.deserialize(json, List<TodoWrapper>.class);
        }
        if (todos != null && !todos.isEmpty()) {
            todosPageNumber = 1;
            todosTotalPages = (Integer) Math.ceil((Double) todos.size() / PAGE_SIZE);
            todosPage = getTodosPage();
        } else {
            todosPage = new List<TodoWrapper>();
            todosPageNumber = 1;
            todosTotalPages = 1;
        }
    }

    public void fetchUsers() {
        clearList();
        String json = makeHttpCall('https://jsonplaceholder.typicode.com/users');
        if (json != null) {
            users = (List<UserWrapper>) System.JSON.deserialize(json, List<UserWrapper>.class);
        }
        if (users != null && !users.isEmpty()) {
            usersPageNumber = 1;
            usersTotalPages = (Integer) Math.ceil((Double) users.size() / PAGE_SIZE);
            usersPage = getUsersPage();
        } else {
            usersPage = new List<UserWrapper>();
            usersPageNumber = 1;
            usersTotalPages = 1;
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
        if (albumPhotos != null && !albumPhotos.isEmpty()) {
            albumPhotosPageNumber = 1;
            albumPhotosTotalPages = (Integer) Math.ceil((Double) albumPhotos.size() / PAGE_SIZE);
            albumPhotosPage = getAlbumPhotosPage();
        } else {
            albumPhotosPage = new List<PhotoWrapper>();
            albumPhotosPageNumber = 1;
            albumPhotosTotalPages = 1;
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

    // Pagination helper methods
    private List<PhotoWrapper> getPhotosPage() {
        if (photos == null || photos.isEmpty()) return new List<PhotoWrapper>();
        Integer startIndex = (photosPageNumber - 1) * PAGE_SIZE;
        Integer endIndex = Math.min(startIndex + PAGE_SIZE, photos.size());
        List<PhotoWrapper> page = new List<PhotoWrapper>();
        for (Integer i = startIndex; i < endIndex; i++) {
            page.add(photos[i]);
        }
        return page;
    }

    private List<TodoWrapper> getTodosPage() {
        if (todos == null || todos.isEmpty()) return new List<TodoWrapper>();
        Integer startIndex = (todosPageNumber - 1) * PAGE_SIZE;
        Integer endIndex = Math.min(startIndex + PAGE_SIZE, todos.size());
        List<TodoWrapper> page = new List<TodoWrapper>();
        for (Integer i = startIndex; i < endIndex; i++) {
            page.add(todos[i]);
        }
        return page;
    }

    private List<UserWrapper> getUsersPage() {
        if (users == null || users.isEmpty()) return new List<UserWrapper>();
        Integer startIndex = (usersPageNumber - 1) * PAGE_SIZE;
        Integer endIndex = Math.min(startIndex + PAGE_SIZE, users.size());
        List<UserWrapper> page = new List<UserWrapper>();
        for (Integer i = startIndex; i < endIndex; i++) {
            page.add(users[i]);
        }
        return page;
    }

    private List<PhotoWrapper> getAlbumPhotosPage() {
        if (albumPhotos == null || albumPhotos.isEmpty()) return new List<PhotoWrapper>();
        Integer startIndex = (albumPhotosPageNumber - 1) * PAGE_SIZE;
        Integer endIndex = Math.min(startIndex + PAGE_SIZE, albumPhotos.size());
        List<PhotoWrapper> page = new List<PhotoWrapper>();
        for (Integer i = startIndex; i < endIndex; i++) {
            page.add(albumPhotos[i]);
        }
        return page;
    }

    // Pagination navigation methods
    public void prevPhotos() {
        if (photosPageNumber > 1) {
            photosPageNumber--;
            photosPage = getPhotosPage();
        }
    }

    public void nextPhotos() {
        if (photosPageNumber < photosTotalPages) {
            photosPageNumber++;
            photosPage = getPhotosPage();
        }
    }

    public void prevTodos() {
        if (todosPageNumber > 1) {
            todosPageNumber--;
            todosPage = getTodosPage();
        }
    }

    public void nextTodos() {
        if (todosPageNumber < todosTotalPages) {
            todosPageNumber++;
            todosPage = getTodosPage();
        }
    }

    public void prevUsers() {
        if (usersPageNumber > 1) {
            usersPageNumber--;
            usersPage = getUsersPage();
        }
    }

    public void nextUsers() {
        if (usersPageNumber < usersTotalPages) {
            usersPageNumber++;
            usersPage = getUsersPage();
        }
    }

    public void prevAlbumPhotos() {
        if (albumPhotosPageNumber > 1) {
            albumPhotosPageNumber--;
            albumPhotosPage = getAlbumPhotosPage();
        }
    }

    public void nextAlbumPhotos() {
        if (albumPhotosPageNumber < albumPhotosTotalPages) {
            albumPhotosPageNumber++;
            albumPhotosPage = getAlbumPhotosPage();
        }
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

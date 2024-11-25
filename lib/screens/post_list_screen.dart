import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:admin/models/post_model.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({Key? key}) : super(key: key);

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final storage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  final List<String> _statusOptions = ['All', 'Active', 'Pending', 'Deleted'];

  List<Post> posts = [];
  List<Post> visiblePosts = [];
  int itemsPerPage = 5;
  int currentPage = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await storage.read(key: "authToken");
      final response = await http.get(
        Uri.parse('https://be-android-project.onrender.com/api/post/getAll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((json) => Post.fromJson(json)).toList();
          filterPosts();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> approvePost(String postId) async {
    try {
      final token = await storage.read(key: "authToken");
      final response = await http.put(
        Uri.parse('https://be-android-project.onrender.com/api/post/$postId/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Approve response: ${response.statusCode}');
      print('Approve body: ${response.body}');

      if (response.statusCode == 200) {
        fetchPosts();
        filterPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã duyệt bài viết')),
        );
        fetchPosts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi duyệt bài')),
        );
      }
    } catch (e) {
      print('Error approving post: $e');
    }
  }

  Future<void> softDeletePost(String postId) async {
    try {
      final token = await storage.read(key: "authToken");
      final response = await http.put(
        Uri.parse('https://be-android-project.onrender.com/api/post/$postId/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchPosts();
        filterPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tạm thời bài viết')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } catch (e) {
      print('Error soft deleting post: $e');
    }
  }

  Future<void> permanentDeletePost(String postId) async {
    try {
      final token = await storage.read(key: "authToken");
      final response = await http.delete(
        Uri.parse('https://be-android-project.onrender.com/api/post/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa vĩnh viễn bài viết')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } catch (e) {
      print('Error permanent deleting post: $e');
    }
  }

  void filterPosts() {
    final String searchTerm = _searchController.text.toLowerCase();
    List<Post> filteredPosts = posts;
    
    if (searchTerm.isNotEmpty) {
      filteredPosts = filteredPosts
          .where((post) => post.title.toLowerCase().contains(searchTerm))
          .toList();
    }
    
    if (_selectedStatus != 'All') {
      filteredPosts = filteredPosts
          .where((post) => post.status == _selectedStatus)
          .toList();
    }

    setState(() {
      visiblePosts = getPaginatedPosts(filteredPosts);
    });
  }

  List<Post> getPaginatedPosts(List<Post> filteredPosts) {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredPosts.length) return [];
    return filteredPosts.sublist(start, 
        end > filteredPosts.length ? filteredPosts.length : end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài đăng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => filterPosts(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Trạng thái: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      setState(() {
                        _selectedStatus = newValue!;
                        filterPosts();
                      });
                      await fetchPosts();
                      filterPosts();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, 
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(error!),
                            ElevatedButton(
                              onPressed: fetchPosts,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : visiblePosts.isEmpty
                        ? const Center(child: Text('Không có bài đăng nào'))
                        : ListView.builder(
                            itemCount: visiblePosts.length,
                            itemBuilder: (context, index) {
                              final post = visiblePosts[index];
                              return PostCard(
                                post: post,
                                onApprove: () => approvePost(post.id),
                                onSoftDelete: () => softDeletePost(post.id),
                                onPermanentDelete: () => permanentDeletePost(post.id),
                              );
                            },
                          ),
          ),
          if (!isLoading && error == null && posts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              currentPage--;
                              filterPosts();
                            });
                          }
                        : null,
                  ),
                  Text(
                    'Trang ${currentPage + 1}/${(posts.length / itemsPerPage).ceil()}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (currentPage + 1) * itemsPerPage < posts.length
                        ? () {
                            setState(() {
                              currentPage++;
                              filterPosts();
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onApprove;
  final VoidCallback onSoftDelete;
  final VoidCallback onPermanentDelete;

  const PostCard({
    Key? key,
    required this.post,
    required this.onApprove,
    required this.onSoftDelete,
    required this.onPermanentDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.images.isNotEmpty)
            Image.network(
              post.images.first.url,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error_outline, size: 100),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Giá: ${post.price ?? "Chưa cập nhật"} VND'),
                Text('Địa chỉ: ${post.location.address}'),
                Text('Trạng thái: ${post.status}'),
                Text('Chủ trọ: ${post.landlord.username}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (post.status == 'Pending') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Duyệt'),
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                        onPressed: onSoftDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ] else if (post.status == 'Deleted') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.restore),
                        label: const Text('Khôi phục'),
                        onPressed: onApprove,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Xóa vĩnh viễn'),
                        onPressed: onPermanentDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ] else if (post.status == 'Active') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa tạm thời'),
                        onPressed: onSoftDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'quiz_page.dart';

class CourseLesson {
  final String title;
  final String duration;
  final String? videoId;
  final String? pdfUrl;

  CourseLesson({
    required this.title,
    required this.duration,
    this.videoId,
    this.pdfUrl,
  });
}

class Course {
  final String title;
  final String imagePath;
  final Color color;
  final List<CourseLesson> lessons;

  Course({
    required this.title,
    required this.imagePath,
    required this.color,
    required this.lessons,
  });
}

class PDFViewerPage extends StatefulWidget {
  final String filePath;
  final String title;

  const PDFViewerPage({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  PDFViewController? _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 0
                ? () {
                    _pdfViewController?.setPage(_currentPage - 1);
                  }
                : null,
          ),
          Center(
            child: Text(
              'Page ${_currentPage + 1} of $_totalPages',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < _totalPages - 1
                ? () {
                    _pdfViewController?.setPage(_currentPage + 1);
                  }
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: false,
            pageSnap: false,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onViewCreated: (PDFViewController pdfViewController) {
              setState(() {
                _pdfViewController = pdfViewController;
              });
            },
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isLoading = false;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page!;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading PDF: $error')),
              );
              Navigator.pop(context);
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  YoutubePlayerController? _controller;
  String? _currentVideoId;
  bool _isLoadingVideo = false;
  bool _hasVideoError = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeFirstVideo();
  }

  void _initializeFirstVideo() {
    final firstVideoLesson = widget.course.lessons.firstWhere(
      (lesson) => lesson.videoId != null,
      orElse: () => CourseLesson(title: '', duration: ''),
    );

    if (firstVideoLesson.videoId != null) {
      _playVideo(firstVideoLesson.videoId!);
    }
  }

  Future<void> _initializePlayer(String videoId) async {
    if (_isDisposed) return;

    if (_currentVideoId == videoId && _controller != null && !_hasVideoError) {
      return;
    }

    setState(() {
      _isLoadingVideo = true;
      _hasVideoError = false;
    });

    YoutubePlayerController? oldController = _controller;
    _controller = null;

    try {
      if (oldController != null) {
        await oldController.close();
      }

      if (_isDisposed) return;

      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );

      if (_isDisposed) {
        await controller.close();
        return;
      }

      setState(() {
        _controller = controller;
        _currentVideoId = videoId;
        _isLoadingVideo = false;
      });
    } catch (e) {
      if (_isDisposed) return;

      setState(() {
        _hasVideoError = true;
        _isLoadingVideo = false;
        _currentVideoId = null;
        _controller = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controller != null) {
      _controller!.close();
      _controller = null;
    }
    super.dispose();
  }

  Future<void> _playVideo(String videoId) async {
    if (_isDisposed) return;
    await _initializePlayer(videoId);
  }

  Future<void> _viewPdf(String? pdfUrl, String lessonTitle) async {
    if (pdfUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF not available yet')),
      );
      return;
    }

    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading PDF...')),
      );

      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');

      // Check if the PDF exists in assets
      try {
        final ByteData data = await rootBundle.load(pdfUrl);
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes, flush: true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF file not found in assets')),
        );
        return;
      }

      if (!mounted) return;

      // Navigate to PDF viewer page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(
            filePath: file.path,
            title: lessonTitle,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title.split('\n')[0]),
        backgroundColor: widget.course.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _controller != null && !_hasVideoError
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        SizedBox.expand(
                          child: YoutubePlayer(
                            controller: _controller!,
                            aspectRatio: 16 / 9,
                          ),
                        ),
                        if (_isLoadingVideo)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: widget.course.color,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Loading video...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hasVideoError
                                ? Icons.error_outline
                                : Icons.play_circle_outline,
                            size: 64,
                            color: _hasVideoError
                                ? Colors.red
                                : widget.course.color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasVideoError
                                ? 'Error loading video'
                                : 'Select a video to play',
                            style: TextStyle(
                              color: _hasVideoError
                                  ? Colors.red
                                  : widget.course.color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // Lessons List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.course.lessons.length,
              itemBuilder: (context, index) {
                final lesson = widget.course.lessons[index];
                final bool isCurrentVideo = lesson.videoId == _currentVideoId;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      lesson.title,
                      style: TextStyle(
                        fontWeight: isCurrentVideo
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentVideo ? widget.course.color : null,
                      ),
                    ),
                    subtitle: Text(
                      'Duration: ${lesson.duration}',
                      style: TextStyle(
                        color: isCurrentVideo
                            ? widget.course.color.withOpacity(0.7)
                            : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lesson.videoId != null)
                          IconButton(
                            icon: Icon(
                              isCurrentVideo &&
                                      !_isLoadingVideo &&
                                      !_hasVideoError
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: isCurrentVideo && !_hasVideoError
                                  ? widget.course.color
                                  : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () => _playVideo(lesson.videoId!),
                          ),
                        if (lesson.pdfUrl != null)
                          IconButton(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 32,
                            ),
                            onPressed: () =>
                                _viewPdf(lesson.pdfUrl, lesson.title),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Quiz Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        courseTitle: widget.course.title.split('\n')[0],
                        courseColor: widget.course.color,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Take Quiz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

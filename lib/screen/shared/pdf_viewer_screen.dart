import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';

import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';

class PdfViewerScreen extends StatefulWidget {
  /// The full URL of the PDF to display (used only when [localBytes] is null).
  final String url;

  /// Title shown in the AppBar.
  final String title;

  /// Pre-loaded bytes (e.g. from a locally-picked file). If provided, [url] is not fetched.
  final Uint8List? localBytes;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
    this.localBytes,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PageController _pageController = PageController();
  final TransformationController _transformationController =
      TransformationController();

  Uint8List? _pdfBytes;
  int _totalPages = 1;
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Use pre-loaded bytes if available (locally-picked file)
      final bytes = widget.localBytes ?? await _fetchFromUrl();
      if (bytes == null) return; // error already set inside _fetchFromUrl

      // Count pages with Syncfusion
      int pages = 1;
      try {
        final doc = PdfDocument(inputBytes: bytes);
        pages = doc.pages.count;
        doc.dispose();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _totalPages = pages > 0 ? pages : 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List?> _fetchFromUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load PDF (HTTP ${response.statusCode})';
            _isLoading = false;
          });
        }
        return null;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
      return null;
    }
  }

  void _zoom(double factor) {
    setState(() {
      final current =
          _transformationController.value.getMaxScaleOnAxis();
      final next = (current * factor).clamp(1.0, 4.0);
      _transformationController.value = Matrix4.identity()..scale(next);
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CustomLoader())
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Page ${_currentPage + 1} / $_totalPages',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PDF PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _totalPages,
                        onPageChanged: (i) {
                          setState(() {
                            _currentPage = i;
                            _resetZoom();
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  child: InteractiveViewer(
                                    transformationController:
                                        _transformationController,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: _RasterizedPage(
                                      pdfBytes: _pdfBytes!,
                                      pageIndex: index,
                                    ),
                                  ),
                                ),
                                // Zoom buttons
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Column(
                                    children: [
                                      _zoomBtn(
                                          Icons.add, () => _zoom(1.25)),
                                      const SizedBox(height: 8),
                                      _zoomBtn(Icons.remove,
                                          () => _zoom(0.8)),
                                      const SizedBox(height: 8),
                                      _zoomBtn(
                                          Icons.refresh, _resetZoom),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Prev / Next navigation
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentPage > 0
                                ? () => _pageController.previousPage(
                                      duration: const Duration(
                                          milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: Text(
                              'Previous',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                _currentPage < _totalPages - 1
                                    ? () => _pageController.nextPage(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        )
                                    : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              'Next',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdf,
              icon: const Icon(Icons.refresh),
              label: Text('Retry',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// Renders a single rasterized page from [pdfBytes] at [pageIndex].
class _RasterizedPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final int pageIndex;

  const _RasterizedPage(
      {required this.pdfBytes, required this.pageIndex});

  @override
  State<_RasterizedPage> createState() => _RasterizedPageState();
}

class _RasterizedPageState extends State<_RasterizedPage> {
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _rasterize();
  }

  @override
  void didUpdateWidget(_RasterizedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      _rasterize();
    }
  }

  Future<void> _rasterize() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      await for (final page in Printing.raster(widget.pdfBytes,
          pages: [widget.pageIndex])) {
        final bytes = await page.toPng();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _loading = false;
          });
        }
        break;
      }
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CustomLoader());
    if (_error || _imageBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Failed to render page',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return Image.memory(_imageBytes!,
        fit: BoxFit.contain, width: double.infinity);
  }
}

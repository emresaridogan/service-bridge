/// Parameters for creating a deep link.
class DeepLinkParams {
  /// Creates [DeepLinkParams].
  const DeepLinkParams({
    required this.link,
    this.domainUriPrefix,
    this.title,
    this.description,
    this.imageUrl,
    this.customParameters = const {},
  });

  /// The deep link URL.
  final Uri link;

  /// Domain URI prefix (e.g., 'https://example.page.link').
  final String? domainUriPrefix;

  /// Title for social meta tags.
  final String? title;

  /// Description for social meta tags.
  final String? description;

  /// Image URL for social meta tags.
  final String? imageUrl;

  /// Additional custom parameters.
  final Map<String, String> customParameters;
}

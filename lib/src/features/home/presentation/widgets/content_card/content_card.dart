// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:air_control/src/features/home/domain/models/content_item.dart';
import 'package:air_control/src/features/home/presentation/controllers/content_controller.dart';

/// Full-screen content card widget (TikTok-style)
class ContentCard extends StatelessWidget {
  final ContentItem content;
  final bool isActive;
  final VoidCallback? onDoubleTap;

  const ContentCard({
    super.key,
    required this.content,
    this.isActive = false,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          _buildMediaContent(),

          // Gradient overlay
          _buildGradientOverlay(),

          // Content info
          _buildContentInfo(context),

          // Side actions
          _buildSideActions(context),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    return CachedNetworkImage(
      imageUrl: content.url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildContentInfo(BuildContext context) {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Author info
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: content.authorAvatar != null
                      ? CachedNetworkImage(
                          imageUrl: content.authorAvatar!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey[800]),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white54,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Author name and follow button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.author ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (content.userRating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'You rated ${content.userRating!.toInt()} stars',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          if (content.title != null)
            Text(
              content.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildSideActions(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 100,
      child: Column(
        children: [
          // Like button
          _ActionButton(
            onTap: () {},
            icon: Icons.favorite_rounded,
            label: formatCount(content.likes),
            color: Colors.white,
          ),
          const SizedBox(height: 20),

          // Comment button
          _ActionButton(
            onTap: () {},
            icon: Icons.chat_bubble_rounded,
            label: formatCount(content.comments),
            color: Colors.white,
          ),
          const SizedBox(height: 20),

          // Share button
          _ActionButton(
            onTap: () {},
            icon: Icons.share_rounded,
            label: formatCount(content.shares),
            color: Colors.white,
          ),
          const SizedBox(height: 20),

          // Rating indicator
          if (content.userRating != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
